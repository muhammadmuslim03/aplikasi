import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  var email = ''.obs;
  var isLoading = false.obs;

  void sendResetLink() async {
    if (email.value.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    Get.snackbar(
      'Berhasil',
      'Link reset password telah dikirim ke ${email.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1D4F44),
      colorText: const Color(0xFFFFFFFF),
    );

    Get.back();
  }
}
