import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../model/ticket_model.dart';

class ETicketScreen extends StatelessWidget {
  final TicketModel ticket;

  const ETicketScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id');
    final rupiahFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isPaid = ticket.status.toLowerCase() == 'paid';
    final qrData = ticket.qrCodeData ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text('E-Ticket'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color(0xFF1D4F44),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GOTRIP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _statusBadge(isPaid),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow('Jalur', ticket.routeName ?? '-'),
              _infoRow(
                'Tanggal Pendakian',
                dateFormat.format(ticket.hikingDate),
              ),
              _infoRow('Jumlah Pendaki', '${ticket.totalMembers} orang'),
              _infoRow(
                'Total Pembayaran',
                rupiahFormat.format(ticket.totalPrice),
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 18),
              Center(
                child: isPaid && qrData.isNotEmpty
                    ? QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 56,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPaid
                                ? 'QR Code belum tersedia'
                                : 'Tiket belum dapat digunakan',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
              ),
              if (isPaid && qrData.isNotEmpty) ...[
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Tunjukkan saat check-in',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPaid ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Text(
        isPaid ? 'Sudah Dibayar' : 'Belum Dibayar',
        style: TextStyle(
          color: isPaid ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
