import 'package:get/get.dart';
import '../model/news_model.dart';

class NewsController extends GetxController {
  var newsList = <NewsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  void fetchNews() {
    // Data dummy (nanti bisa diganti dari API)
    newsList.assignAll([
      NewsModel(
        title: "Pendakian Gunung Sumbing Dibuka Kembali",
        content:
            "Setelah sempat ditutup karena kondisi cuaca ekstrem, jalur pendakian Gunung Sumbing resmi dibuka kembali mulai 10 Oktober 2025. Para pendaki diimbau tetap memperhatikan keselamatan dan membawa perlengkapan standar.",
        date: DateTime(2025, 10, 10),
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRImydgli7FivV9d3WIGZ-XBJ8sti-fIthRsw&s",
      ),
      NewsModel(
        title: "Kegiatan Bersih Gunung Sumbing oleh Komunitas Pecinta Alam",
        content:
            "Puluhan relawan dari berbagai komunitas pecinta alam melakukan kegiatan bersih gunung di jalur pendakian Garung. Aksi ini bertujuan menjaga kebersihan dan kelestarian lingkungan sekitar Gunung Sumbing.",
        date: DateTime(2025, 10, 5),
        imageUrl:
            "https://cdn.antaranews.com/cache/1200x800/2025/01/15/Tradisi-Nyadran-Lepen-Di-Lereng-Gunung-Sumbing-150125-aez-2.jpg",
      ),
      NewsModel(
        title: "Gunung Sumbing Jadi Favorit Pendaki Akhir Tahun",
        content:
            "Gunung Sumbing menjadi salah satu destinasi favorit untuk pendakian akhir tahun. Keindahan sunrise dari puncak 3.371 mdpl ini menarik banyak pendaki dari berbagai daerah.",
        date: DateTime(2025, 10, 1),
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEVsuKDVVN3a8ALvwoYin1klnnVsSho7TcnQ&s",
      ),
    ]);
  }
}
