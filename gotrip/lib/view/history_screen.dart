import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/history_controller.dart';
import '../model/ticket_model.dart';
import 'eticket_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());
    final dateFormat = DateFormat('dd MMM yyyy', 'id');
    final rupiahFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Booking Saya'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color(0xFF1D4F44),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => _refreshHistory(controller),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1D4F44)),
          );
        }

        if (controller.historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada booking',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _refreshHistory(controller),
                  child: const Text('Muat Ulang'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1D4F44),
          onRefresh: () => _refreshHistory(controller),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.historyList.length,
            itemBuilder: (context, index) {
              final ticket = controller.historyList[index];
              return _buildTicketCard(
                controller,
                ticket,
                dateFormat,
                rupiahFormat,
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _refreshHistory(HistoryController controller) async {
    final dynamic dynamicController = controller;
    try {
      await dynamicController.fetchHistory();
    } catch (_) {}
  }

  Widget _buildTicketCard(
    HistoryController controller,
    TicketModel ticket,
    DateFormat dateFormat,
    NumberFormat rupiahFormat,
  ) {
    final statusInfo = _statusInfo(ticket.status);
    final bool isCancelled = ticket.status == 'cancelled';
    final bool isRejected =
        ticket.rejectNote != null && ticket.rejectNote!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.07),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusInfo['color'] as Color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.routeName ?? 'Jalur tidak diketahui',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusInfo['label'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#${ticket.id.length > 8 ? ticket.id.substring(0, 8).toUpperCase() : ticket.id}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _detailRow(
                  Icons.calendar_today,
                  'Tanggal Pendakian',
                  dateFormat.format(ticket.hikingDate),
                ),
                const SizedBox(height: 8),
                _detailRow(
                  Icons.group,
                  'Jumlah Anggota',
                  '${ticket.totalMembers} orang',
                ),
                if (ticket.includeOjek) ...[
                  const SizedBox(height: 8),
                  _detailRow(
                    Icons.electric_moped,
                    'Layanan Ojek',
                    '${ticket.ojekCount} orang',
                  ),
                ],
                _detailRow(Icons.terrain, 'Jalur', ticket.routeName ?? '-'),
                const SizedBox(height: 8),
                _detailRow(
                  Icons.payments_outlined,
                  'Total Bayar',
                  rupiahFormat.format(ticket.totalPrice),
                  isHighlight: true,
                ),

                const SizedBox(height: 14),
                _ticketAction(controller, ticket),

                if (isRejected) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Admin:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.rejectNote!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (ticket.qrCodeData != null &&
                    ticket.qrCodeData!.isNotEmpty &&
                    !isCancelled) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'QR Code Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.qr_code_2,
                              size: 80,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tunjukkan saat check-in',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Tanggal booking
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 6),
                Text(
                  'Dipesan pada ${dateFormat.format(ticket.bookingDate)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1D4F44)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? const Color(0xFF1D4F44) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ticketAction(HistoryController controller, TicketModel ticket) {
    final status = ticket.status.toLowerCase();

    if (status == 'pending') {
      return Obx(() {
        final isProcessing = controller.processingTicketId.value == ticket.id;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessing
                ? null
                : () => controller.continuePayment(ticket),
            icon: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.payment, size: 18),
            label: Text(
              isProcessing ? 'Membuat Pembayaran...' : 'Lanjutkan Pembayaran',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4F44),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      });
    }

    if (status == 'paid') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Get.to(
            () => ETicketScreen(ticket: ticket),
            transition: Transition.rightToLeft,
          ),
          icon: const Icon(Icons.qr_code_2, size: 18),
          label: const Text('Lihat E-Ticket'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1D4F44),
            side: const BorderSide(color: Color(0xFF1D4F44)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    if (status == 'expired') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.timer_off_outlined, size: 18),
          label: const Text('Pembayaran Kedaluwarsa'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Map<String, dynamic> _statusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return {'label': 'Sudah Dibayar', 'color': Colors.green[600]!};
      case 'expired':
        return {'label': 'Kedaluwarsa', 'color': Colors.grey[600]!};
      case 'checked_in':
        return {'label': 'Check In', 'color': Colors.blue[600]!};
      case 'checked_out':
        return {'label': 'Selesai', 'color': Colors.teal[600]!};
      case 'cancelled':
        return {'label': 'Dibatalkan', 'color': Colors.red[400]!};
      case 'waiting_verification':
        return {'label': 'Menunggu Verifikasi', 'color': Colors.orange[600]!};
      case 'pending':
      default:
        return {'label': 'Menunggu Pembayaran', 'color': Colors.orange[600]!};
    }
  }
}
