import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controller/news_controller.dart';
import 'booking_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final NewsController newsController = Get.put(NewsController());

  final List<Map<String, dynamic>> routes = [
    {
      'id': 1,
      'route_name': 'Jalur Garung',
      'description': 'Jalur paling populer, cocok untuk pendaki pemula',
      'is_open': true,
    },
    {
      'id': 2,
      'route_name': 'Jalur Bowongso',
      'description': 'Jalur menantang dengan pemandangan indah',
      'is_open': true,
    },
    {
      'id': 3,
      'route_name': 'Jalur Kaliangkrik',
      'description': 'Jalur alternatif yang lebih sepi',
      'is_open': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Ambil nama dari storage (hasil login)
    final String userName = GetStorage().read('name') ?? 'Pendaki';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('GoTrip'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF1D4F44),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ──
            _buildHeroBanner(userName),

            const SizedBox(height: 24),

            // ── Jalur Pendakian ──
            _sectionHeader('Jalur Pendakian', null),
            const SizedBox(height: 12),
            _buildRouteList(),

            const SizedBox(height: 24),

            // ── Berita Terkini ──
            _sectionHeader('Berita Terkini', () => Get.to(const NewsScreen())),
            const SizedBox(height: 12),
            _buildNewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4F44), Color(0xFF2A6B5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4F44).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $userName!',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selamat Datang Kembali',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunung Sumbing 3.371 mdpl',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => BookingScreen()),
            icon: const Icon(Icons.confirmation_number_outlined, size: 18),
            label: const Text(
              'Pesan Booking',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1D4F44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(color: Color(0xFF1D4F44)),
            ),
          ),
      ],
    );
  }

  Widget _buildRouteList() {
    return Column(
      children: routes.map((route) {
        final bool isOpen = route['is_open'] as bool;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1D4F44).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.terrain, color: Color(0xFF1D4F44)),
            ),
            title: Text(
              route['route_name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  route['description'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOpen ? 'Jalur Terbuka' : 'Jalur Ditutup',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOpen ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            trailing: isOpen
                ? const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  )
                : null,
            onTap: isOpen
                ? () => Get.to(
                    () => BookingScreen(),
                    arguments: {
                      'route_id': route['id'],
                      'route_name': route['route_name'],
                    },
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNewsList() {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');

    return Obx(
      () => Column(
        children: newsController.newsList.take(3).map((berita) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  berita.title,
                  'Buka detail berita',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      berita.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berita.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(berita.date),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            berita.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
