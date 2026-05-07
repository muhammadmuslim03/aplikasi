import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/payment_model.dart';
import '../model/ticket_model.dart';
import '../view/payment_proof_screen.dart';
import 'hiking_route_controller.dart';

class BookingController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Rx<DateTime?> hikingDate = Rx<DateTime?>(null);
  RxInt totalMembers = 1.obs;

  RxBool includeOjek = false.obs;
  RxInt ojekCount = 0.obs;

  RxInt selectedRouteId = 0.obs;
  RxString selectedRouteName = ''.obs;

  RxBool isLoading = false.obs;
  RxList<TicketModel> historyList = <TicketModel>[].obs;

  final int pricePerPerson = 35000;
  final int pricePerOjek = 50000;

  RxInt totalPrice = 0.obs;

  final NumberFormat rupiah = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final String baseUrl = 'http://10.100.229.109:8080';

  @override
  void onInit() {
    super.onInit();

    _recalcTotal();

    everAll([totalMembers, includeOjek, ojekCount], (_) {
      _recalcTotal();
    });

    fetchHistory();
  }

  void _recalcTotal() {
    int total = totalMembers.value * pricePerPerson;

    if (includeOjek.value && ojekCount.value > 0) {
      total += ojekCount.value * pricePerOjek;
    }

    totalPrice.value = total;
  }

  void resetForm() {
    hikingDate.value = null;
    totalMembers.value = 1;
    includeOjek.value = false;
    ojekCount.value = 0;
    selectedRouteId.value = 0;
    selectedRouteName.value = '';
    _recalcTotal();
  }

  void selectRoute(int id, String name) {
    selectedRouteId.value = id;
    selectedRouteName.value = name;
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;

    final token = GetStorage().read('token')?.toString().trim();

    if (token == null || token.isEmpty) {
      historyList.clear();
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        historyList.value = (data as List)
            .map((e) => TicketModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar(
          'Error',
          'Gagal mengambil data booking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitBooking() async {
    // VALIDASI
    if (hikingDate.value == null) {
      Get.snackbar(
        'Gagal',
        'Tanggal pendakian belum dipilih',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRouteId.value == 0) {
      Get.snackbar(
        'Gagal',
        'Jalur pendakian belum dipilih',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (Get.isRegistered<HikingRouteController>()) {
      final routeController = Get.find<HikingRouteController>();
      final selectedRoute = routeController.findById(selectedRouteId.value);

      if (selectedRoute != null && !selectedRoute.isOpen) {
        Get.snackbar(
          'Gagal',
          selectedRoute.closedReason.isEmpty
              ? 'Jalur pendakian sedang ditutup'
              : selectedRoute.closedReason,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    final token = GetStorage().read('token')?.toString().trim();

    if (token == null || token.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Token tidak ditemukan. Silakan login ulang.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      if (includeOjek.value && ojekCount.value == 0) {
        ojekCount.value = 1;
      }

      final bool validOjek = includeOjek.value && ojekCount.value > 0;

      final bodyMap = {
        'route_id': selectedRouteId.value,
        'hiking_date': hikingDate.value!.toIso8601String().split('T').first,
        'total_members': totalMembers.value,
        'total_price': totalPrice.value,
        'include_ojek': validOjek,
        'ojek_count': validOjek ? ojekCount.value : 0,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final err = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          err['error'] ?? 'Gagal membuat booking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final ticketData = jsonDecode(response.body);
      final String ticketId = ticketData['id'];

      final paymentData = PaymentModel(
        ticketId: ticketId,
        routeId: selectedRouteId.value,
        routeName: selectedRouteName.value,
        hikingDate: hikingDate.value!,
        totalMembers: totalMembers.value,
        totalPrice: totalPrice.value.toDouble(),
        includeOjek: validOjek,
        ojekCount: validOjek ? ojekCount.value : 0,
      );

      Get.to(
        () => PaymentProofScreen(paymentData: paymentData),
        transition: Transition.rightToLeft,
      );

      await fetchHistory();

      Get.snackbar(
        'Sukses',
        'Booking berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
