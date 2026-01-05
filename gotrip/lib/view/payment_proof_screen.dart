import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controller/payment_controller.dart';
import '../model/payment_model.dart';

class PaymentProofScreen extends StatelessWidget {
  final PaymentModel paymentData;
  const PaymentProofScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentController()..setPayment(paymentData),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Upload Bukti Pembayaran'),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          backgroundColor: const Color(0xFF1D4F44),
        ),
        body: Consumer<PaymentController>(
          builder: (context, controller, _) {
            final payment = controller.payment;
            if (payment == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final formattedTotal = NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(payment.total ?? 0);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nama: ${payment.name}"),
                        Text("Email: ${payment.email}"),
                        Text("Telepon: ${payment.telepon}"),
                        Text(
                          "Tanggal: ${DateFormat('dd MMMM yyyy').format(payment.date)}",
                        ), // Tampilkan tanggal
                        Text("Total: $formattedTotal"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Metode Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: [
                      _buildRadioOption(
                        controller,
                        label: 'BCA',
                        account: '513-301-6782 a.n Muhammad Muslim',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  if (controller.selectedMethod != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Silakan transfer ke akun ${controller.selectedMethod}: '
                        '\n${controller.selectedAccount}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                  const SizedBox(height: 30),
                  const Text(
                    'Upload Bukti Transfer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () => controller.pickProofImage(),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: controller.proofImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                controller.proofImageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => controller.confirmPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4F44),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Kirim'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    PaymentController controller, {
    required String label,
    required String account,
  }) {
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: controller.selectedMethod,
      onChanged: (value) {
        controller.selectPaymentMethod(value!, account);
      },
      activeColor: const Color(0xFF1D4F44),
    );
  }
}
