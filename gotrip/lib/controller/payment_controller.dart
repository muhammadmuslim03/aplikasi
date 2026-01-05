import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../model/payment_model.dart';
import '../controller/history_controller.dart';
import '../view/bottomnavigation.dart';

class PaymentController extends ChangeNotifier {
  PaymentModel? payment;

  String? selectedMethod;
  String? selectedAccount;

  final ImagePicker _picker = ImagePicker();
  final box = GetStorage();

  Uint8List? proofImageBytes;
  String? proofImageFileName;

  // ================= SET DATA =================
  void setPayment(PaymentModel data) {
    payment = data;
    notifyListeners();
  }

  void selectPaymentMethod(String method, String account) {
    selectedMethod = method;
    selectedAccount = account;
    notifyListeners();
  }

  // ================= PICK IMAGE =================
  Future<void> pickProofImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        proofImageBytes = await image.readAsBytes();
        proofImageFileName = image.name;

        payment = (payment ?? PaymentModel(date: DateTime.now())).copyWith(
          proofImagePath: "local-preview",
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error pilih gambar: $e");
    }
  }

  // ================= SEND BOOKING =================
  Future<bool> sendBooking(BuildContext context, PaymentModel data) async {
    final token = box.read("token");
    const String apiUrl = "http://10.246.143.109:8080/api/pendaki/booking";

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan, login ulang.")),
      );
      return false;
    }

    if (proofImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bukti pembayaran diperlukan.")),
      );
      return false;
    }

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.headers["Authorization"] = "Bearer $token";

      request.fields["nama"] = data.name;
      request.fields["email"] = data.email;
      request.fields["telepon"] = data.telepon;
      request.fields["darurat"] = data.darurat ?? "-";
      request.fields["tanggal"] = DateFormat("yyyy-MM-dd").format(data.date);
      request.fields["jumlah_orang"] = data.jumlahOrang.toString();
      request.fields["jumlah_ojek"] = data.jumlahOjek.toString();
      request.fields["termasuk_ojek"] = data.termasukOjek.toString();
      request.fields["total_harga"] = data.total!.toInt().toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          "proof_image",
          proofImageBytes!,
          filename: proofImageFileName,
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
      return false;
    }
  }

  // ================= CONFIRM PAYMENT =================
  Future<void> confirmPayment(BuildContext context) async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih metode pembayaran dulu.")),
      );
      return;
    }

    if (proofImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload bukti pembayaran dulu.")),
      );
      return;
    }

    if (payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data pembayaran tidak ditemukan.")),
      );
      return;
    }

    final success = await sendBooking(context, payment!);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan ke server.")),
      );
      return;
    }

    // 🔄 Refresh history TANPA navigasi
    if (Get.isRegistered<BookingHistoryController>()) {
      await Get.find<BookingHistoryController>().fetchHistory();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pembayaran berhasil dikonfirmasi!")),
    );

    Get.offAll(() => Bottomnavigation(initialIndex: 0));
  }
}
