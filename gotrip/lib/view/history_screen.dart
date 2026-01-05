import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/history_controller.dart';
import '../model/history_model.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final controller = Get.find<BookingHistoryController>();

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Riwayat Pemesanan"),
        backgroundColor: const Color(0xFF1D4F44),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyList.isEmpty) {
          return const Center(child: Text("Belum ada riwayat pemesanan."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.historyList.length,
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            return _buildTicket(item, rupiah);
          },
        );
      }),
    );
  }

  Widget _buildTicket(BookingHistoryModel item, NumberFormat rupiah) {
    final isRejected = item.status.toLowerCase() == 'ditolak';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.nama,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text("Tanggal: ${item.tanggal}"),
          Text("Jumlah Orang: ${item.jumlahOrang}"),
          Text("Jumlah Ojek: ${item.jumlahOjek}"),
          Text("Total: ${rupiah.format(item.totalHarga)}"),
          const SizedBox(height: 6),
          Text(
            item.status,
            style: TextStyle(
              color: _statusColor(item.status),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRejected && item.rejectNote.isNotEmpty) ...[
            const Divider(),
            Text(
              "Alasan Ditolak:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(item.rejectNote),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case "success":
    case "approved":
    case "lunas":
      return Colors.green;
    case "pending":
      return Colors.orange;
    case "rejected":
    case "ditolak":
      return Colors.red;
    default:
      return Colors.grey;
  }
}
