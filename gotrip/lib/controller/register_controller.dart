import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  var username = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  final String baseUrl = 'http://10.246.143.109:8080';

  Future<void> register() async {
    if (username.value.isEmpty ||
        email.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar('Gagal', 'Semua kolom wajib diisi');
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar('Gagal', 'Password dan konfirmasi tidak sama');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.value,
          'email': email.value,
          'password': password.value,
          'confirm_password': confirmPassword.value,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Registrasi berhasil!',
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Gagal',
          data['error'] ?? 'Registrasi gagal',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isLoading.value = false;
    }
  }
}
