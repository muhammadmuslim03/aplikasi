import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class CheckinCheckoutController extends GetxController {
  final isSubmitting = false.obs;
  final lastMessage = ''.obs;

  Future<bool> submitBarcode(String code) async {
    final token = GetStorage().read('token');

    if (token == null) {
      Get.snackbar(
        'Error',
        'Token tidak ditemukan. Silakan login ulang.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return false;
    }

    isSubmitting.value = true;
    lastMessage.value = '';

    try {
      final response = await http.post(
        ApiConfig.uri('/api/checkpoint/scan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'code': code}),
      );

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final message = body['message'] ?? body['error'] ?? 'Barcode diproses';

      if (response.statusCode == 200) {
        lastMessage.value = message;
        Get.snackbar(
          'Berhasil',
          message,
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );
        return true;
      }

      Get.snackbar(
        'Gagal',
        message,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat memproses barcode: ${e.toString()}',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
