import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/booking_controller.dart';
import '../controller/hiking_route_controller.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late BookingController controller;
  late HikingRouteController routeController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BookingController>()) {
      Get.delete<BookingController>();
    }
    controller = Get.put(BookingController());
    controller.resetForm();
    routeController = Get.isRegistered<HikingRouteController>()
        ? Get.find<HikingRouteController>()
        : Get.put(HikingRouteController(), permanent: true);
    routeController.fetchRoutes();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      controller.selectRoute(
        args['route_id'] as int,
        args['route_name'] as String,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id');
    final rupiahFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Booking Pendakian'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color(0xFF1D4F44),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info Gunung ──
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gunung Sumbing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Magelang, Jawa Tengah · 3.371 mdpl',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Pilih Jalur ──
              _sectionLabel('Jalur Pendakian'),
              const SizedBox(height: 12),

              _buildRouteSelector(),

              const SizedBox(height: 20),

              // ── Detail Pemesanan ──
              _sectionLabel('Detail Pemesanan'),
              const SizedBox(height: 12),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF1D4F44),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    controller.hikingDate.value = picked;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.hikingDate.value == null
                            ? 'Pilih tanggal pendakian'
                            : dateFormat.format(controller.hikingDate.value!),
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.hikingDate.value == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF1D4F44),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Jumlah Anggota (total_members)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Anggota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rp 35.000 / orang',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  _counterWidget(
                    value: controller.totalMembers.value,
                    onDecrement: () {
                      if (controller.totalMembers.value > 1) {
                        controller.totalMembers.value--;
                        if (controller.ojekCount.value >
                            controller.totalMembers.value) {
                          controller.ojekCount.value =
                              controller.totalMembers.value;
                        }
                      }
                    },
                    onIncrement: () => controller.totalMembers.value++,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Tambah Layanan Ojek',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Rp 50.000 / orang  ·  Basecamp → Pos 1',
                  style: TextStyle(fontSize: 12),
                ),
                value: controller.includeOjek.value,
                activeColor: const Color(0xFF1D4F44),
                onChanged: (val) {
                  controller.includeOjek.value = val!;
                  if (!val) controller.ojekCount.value = 0;
                },
              ),

              if (controller.includeOjek.value) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah Ojek', style: TextStyle(fontSize: 15)),
                    _counterWidget(
                      value: controller.ojekCount.value,
                      onDecrement: () {
                        if (controller.ojekCount.value > 0) {
                          controller.ojekCount.value--;
                        }
                      },
                      onIncrement: () {
                        if (controller.ojekCount.value <
                            controller.totalMembers.value) {
                          controller.ojekCount.value++;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4F44).withValues(alpha: 0.06),
                  border: Border.all(
                    color: const Color(0xFF1D4F44).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _priceRow(
                      'Booking (${controller.totalMembers.value} orang)',
                      controller.totalMembers.value * controller.pricePerPerson,
                      rupiahFormat,
                    ),
                    if (controller.includeOjek.value &&
                        controller.ojekCount.value > 0)
                      _priceRow(
                        'Ojek (${controller.ojekCount.value} orang)',
                        controller.ojekCount.value * controller.pricePerOjek,
                        rupiahFormat,
                      ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          rupiahFormat.format(controller.totalPrice.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1D4F44),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.submitBooking(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4F44),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Pesan Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRouteSelector() {
    if (routeController.isLoading.value && routeController.routes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Memuat status jalur...'),
          ],
        ),
      );
    }

    if (routeController.errorMessage.value.isNotEmpty &&
        routeController.routes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red.withValues(alpha: 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routeController.errorMessage.value,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: routeController.fetchRoutes,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (routeController.routes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Belum ada data jalur pendakian.'),
      );
    }

    final selectedRouteId = controller.selectedRouteId.value;
    final selectedValue =
        routeController.routes.any((route) => route.id == selectedRouteId)
        ? selectedRouteId
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(
            controller.selectedRouteName.value.isEmpty
                ? 'Pilih jalur pendakian'
                : controller.selectedRouteName.value,
          ),
          items: routeController.routes
              .map(
                (route) => DropdownMenuItem<int>(
                  value: route.id,
                  enabled: route.isOpen,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          route.routeName,
                          style: TextStyle(
                            color: route.isOpen ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      if (!route.isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Ditutup',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              final route = routeController.findById(val);
              if (route == null) return;

              if (!route.isOpen) {
                Get.snackbar(
                  'Jalur ditutup',
                  route.closedReason.isEmpty
                      ? '${route.routeName} sedang ditutup.'
                      : route.closedReason,
                  backgroundColor: Colors.red[400],
                  colorText: Colors.white,
                );
                return;
              }

              controller.selectRoute(route.id, route.routeName);
            }
          },
        ),
      ),
    );
  }

  Widget _counterWidget({
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Color(0xFF1D4F44),
          ),
        ),
        Text('$value', style: const TextStyle(fontSize: 16)),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1D4F44)),
        ),
      ],
    );
  }

  Widget _priceRow(String label, int amount, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(fmt.format(amount)),
        ],
      ),
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
}
