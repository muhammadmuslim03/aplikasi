import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/booking_controller.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late BookingController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BookingController>()) {
      Get.delete<BookingController>();
    }
    controller = Get.put(BookingController());
    controller.resetForm();

    // Jika dipanggil dari HomeScreen dengan argument route
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

              // Dropdown jalur (route_id dari hiking_routes)
              _buildRouteSelector(),

              const SizedBox(height: 20),

              // ── Detail Pemesanan ──
              _sectionLabel('Detail Pemesanan'),
              const SizedBox(height: 12),

              // Pilih Tanggal Pendakian (hiking_date)
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

              // Tambah layanan ojek yang disimpan di tabel bookings
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
                  color: const Color(0xFF1D4F44).withOpacity(0.06),
                  border: Border.all(
                    color: const Color(0xFF1D4F44).withOpacity(0.3),
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

              // ── Tombol Pesan ──
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
    final List<Map<String, dynamic>> routes = [
      {'id': 1, 'route_name': 'Jalur Garung'},
      {'id': 2, 'route_name': 'Jalur Bowongso'},
      {'id': 3, 'route_name': 'Jalur Kaliangkrik'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: controller.selectedRouteId.value == 0
              ? null
              : controller.selectedRouteId.value,
          hint: const Text('Pilih jalur pendakian'),
          items: routes
              .map(
                (r) => DropdownMenuItem<int>(
                  value: r['id'] as int,
                  child: Text(r['route_name']),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              final route = routes.firstWhere((r) => r['id'] == val);
              controller.selectRoute(val, route['route_name']);
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
