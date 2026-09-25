# 📱 GoTrip Mobile Application

Aplikasi mobile berbasis Flutter untuk para pendaki gunung dalam melakukan registrasi, pemesanan tiket pendakian, pembayaran online/transfer, e-tiket QR Code, dan navigasi GPS rute pendakian (Studi Kasus: Jalur Pendakian Gunung Sumbing).

---

## 🛠️ Tech Stack & Pustaka Utama

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK ^3.9.2)
- **State Management & Routing**: `get` (GetX) & `get_storage`
- **Peta & Geolocation**: `flutter_map`, `latlong2`, `geolocator`
- **Barcode & Scanner**: `mobile_scanner`, `qr_flutter`
- **HTTP & Network**: `http`, `dio`, `http_parser`
- **Utilities**: `intl`, `image_picker`, `url_launcher`

---

## 🌟 Fitur Utama Mobile

1. **Autentikasi Pendaki**: Registrasi akun dan login berbasis JWT dengan penyimpanan token lokal (`get_storage`).
2. **Pemesanan Tiket (Booking)**: Pemilihan tanggal pendakian, jumlah tiket/rombongan, pengisian identitas pendaki.
3. **Pembayaran Terintegrasi**:
   - Pembayaran instan via Midtrans Snap (Virtual Account, E-Wallet, QRIS).
   - Pembayaran manual via transfer bank dengan mengunggah bukti pembayaran langsung dari kamera/galeri.
4. **E-Ticket Digital**: Tiket pendakian otomatis dengan QR Code untuk dipindai saat di basecamp.
5. **Navigasi Rute Gunung Sumbing**:
   - Peta jalur pendakian interaktif dengan koordinat pos-pos pendakian (*sumbing_route_points*).
   - Penjejakan posisi pendaki secara real-time via GPS.
6. **Perkiraan Cuaca & Berita**: Informasi cuaca dan pembaruan seputar pendakian.

---

## 🚀 Panduan Menjalankan

### 1. Konfigurasi Endpoint Backend
Buka file `lib/config/api_config.dart` dan sesuaikan `API_BASE_URL`:
- Emulator Android: `http://10.0.2.2:8080`
- Perangkat Fisik (HP): Gunakan IP lokal komputer Anda pada jaringan Wi-Fi yang sama (misal `http://192.168.1.50:8080`)

### 2. Mengambil Dependencies
```bash
flutter pub get
```

### 3. Menjalankan Aplikasi
```bash
flutter run
```

### 4. Build APK Release
```bash
flutter build apk --release
```
