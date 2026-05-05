import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  // Field sesuai schema tabel users
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var identityNumber = ''.obs; 
  var role = ''.obs;

  var isUpdating = false.obs;

  final box = GetStorage();
  final String baseUrl = 'http://192.168.88.191:8080';

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    name.value = box.read('name') ?? '';
    email.value = box.read('email') ?? '';
    phone.value = box.read('phone') ?? '';
    identityNumber.value = box.read('identity_number') ?? '';
    role.value = box.read('role') ?? 'pendaki';
  }

  // Update nama saja secara lokal + API
  Future<void> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    final token = box.read('token');
    if (token == null) return;

    isUpdating.value = true;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': newName,
          'phone': newPhone,
        }),
      );

      if (response.statusCode == 200) {
        // Update storage
        name.value = newName;
        phone.value = newPhone;
        box.write('name', newName);
        box.write('phone', newPhone);

        Get.snackbar(
          'Berhasil',
          'Profil berhasil diperbarui!',
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal memperbarui profil',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } on http.ClientException {
      Get.snackbar(
        'Error Koneksi',
        'Tidak dapat terhubung ke server',
        backgroundColor: Colors.orange[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isUpdating.value = false;
    }
  }

  void logout() {
    box.erase();
    Get.offAllNamed('/login');
  }
}