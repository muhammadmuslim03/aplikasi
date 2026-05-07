import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var NIK = ''.obs; 
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs;

  final String baseUrl = 'http://10.100.229.109:8080';

  Future<void> register() async {
    if (name.value.isEmpty ||
        email.value.isEmpty ||
        phone.value.isEmpty ||
        NIK.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Semua kolom wajib diisi',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar(
        'Gagal',
        'Password dan konfirmasi tidak sama',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.value,                       
          'email': email.value,
          'phone': phone.value,                    
          'NIK': NIK.value,  
          'password': password.value,
          'role': 'pendaki',                     
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Akun berhasil dibuat! Silakan login.',
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
      } else {
        final String errorMsg =
            data['error'] ?? data['message'] ?? 'Registrasi gagal';
        Get.snackbar(
          'Gagal',
          errorMsg,
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
}