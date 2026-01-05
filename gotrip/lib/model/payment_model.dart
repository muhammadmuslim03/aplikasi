class PaymentModel {
  final String name;
  final String email;
  final String telepon;
  final String? darurat;
  final DateTime date;
  final int jumlahOrang;
  final int jumlahOjek;
  final bool termasukOjek;
  final double? total;
  final String? proofImagePath;

  PaymentModel({
    this.name = "",
    this.email = "",
    this.telepon = "",
    this.darurat,
    required this.date, 
    this.jumlahOrang = 1,
    this.jumlahOjek = 0,
    this.termasukOjek = false,
    this.total,
    this.proofImagePath,
  });

  PaymentModel copyWith({
    String? name,
    String? email,
    String? telepon,
    String? darurat,
    DateTime? date,
    int? jumlahOrang,
    int? jumlahOjek,
    bool? termasukOjek,
    double? total,
    String? proofImagePath,
  }) {
    return PaymentModel(
      name: name ?? this.name,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      darurat: darurat ?? this.darurat,
      date: date ?? this.date,
      jumlahOrang: jumlahOrang ?? this.jumlahOrang,
      jumlahOjek: jumlahOjek ?? this.jumlahOjek,
      termasukOjek: termasukOjek ?? this.termasukOjek,
      total: total ?? this.total,
      proofImagePath: proofImagePath ?? this.proofImagePath,
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      telepon: json["telepon"] ?? "",
      darurat: json["darurat"],
      date: (json["tanggal"] != null) ? DateTime.parse(json["tanggal"]) : DateTime.now(), 
      jumlahOrang: json["jumlah_orang"] ?? 1,
      jumlahOjek: json["jumlah_ojek"] ?? 0,
      termasukOjek: json["termasuk_ojek"] ?? false,
      total: (json["total_harga"] != null)
          ? double.tryParse(json["total_harga"].toString())
          : null,
      proofImagePath: json["proof_image"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "telepon": telepon,
      "darurat": darurat,
      "tanggal": date.toIso8601String(), 
      "jumlah_orang": jumlahOrang,
      "jumlah_ojek": jumlahOjek,
      "termasuk_ojek": termasukOjek,
      "total_harga": total,
      "proof_image": proofImagePath,
    };
  }
}