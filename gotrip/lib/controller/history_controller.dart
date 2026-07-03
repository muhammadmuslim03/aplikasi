import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/payment_model.dart';
import '../model/ticket_model.dart';
import '../view/payment_proof_screen.dart';
import '../view/payment_screen.dart';

class HistoryController extends GetxController {
  final historyList = <TicketModel>[].obs;
  final isLoading = false.obs;
  final processingTicketId = ''.obs;
  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final token = GetStorage().read('token');

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
        ApiConfig.uri('/api/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final List raw = jsonBody is List
            ? jsonBody
            : (jsonBody['tickets'] ?? jsonBody['data'] ?? []);

        historyList.assignAll(raw.map((e) => TicketModel.fromJson(e)).toList());
      } else {
        Get.snackbar(
          'Error',
          'Gagal memuat riwayat booking (${response.statusCode})',
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

  Future<void> refreshHistory() async {
    await fetchHistory();
  }

  Future<void> continuePayment(TicketModel ticket) async {
    final token = GetStorage().read('token');

    if (token == null) {
      Get.snackbar(
        'Error',
        'Token tidak ditemukan. Silakan login ulang.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    processingTicketId.value = ticket.id;

    try {
      final response = await http.post(
        ApiConfig.uri('/api/payments/create/${ticket.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decodedBody = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      final jsonBody = decodedBody is Map<String, dynamic>
          ? decodedBody
          : <String, dynamic>{};

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (_shouldUseManualPaymentFallback(response.statusCode, jsonBody)) {
          await _openManualPayment(ticket);
          return;
        }

        Get.snackbar(
          'Gagal',
          jsonBody['error'] ?? 'Gagal membuat pembayaran',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
        return;
      }

      final rawPayment = jsonBody['payment'];
      if (rawPayment is! Map<String, dynamic>) {
        Get.snackbar(
          'Info',
          jsonBody['message'] ?? 'Status pembayaran diperbarui',
          backgroundColor: const Color(0xFF1D4F44),
          colorText: Colors.white,
        );
        await fetchHistory();
        return;
      }

      final paymentUrl = rawPayment['payment_url']?.toString() ?? '';
      if (paymentUrl.isEmpty) {
        if (_isManualPaymentResponse(jsonBody, rawPayment)) {
          await _openManualPayment(ticket);
          return;
        }

        Get.snackbar(
          'Gagal',
          'Payment URL Midtrans tidak tersedia',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
        return;
      }

      await Get.to(
        () => PaymentScreen(
          ticketId: ticket.id,
          paymentUrl: paymentUrl,
          snapToken: rawPayment['snap_token']?.toString(),
        ),
        transition: Transition.rightToLeft,
      );

      await fetchHistory();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      processingTicketId.value = '';
    }
  }

  bool _shouldUseManualPaymentFallback(
    int statusCode,
    Map<String, dynamic> body,
  ) {
    final code = body['code']?.toString() ?? '';
    final error = (body['error']?.toString() ?? '').toLowerCase();

    return statusCode == 503 &&
        (code == 'MIDTRANS_CONFIG_MISSING' ||
            error.contains('konfigurasi midtrans'));
  }

  bool _isManualPaymentResponse(
    Map<String, dynamic> body,
    Map<String, dynamic> payment,
  ) {
    final provider = payment['provider']?.toString().toLowerCase() ?? '';
    final code = body['code']?.toString() ?? '';

    return provider == 'manual' ||
        body['manual_payment_available'] == true ||
        code == 'MIDTRANS_CONFIG_MISSING';
  }

  Future<void> _openManualPayment(TicketModel ticket) async {
    Get.snackbar(
      'Pembayaran Manual',
      'Midtrans belum dikonfigurasi. Silakan upload bukti transfer manual.',
      backgroundColor: Colors.orange[700],
      colorText: Colors.white,
    );

    await Get.to(
      () => PaymentProofScreen(paymentData: PaymentModel.fromTicket(ticket)),
      transition: Transition.rightToLeft,
    );

    await fetchHistory();
  }
}
