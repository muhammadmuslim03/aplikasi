import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/payment_controller.dart';
import '../model/payment_model.dart';

class PaymentProofScreen extends StatelessWidget {
  final PaymentModel paymentData;

  const PaymentProofScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());
    controller.setPayment(paymentData);

    final dateFormat = DateFormat('dd MMMM yyyy', 'id');
    final rupiahFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Upload Bukti Pembayaran'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color(0xFF1D4F44),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final p = controller.payment.value;
        if (p == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan booking
              _sectionLabel('Ringkasan Pemesanan'),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.terrain, 'Jalur', p.routeName),
                    _divider(),
                    _infoRow(
                      Icons.calendar_today,
                      'Tanggal Pendakian',
                      dateFormat.format(p.hikingDate),
                    ),
                    _divider(),
                    _infoRow(
                      Icons.group,
                      'Jumlah Anggota',
                      '${p.totalMembers} orang',
                    ),
                    if (p.includeOjek) ...[
                      _divider(),
                      _infoRow(
                        Icons.electric_moped,
                        'Layanan Ojek',
                        '${p.ojekCount} orang',
                      ),
                    ],
                    _divider(),
                    _infoRow(
                      Icons.receipt_long,
                      'No. Booking',
                      // Tampilkan 8 karakter pertama UUID saja
                      p.ticketId.length > 8
                          ? '#${p.ticketId.substring(0, 8).toUpperCase()}'
                          : '#${p.ticketId}',
                      isHighlight: false,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.payments_outlined,
                      'Total Pembayaran',
                      rupiahFormat.format(p.totalPrice),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Pilih Metode Pembayaran ──
              _sectionLabel('Metode Pembayaran'),
              const SizedBox(height: 12),

              ...controller.paymentMethods.map((method) {
                return Obx(
                  () => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      method['label']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      method['account']!,
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: method['label']!,
                    groupValue: controller.selectedMethod.value.isEmpty
                        ? null
                        : controller.selectedMethod.value,
                    activeColor: const Color(0xFF1D4F44),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectPaymentMethod(val, method['account']!);
                      }
                    },
                  ),
                );
              }),

              // Info transfer setelah pilih metode
              Obx(() {
                if (controller.selectedMethod.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Transfer ke ${controller.selectedMethod.value}:\n'
                          '${controller.selectedAccount.value}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ── Upload Bukti Transfer ──
              _sectionLabel('Bukti Transfer'),
              const SizedBox(height: 12),

              Obx(
                () => GestureDetector(
                  onTap: () => controller.pickProofImage(),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.proofImageBytes.value != null
                            ? const Color(0xFF1D4F44)
                            : Colors.grey.shade400,
                        width: controller.proofImageBytes.value != null ? 2 : 1,
                      ),
                    ),
                    child: controller.proofImageBytes.value != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.memory(
                                  controller.proofImageBytes.value!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              // Tombol ganti foto
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ganti Foto',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk pilih foto',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Format: JPG, PNG (maks. 5MB)',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Tombol Kirim ──
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isUploading.value
                        ? null
                        : () => controller.confirmPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4F44),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF1D4F44,
                      ).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: controller.isUploading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Kirim Bukti Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Catatan
              Center(
                child: Text(
                  'Pembayaran akan diverifikasi oleh admin dalam 1×24 jam',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1D4F44),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D4F44),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1D4F44)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? const Color(0xFF1D4F44) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}
