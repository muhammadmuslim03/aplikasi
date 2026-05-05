class BookingHistoryModel {
  final int id;
  final String nama;
  final String email;
  final String telepon;
  final String darurat;
  final String tanggal;
  final int jumlahOrang;
  final int jumlahOjek;
  final bool termasukOjek;
  final int totalHarga;
  final String status;
  final String proofImage;
  final String rejectNote;

  BookingHistoryModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.telepon,
    required this.darurat,
    required this.tanggal,
    required this.jumlahOrang,
    required this.jumlahOjek,
    required this.termasukOjek,
    required this.totalHarga,
    required this.status,
    required this.proofImage,
    required this.rejectNote,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '-',
      email: json['email'] ?? '-',
      telepon: json['telepon'] ?? '-',
      darurat: json['darurat'] ?? '-',
      tanggal: json['tanggal'] ?? '',
      jumlahOrang: json['jumlah_orang'] ?? 0,
      jumlahOjek: json['jumlah_ojek'] ?? 0,
      termasukOjek: json['termasuk_ojek'] ?? false,
      totalHarga: json['total_harga'] ?? 0,
      status: json['status'] ?? 'Menunggu Pembayaran',
      proofImage: json['proof_image'] ?? '',
      rejectNote: json['reject_note'] ?? '',
    );
  }
}