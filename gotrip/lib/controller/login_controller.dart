import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../model/user_model.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  final box = GetStorage();

  final String baseUrl = 'http://10.100.229.109:8080';

  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email dan password tidak boleh kosong',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.value,
          'password': password.value,
          'client': 'mobile',
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String token = responseBody['token'];

        // Parse user menggunakan UserModel baru (sesuai schema DB)
        final UserModel user = UserModel.fromJson(responseBody['user']);

        // Simpan ke local storage
        box.write('token', token);
        box.write('user_id', user.id);
        box.write('name', user.name);           // Pakai 'name', bukan 'username'
        box.write('email', user.email);
        box.write('phone', user.phone ?? '');
        box.write('role', user.role);

        Get.snackbar(
          'Berhasil',
          'Selamat datang, ${user.name}!',
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );

        // Arahkan berdasarkan role
        if (user.role == 'admin') {
          Get.offAllNamed('/admin-home');
        } else {
          Get.offAllNamed('/home');
        }
      } else {
        final String errorMessage =
            responseBody['error'] ?? responseBody['message'] ?? 'Login gagal';
        Get.snackbar(
          'Gagal',
          errorMessage,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } on http.ClientException {
      Get.snackbar(
        'Error Koneksi',
        'Tidak dapat terhubung ke server. Periksa jaringan kamu.',
        backgroundColor: Colors.orange[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.toNamed('/forgot');
  }

  // Helper: ambil data user dari storage
  static String get savedName => GetStorage().read('name') ?? '';
  static String get savedEmail => GetStorage().read('email') ?? '';
  static String get savedRole => GetStorage().read('role') ?? 'pendaki';
  static String get savedToken => GetStorage().read('token') ?? '';

  void logout() {
    box.erase();
    Get.offAllNamed('/login');
  }
}