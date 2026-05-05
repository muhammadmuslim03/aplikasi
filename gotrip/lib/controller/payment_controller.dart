import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../model/payment_model.dart';

class PaymentController extends GetxController {
  Rx<PaymentModel?> payment = Rx<PaymentModel?>(null);

  RxString selectedMethod = ''.obs;
  RxString selectedAccount = ''.obs;
  Rx<Uint8List?> proofImageBytes = Rx<Uint8List?>(null);
  RxString proofImageFileName = ''.obs;
  RxBool isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();
  final String baseUrl = 'http://192.168.88.191:8080';

  final List<Map<String, String>> paymentMethods = [
    {'label': 'BCA', 'account': '513-301-6782 a.n Muhammad Muslim'},
    {'label': 'Mandiri', 'account': '123-456-7890 a.n Muhammad Muslim'},
  ];

  void setPayment(PaymentModel data) {
    payment.value = data;
    selectedMethod.value = '';
    selectedAccount.value = '';
    proofImageBytes.value = null;
    proofImageFileName.value = '';
  }

  void selectPaymentMethod(String method, String account) {
    selectedMethod.value = method;
    selectedAccount.value = account;
  }

  Future<void> pickProofImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        proofImageBytes.value = await image.readAsBytes();
        proofImageFileName.value = image.name;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: ${e.toString()}',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _uploadProof() async {
    final token = GetStorage().read('token');
    final ticketId = payment.value?.ticketId;

    if (token == null || ticketId == null || ticketId.isEmpty) {
      Get.snackbar(
        'Error',
        'Data booking tidak ditemukan.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return false;
    }

    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/bookings/$ticketId/proof'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['payment_method'] = selectedMethod.value;

      request.files.add(
        http.MultipartFile.fromBytes(
          'proof_image',
          proofImageBytes.value!,
          filename: proofImageFileName.value,
        ),
      );

      final response = await request.send();

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upload: ${e.toString()}',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> confirmPayment() async {
    if (selectedMethod.value.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Pilih metode pembayaran terlebih dahulu.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    if (proofImageBytes.value == null) {
      Get.snackbar(
        'Gagal',
        'Upload bukti pembayaran terlebih dahulu.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;

    final success = await _uploadProof();

    isUploading.value = false;

    if (success) {
      Get.snackbar(
        'Berhasil',
        'Bukti pembayaran dikirim, menunggu verifikasi.',
        backgroundColor: const Color(0xFF1D4F44),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(seconds: 2));

      Get.offAllNamed('/home', arguments: {'tab': 1});
    }
  }
}
