# ⚙️ GoTrip Backend REST API

Layanan RESTful API backend untuk platform reservasi tiket dan navigasi pendakian gunung **GoTrip**, dibangun menggunakan bahasa pemrograman Go (Golang) dan framework Gin.

---

## 🛠️ Tech Stack & Pustaka

- **Bahasa**: [Go (Golang) 1.24](https://go.dev/)
- **Web Framework**: [Gin Gonic](https://gin-gonic.com/) v1.11.0
- **ORM & Database**: [GORM](https://gorm.io/) v1.31.1 + PostgreSQL Driver
- **Autentikasi**: `golang-jwt/jwt/v5` & `golang.org/x/crypto/bcrypt`
- **Konfigurasi**: `joho/godotenv`
- **Laporan & Ekspor**: `phpdave11/gofpdf` (PDF generator) & bawaan `encoding/csv`
- **Pembayaran**: Midtrans Snap Payment API integration

---

## 🚀 Fitur Backend

- **Autentikasi & RBAC**: Registrasi, login, dan pemisahan hak akses berbasis role (`pendaki` vs `admin`).
- **Manajemen Reservasi & Tiket**:
  - Reservasi kuota pendakian harian.
  - Pembuatan e-tiket otomatis dan kode QR.
  - Check-in dan Check-out pendaki via scanning barcode.
- **Integrasi Pembayaran**:
  - Gateway otomatis Midtrans Snap dengan webhook receiver (`/api/payments/webhook`).
  - Penanganan pembayaran manual transfer dan upload bukti transfer (`/api/payments/upload-proof`).
- **Dashboard & Analitik**: Agregasi data statistik pendaki dan laporan pendapatan.
- **Ekspor Dokumen**: Generator laporan transaksi dalam format PDF dan CSV.

---

## ⚙️ Panduan Setup & Menjalankan

### 1. Konfigurasi Environment
Salin template `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```
Sesuaikan konfigurasi database PostgreSQL dan kredensial Midtrans Anda di file `.env`.

### 2. Download Dependencies
```bash
go mod download
```

### 3. Jalankan Server
```bash
go run main.go
```
Server akan berjalan di port `8080` (default) dan secara otomatis melakukan auto-migrate tabel pada database.

---

## 📂 Struktur Direktori Backend

```text
gotrip-backend/
├── config/          # Pengaturan database & pemuatan environment
├── controllers/     # HTTP Handlers (auth, payment, ticket, dashboard, export)
├── middlewares/     # JWT Auth & Role-based Access Control
├── models/          # Entitas & skema database GORM
├── routes/          # Definisi endpoint API Gin
├── services/        # Logika bisnis (Midtrans, QR Code, Payment)
├── uploads/         # Direktori runtime penyimpanan bukti transfer (diabaikan git)
├── .env.example     # Contoh konfigurasi environment
├── go.mod           # Daftar dependency Go
└── main.go          # Entry point server aplikasi
```
