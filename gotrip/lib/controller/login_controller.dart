import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  final String baseUrl = 'http://10.246.143.109:8080';

  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Gagal', 'Email dan password tidak boleh kosong');
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
          "role": "pendaki",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        box.write('token', token);
        box.write('user_id', userData['id']);
        box.write('name', userData['username']);
        box.write('email', userData['email']);
        box.write('role', userData['role']);

        Get.snackbar(
          'Berhasil',
          'Login berhasil!',
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );
        Get.offAllNamed('/home');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login gagal';
        Get.snackbar(
          'Gagal',
          error,
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

  void forgotPassword() {
    Get.toNamed('/forgot');
  }
}
