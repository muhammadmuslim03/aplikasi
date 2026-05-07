import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../model/hiking_route_model.dart';

class HikingRouteController extends GetxController {
  final routes = <HikingRouteModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final String baseUrl = 'http://10.100.229.109:8080';

  bool get hasOpenRoutes => routes.any((route) => route.isOpen);

  HikingRouteModel? findById(int id) {
    try {
      return routes.firstWhere((route) => route.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchRoutes() async {
    final token = GetStorage().read('token')?.toString().trim();

    if (token == null || token.isEmpty) {
      routes.clear();
      isLoading.value = false;
      errorMessage.value = 'Token tidak ditemukan. Silakan login ulang.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/hiking-routes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        final rawRoutes = decoded is List
            ? decoded
            : decoded is Map<String, dynamic>
            ? decoded['data'] ?? []
            : [];

        routes.assignAll(
          (rawRoutes as List)
              .map((item) => HikingRouteModel.fromJson(item))
              .toList(),
        );
        return;
      }

      errorMessage.value = decoded is Map<String, dynamic>
          ? decoded['error']?.toString() ?? 'Gagal memuat jalur pendakian'
          : 'Gagal memuat jalur pendakian';
    } catch (e) {
      errorMessage.value = 'Tidak dapat terhubung ke server: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
