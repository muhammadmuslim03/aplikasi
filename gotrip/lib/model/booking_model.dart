class PemesananModel {
  String nama;
  String email;
  String telepon;
  String darurat;
  DateTime? tanggalPendakian;
  int jumlahOrang;
  bool termasukOjek;

  final int hargaPerOrang = 35000;
  final int biayaOjek = 20000;

  PemesananModel({
    this.nama = '',
    this.email = '',
    this.telepon = '',
    this.darurat = '',
    this.tanggalPendakian,
    this.jumlahOrang = 1,
    this.termasukOjek = true,
  });

  int? _totalHargaOverride;

  int get totalHarga {
    if (_totalHargaOverride != null) return _totalHargaOverride!;
    int total = jumlahOrang * hargaPerOrang;
    if (termasukOjek) total += jumlahOrang * biayaOjek;
    return total;
  }

  set totalHarga(int value) {
    _totalHargaOverride = value;
  }

  int _jumlahOjek = 0;

  int get jumlahOjek => _jumlahOjek;

  set jumlahOjek(int jumlahOjek) {
    _jumlahOjek = jumlahOjek;
  }
}
