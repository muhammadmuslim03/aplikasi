import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class BookingController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final teleponController = TextEditingController();
  final daruratController = TextEditingController();

  Rx<DateTime?> tanggalPendakian = Rx<DateTime?>(null);
  RxInt jumlahOrang = 1.obs;
  RxBool termasukOjek = false.obs;
  RxInt jumlahOjek = 0.obs;

  final int hargaPerOrang = 35000;
  final int hargaPerOjek = 50000;

  final NumberFormat rupiah = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  RxInt totalHarga = 0.obs;

  @override
  void onInit() {
    super.onInit();
    hitungTotal();
    everAll([jumlahOrang, termasukOjek, jumlahOjek], (_) => hitungTotal());
  }

  @override
  void onReady() {
    super.onReady();
    resetForm();
  }

  void resetForm() {
    namaController.clear();
    emailController.clear();
    teleponController.clear();
    daruratController.clear();

    tanggalPendakian.value = null;
    jumlahOrang.value = 1;
    termasukOjek.value = false;
    jumlahOjek.value = 0;

    hitungTotal();
  }

  void hitungTotal() {
    int total = jumlahOrang.value * hargaPerOrang;
    if (termasukOjek.value) {
      total += jumlahOjek.value * hargaPerOjek;
    }
    totalHarga.value = total;
  }

  Future<void> createBooking() async {
    final tanggal = tanggalPendakian.value;

    if (tanggal == null) {
      Get.snackbar("Error", "Tanggal pendakian belum dipilih");
      return;
    }

    final body = jsonEncode({
      "nama": namaController.text,
      "email": emailController.text,
      "telepon": teleponController.text,
      "darurat": daruratController.text,
      "tanggal": tanggal.toIso8601String().split("T").first,
      "jumlah_orang": jumlahOrang.value,
      "jumlah_ojek": jumlahOjek.value,
      "termasuk_ojek": termasukOjek.value,
      "total_harga": totalHarga.value,
    });

    final response = await http.post(
      Uri.parse("http://10.246.143.109:8080/api/pendaki/booking"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${GetStorage().read('token')}",
      },
      body: body,
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Berhasil", "Pemesanan berhasil dikirim!");
      resetForm();
    } else {
      Get.snackbar("Gagal", "Terjadi kesalahan saat mengirim data.");
    }
  }

  void submitForm(BuildContext context) {
    if (formKey.currentState!.validate()) {
      createBooking();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pemesanan berhasil! Total: ${rupiah.format(totalHarga.value)}',
          ),
        ),
      );
    }
  }
}
