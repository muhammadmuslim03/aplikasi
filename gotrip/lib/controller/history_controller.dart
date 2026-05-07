import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../model/ticket_model.dart';

class HistoryController extends GetxController {
  final historyList = <TicketModel>[].obs;
  final isLoading = false.obs;

  final String baseUrl = 'http://10.100.229.109:8080';

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final token = GetStorage().read('token');

    print("=== FETCH HISTORY ===");
    print("TOKEN => $token");

    if (token == null) {
      Get.snackbar(
        'Error',
        'Token tidak ditemukan. Silakan login ulang.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("STATUS CODE => ${response.statusCode}");
      print("RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final List raw = jsonBody is List
            ? jsonBody
            : (jsonBody['tickets'] ?? jsonBody['data'] ?? []);

        print("TOTAL DATA => ${raw.length}");

        historyList.assignAll(
          raw.map((e) {
            print("ITEM => $e"); // 🔥 debug tiap item
            return TicketModel.fromJson(e);
          }).toList(),
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal memuat riwayat booking (${response.statusCode})',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } on http.ClientException catch (e) {
      print("CLIENT ERROR => $e");

      Get.snackbar(
        'Error Koneksi',
        'Tidak dapat terhubung ke server',
        backgroundColor: Colors.orange[700],
        colorText: Colors.white,
      );
    } catch (e) {
      print("ERROR => $e");

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

  // 🔥 OPTIONAL: refresh manual
  Future<void> refreshHistory() async {
    await fetchHistory();
  }
}
