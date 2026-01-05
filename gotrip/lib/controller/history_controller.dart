import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../model/history_model.dart';

class BookingHistoryController extends GetxController {
  final historyList = <BookingHistoryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;

    final token = GetStorage().read('token');
    if (token == null) {
      historyList.clear();
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.246.143.109:8080/api/pendaki/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody['history'] ?? [];

        historyList.assignAll(
          data.map((e) => BookingHistoryModel.fromJson(e)).toList(),
        );
      } else {
        Get.snackbar("Error", "Gagal memuat riwayat pemesanan");
      }
    } catch (e) {
      Get.snackbar("Error", "Kesalahan koneksi: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
