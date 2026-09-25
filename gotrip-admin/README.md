# 💻 GoTrip Admin Dashboard

Dashboard web manajemen dan monitoring operasional pendakian gunung untuk pengelola basecamp **GoTrip**.

---

## 🛠️ Tech Stack

- **Framework**: [React 19](https://react.dev/) + [Vite](https://vitejs.dev/)
- **Routing**: React Router DOM v7
- **Styling**: Tailwind CSS
- **HTTP Client**: Axios (dengan JWT Bearer interceptor)
- **Visualisasi Data / Grafik**: Recharts
- **Icons**: Lucide React

---

## 🚀 Fitur Admin

1. **Dashboard Statistik**: Pemantauan visual grafik jumlah pendaki harian, bulanan, dan total penerimaan transaksi tiket.
2. **Manajemen Reservasi & Tiket**:
   - Melihat daftar seluruh reservasi pendaki.
   - Verifikasi bukti transfer manual pendaki (preview gambar bukti pembayaran).
   - Menyetujui (*approve*) atau menolak (*reject*) pembayaran tiket.
3. **Validasi Check-in & Check-out**:
   - Pemantauan status pendaki yang sedang berada di jalur pendakian (*checked-in*) vs sudah turun (*checked-out*).
4. **Ekspor Laporan**:
   - Download rekap data transaksi dan tiket dalam format PDF dan CSV.

---

## ⚙️ Cara Menjalankan

### 1. Salin Environment
```bash
cp .env.example .env
```
Pastikan `VITE_API_BASE_URL` mengarah ke URL backend GoTrip (contoh: `http://localhost:8080`).

### 2. Pasang Dependencies
```bash
npm install
```

### 3. Jalankan Mode Development
```bash
npm run dev
```
Akses web di peramban pada alamat `http://localhost:5173`.

### 4. Build untuk Production
```bash
npm run build
```
File hasil build akan berada di direktori `dist/`.

---

## 📂 Struktur Folder

```text
src/
├── api/             # Konfigurasi Axios instance & helper format URL
├── assets/          # Logo, icon, dan aset statis
├── components/      # Komponen navigasi, modal, header, dll
├── pages/           # Halaman utama (Dashboard, Bookings, Verification, dll)
├── App.jsx          # Routing & Root layout
└── main.jsx         # Entrypoint React
```
