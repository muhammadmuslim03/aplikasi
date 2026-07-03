import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../model/ticket_model.dart';
import 'eticket_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String ticketId;
  final String paymentUrl;
  final String? snapToken;

  const PaymentScreen({
    super.key,
    required this.ticketId,
    required this.paymentUrl,
    this.snapToken,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isOpening = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPaymentUrl());
  }

  Future<void> _openPaymentUrl() async {
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null) {
      Get.snackbar(
        'Gagal',
        'Payment URL tidak valid',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isOpening = true);

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        Get.snackbar(
          'Gagal',
          'Halaman pembayaran tidak dapat dibuka',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _checkPaymentStatus() async {
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

    setState(() => _isChecking = true);

    try {
      final response = await http.get(
        ApiConfig.uri('/api/payments/status/${widget.ticketId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonBody = jsonDecode(response.body);
      if (response.statusCode != 200) {
        Get.snackbar(
          'Gagal',
          jsonBody['error'] ?? 'Gagal mengecek status pembayaran',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
        return;
      }

      final ticketStatus = (jsonBody['ticket_status'] ?? '').toString();
      final rawTicket = jsonBody['ticket'];

      if (ticketStatus == 'paid' && rawTicket is Map<String, dynamic>) {
        Get.off(
          () => ETicketScreen(ticket: TicketModel.fromJson(rawTicket)),
          transition: Transition.rightToLeft,
        );
        return;
      }

      Get.snackbar(
        'Status Pembayaran',
        _statusMessage(ticketStatus),
        backgroundColor: const Color(0xFF1D4F44),
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
      if (mounted) setState(() => _isChecking = false);
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'paid':
        return 'Pembayaran berhasil';
      case 'expired':
        return 'Pembayaran kedaluwarsa';
      case 'cancelled':
        return 'Pembayaran dibatalkan';
      case 'pending':
      default:
        return 'Menunggu pembayaran';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pembayaran'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color(0xFF1D4F44),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Midtrans Snap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _infoRow('Ticket', widget.ticketId),
                  if (widget.snapToken != null && widget.snapToken!.isNotEmpty)
                    _infoRow('Snap Token', widget.snapToken!),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isOpening ? null : _openPaymentUrl,
                icon: _isOpening
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.open_in_browser),
                label: Text(
                  _isOpening
                      ? 'Membuka Pembayaran...'
                      : 'Buka Halaman Pembayaran',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4F44),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isChecking ? null : _checkPaymentStatus,
                icon: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  _isChecking ? 'Mengecek Status...' : 'Cek Status Pembayaran',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1D4F44),
                  side: const BorderSide(color: Color(0xFF1D4F44)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
