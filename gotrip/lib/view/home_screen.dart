import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controller/hiking_route_controller.dart';
import '../controller/news_controller.dart';
import 'booking_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NewsController newsController;
  late final HikingRouteController routeController;

  @override
  void initState() {
    super.initState();
    newsController = Get.put(NewsController());
    routeController = Get.isRegistered<HikingRouteController>()
        ? Get.find<HikingRouteController>()
        : Get.put(HikingRouteController(), permanent: true);
    routeController.fetchRoutes();
  }

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
      body: Obx(
        () => RefreshIndicator(
          onRefresh: routeController.fetchRoutes,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ──
                _buildHeroBanner(userName, routeController.hasOpenRoutes),

                const SizedBox(height: 24),

                // ── Jalur Pendakian ──
                _sectionHeader('Jalur Pendakian', null),
                const SizedBox(height: 12),
                _buildRouteList(),

                const SizedBox(height: 24),

                // ── Berita Terkini ──
                _sectionHeader(
                  'Berita Terkini',
                  () => Get.to(const NewsScreen()),
                ),
                const SizedBox(height: 12),
                _buildNewsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(String userName, bool hasOpenRoutes) {
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
            color: const Color(0xFF1D4F44).withValues(alpha: 0.4),
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
            onPressed: routeController.isLoading.value
                ? null
                : () {
                    if (!hasOpenRoutes) {
                      Get.snackbar(
                        'Jalur ditutup',
                        'Belum ada jalur pendakian yang bisa dipesan.',
                        backgroundColor: Colors.red[400],
                        colorText: Colors.white,
                      );
                      return;
                    }

                    Get.to(() => const BookingScreen());
                  },
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
    if (routeController.isLoading.value && routeController.routes.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Memuat status jalur pendakian...'),
            ],
          ),
        ),
      );
    }

    if (routeController.errorMessage.value.isNotEmpty &&
        routeController.routes.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routeController.errorMessage.value,
                style: TextStyle(color: Colors.red[700], fontSize: 13),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: routeController.fetchRoutes,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (routeController.routes.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Text('Belum ada data jalur pendakian.'),
        ),
      );
    }

    return Column(
      children: routeController.routes.map((route) {
        final bool isOpen = route.isOpen;
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
                color: const Color(0xFF1D4F44).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.terrain, color: Color(0xFF1D4F44)),
            ),
            title: Text(
              route.routeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  route.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (!isOpen && route.closedReason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    route.closedReason,
                    style: TextStyle(fontSize: 12, color: Colors.red[700]),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
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
                : Icon(Icons.lock_outline, size: 18, color: Colors.red[300]),
            onTap: () {
              if (!isOpen) {
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

              Get.to(
                () => const BookingScreen(),
                arguments: {
                  'route_id': route.id,
                  'route_name': route.routeName,
                },
              );
            },
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
                      errorBuilder: (context, error, stackTrace) => Container(
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
