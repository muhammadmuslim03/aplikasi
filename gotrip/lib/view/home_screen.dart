import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'booking_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> beritaList = [
      {
        'judul': 'Gunung Sumbing Dibuka Kembali untuk Pendakian',
        'tanggal': '10 Oktober 2025',
        'isi':
            'Gunung Sumbing resmi dibuka kembali setelah sempat ditutup akibat cuaca ekstrem. Para pendaki diimbau tetap berhati-hati dan menjaga kebersihan jalur pendakian.',
        'gambar':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRImydgli7FivV9d3WIGZ-XBJ8sti-fIthRsw&s',
      },
      {
        'judul': 'Aksi Bersih Jalur Gunung Sumbing',
        'tanggal': '7 Oktober 2025',
        'isi':
            'Komunitas pecinta alam melakukan kegiatan bersih-bersih jalur pendakian dari basecamp Garung hingga Pos 3.',
        'gambar':
            'https://cdn.antaranews.com/cache/1200x800/2025/01/15/Tradisi-Nyadran-Lepen-Di-Lereng-Gunung-Sumbing-150125-aez-2.jpg',
      },
      {
        'judul': 'Tips Mendaki Gunung Sumbing Bagi Pemula',
        'tanggal': '5 Oktober 2025',
        'isi':
            'Sebelum mendaki Gunung Sumbing, pastikan kamu sudah berlatih fisik, membawa perlengkapan mendaki, dan memahami jalur pendakian.',
        'gambar':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEVsuKDVVN3a8ALvwoYin1klnnVsSho7TcnQ&s',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('GoTrip'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF1D4F44),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4F44), Color(0xFF2A6B5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang di GoTrip!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jelajahi keindahan Gunung Sumbing bersama kami',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1D4F44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pesan Tiket',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Berita Terkini',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(const NewsScreen());
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ListView.builder(
              itemCount: beritaList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final berita = beritaList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Get.snackbar(
                        berita['judul']!,
                        'Klik untuk membaca lebih lanjut!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
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
                            berita['gambar']!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  berita['judul']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  berita['tanggal']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  berita['isi']!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
