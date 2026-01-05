import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/booking_controller.dart';
import '../model/payment_model.dart';
import 'payment_proof_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late BookingController controller;

  final int hargaPerOrang = 35000;
  final int hargaOjek = 50000;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<BookingController>()) {
      Get.delete<BookingController>();
    }

    controller = Get.put(BookingController());
    controller.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pemesanan Tiket'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF1D4F44),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

        child: Obx(() {
          final totalHarga = _hitungTotal();
          final formattedTotal = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(totalHarga);

          return Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4F44), Color(0xFF2D5F54)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gunung Sumbing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Via Kaliangkrik',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Magelang, Jawa Tengah',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Informasi Pribadi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: controller.namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: controller.teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: controller.daruratController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Darurat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning_amber_rounded),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Detail Pemesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.tanggalPendakian.value = picked;
                    }
                  },
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.tanggalPendakian.value == null
                                ? 'Pilih tanggal pendakian'
                                : DateFormat(
                                    "dd-MM-yyyy",
                                  ).format(controller.tanggalPendakian.value!),
                            style: TextStyle(
                              fontSize: 16,
                              color: controller.tanggalPendakian.value == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Orang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (controller.jumlahOrang.value > 1) {
                                controller.jumlahOrang.value--;
                                if (controller.jumlahOjek.value >
                                    controller.jumlahOrang.value) {
                                  controller.jumlahOjek.value =
                                      controller.jumlahOrang.value;
                                }
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '${controller.jumlahOrang.value}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () => controller.jumlahOrang.value++,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Obx(
                  () => CheckboxListTile(
                    title: const Text('Termasuk Ojek'),
                    value: controller.termasukOjek.value,
                    onChanged: (val) => controller.termasukOjek.value = val!,
                  ),
                ),

                Obx(
                  () => controller.termasukOjek.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jumlah Ojek',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (controller.jumlahOjek.value > 0) {
                                      controller.jumlahOjek.value--;
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '${controller.jumlahOjek.value}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (controller.jumlahOjek.value <
                                        controller.jumlahOrang.value) {
                                      controller.jumlahOjek.value++;
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: $formattedTotal',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (!controller.formKey.currentState!.validate()) return;

                    if (controller.tanggalPendakian.value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tanggal pendakian wajib dipilih."),
                        ),
                      );
                      return;
                    }

                    final payment = PaymentModel(
                      name: controller.namaController.text.trim(),
                      email: controller.emailController.text.trim(),
                      telepon: controller.teleponController.text.trim(),
                      darurat: controller.daruratController.text.trim(),
                      date: controller.tanggalPendakian.value!,
                      jumlahOrang: controller.jumlahOrang.value,
                      jumlahOjek: controller.jumlahOjek.value,
                      termasukOjek: controller.termasukOjek.value,
                      total: totalHarga.toDouble(),
                    );

                    Get.to(() => PaymentProofScreen(paymentData: payment));
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4F44),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lanjutkan Pemesanan'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  int _hitungTotal() {
    int total = controller.jumlahOrang.value * hargaPerOrang;
    if (controller.termasukOjek.value) {
      total += controller.jumlahOjek.value * hargaOjek;
    }
    return total;
  }
}
