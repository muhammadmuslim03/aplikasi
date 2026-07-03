# Sequence Diagram User - GoTrip Mobile

Dokumen ini memisahkan sequence diagram untuk aktor user/pendaki pada aplikasi mobile GoTrip. Diagram dibuat dari alur kode Flutter di `gotrip/lib/controller/**` dan endpoint backend Go/Gin di `gotrip-backend/main.go` serta `gotrip-backend/controllers/**`.

## 1. Registrasi User

```mermaid
sequenceDiagram
    autonumber
    actor User as User/Pendaki
    participant Mobile as Aplikasi Mobile Flutter
    participant API as Backend Go/Gin
    participant Auth as Auth Controller
    participant DB as PostgreSQL

    User->>Mobile: Isi form registrasi
    Mobile->>Mobile: Validasi nama, email, password, phone, NIK
    Mobile->>API: POST /auth/register
    API->>Auth: Register(input)
    Auth->>DB: Cek email user

    alt Email sudah terdaftar
        DB-->>Auth: User ditemukan
        Auth-->>API: 400 Email sudah terdaftar
        API-->>Mobile: Response error
        Mobile-->>User: Tampilkan pesan gagal
    else Email belum terdaftar
        Auth->>Auth: Hash password dengan bcrypt
        Auth->>DB: Simpan user role pendaki
        DB-->>Auth: User tersimpan
        Auth-->>API: 201 Registrasi berhasil
        API-->>Mobile: Response sukses
        Mobile-->>User: Arahkan ke login
    end
```

## 2. Login User Mobile

```mermaid
sequenceDiagram
    autonumber
    actor User as User/Pendaki
    participant Mobile as Aplikasi Mobile Flutter
    participant Storage as GetStorage
    participant API as Backend Go/Gin
    participant Auth as Auth Controller
    participant DB as PostgreSQL

    User->>Mobile: Isi email dan password
    Mobile->>Mobile: Validasi email dan password tidak kosong
    Mobile->>API: POST /auth/login client=mobile
    API->>Auth: Login(input)
    Auth->>DB: Cari user berdasarkan email

    alt Email/password salah
        DB-->>Auth: User tidak ditemukan atau password tidak cocok
        Auth-->>API: 401 Email atau password salah
        API-->>Mobile: Response error
        Mobile-->>User: Tampilkan pesan gagal login
    else Role admin mencoba login mobile
        Auth-->>API: 403 Admin hanya bisa login di web admin
        API-->>Mobile: Response error
        Mobile-->>User: Tampilkan pesan akses ditolak
    else Kredensial valid dan role pendaki
        Auth->>Auth: Buat JWT berisi user_id, role, exp
        Auth-->>API: Token dan data user
        API-->>Mobile: 200 AuthResponse
        Mobile->>Storage: Simpan token, user_id, name, email, phone, role
        Mobile-->>User: Masuk ke halaman home
    end
```

## 3. Booking Pendakian dan Upload Bukti Pembayaran

```mermaid
sequenceDiagram
    autonumber
    actor User as User/Pendaki
    participant Mobile as Aplikasi Mobile Flutter
    participant Storage as GetStorage
    participant API as Backend Go/Gin
    participant MW as AuthMiddleware
    participant Ticket as Ticket Controller
    participant Uploads as Folder uploads
    participant DB as PostgreSQL

    User->>Mobile: Pilih jalur, tanggal, jumlah anggota, opsi ojek
    Mobile->>Mobile: Hitung total harga dan validasi form
    Mobile->>Storage: Ambil token JWT
    Mobile->>API: POST /api/bookings + Bearer token
    API->>MW: Validasi JWT

    alt Token tidak valid
        MW-->>API: 401 Token tidak valid
        API-->>Mobile: Response error
        Mobile-->>User: Minta login ulang
    else Token valid
        MW->>Ticket: CreateBooking(user_id, input)
        Ticket->>DB: Cari hiking_routes berdasarkan route_id

        alt Jalur tidak ditemukan atau ditutup
            DB-->>Ticket: Data jalur tidak valid
            Ticket-->>API: 400 Jalur tidak tersedia
            API-->>Mobile: Response error
            Mobile-->>User: Tampilkan pesan gagal booking
        else Jalur terbuka
            Ticket->>DB: Begin transaction
            Ticket->>DB: Simpan booking status pending
            Ticket->>DB: Simpan payment status pending
            DB-->>Ticket: Commit transaction
            Ticket-->>API: 201 Detail booking dan payment
            API-->>Mobile: Response booking berhasil
            Mobile-->>User: Buka halaman upload bukti pembayaran
        end
    end

    User->>Mobile: Pilih metode bayar dan gambar bukti
    Mobile->>Mobile: Validasi metode dan file bukti
    Mobile->>Storage: Ambil token JWT
    Mobile->>API: PATCH /api/bookings/:id/proof multipart
    API->>MW: Validasi JWT
    MW->>Ticket: UploadProof(booking_id, payment_method, proof_image)
    Ticket->>Uploads: Simpan file bukti pembayaran
    Ticket->>DB: Ambil booking beserta payment
    Ticket->>DB: Begin transaction
    Ticket->>DB: Update booking status waiting_verification
    Ticket->>DB: Update payment method, proof_image, status waiting_verification
    DB-->>Ticket: Commit transaction
    Ticket-->>API: 200 Bukti pembayaran berhasil diupload
    API-->>Mobile: Response sukses
    Mobile-->>User: Tampilkan status menunggu verifikasi
```

## 4. Melihat Riwayat Booking

```mermaid
sequenceDiagram
    autonumber
    actor User as User/Pendaki
    participant Mobile as Aplikasi Mobile Flutter
    participant Storage as GetStorage
    participant API as Backend Go/Gin
    participant MW as AuthMiddleware
    participant Ticket as Ticket Controller
    participant DB as PostgreSQL

    User->>Mobile: Buka riwayat booking
    Mobile->>Storage: Ambil token JWT
    Mobile->>API: GET /api/bookings + Bearer token
    API->>MW: Validasi JWT

    alt Token tidak valid
        MW-->>API: 401 Token diperlukan/tidak valid
        API-->>Mobile: Response error
        Mobile-->>User: Tampilkan pesan login ulang
    else Token valid
        MW->>Ticket: GetBookings(user_id)
        Ticket->>DB: Ambil bookings milik user dan preload payment
        DB-->>Ticket: Daftar booking
        Ticket-->>API: 200 List booking
        API-->>Mobile: Response riwayat
        Mobile-->>User: Tampilkan status pending, waiting_verification, paid, checked_in, checked_out, atau cancelled
    end
```

## 5. Check-in dan Check-out Barcode

```mermaid
sequenceDiagram
    autonumber
    actor User as User/Pendaki
    participant Mobile as Aplikasi Mobile Flutter
    participant Storage as GetStorage
    participant API as Backend Go/Gin
    participant MW as AuthMiddleware
    participant Checkpoint as Checkpoint Controller
    participant DB as PostgreSQL

    User->>Mobile: Scan barcode check-in atau check-out
    Mobile->>Storage: Ambil token JWT
    Mobile->>API: POST /api/checkpoint/scan {code}
    API->>MW: Validasi JWT
    MW->>Checkpoint: ScanBarcode(user_id, code)
    Checkpoint->>Checkpoint: Normalisasi kode barcode

    alt Kode bukan GOTRIP_CHECK_IN/GOTRIP_CHECK_OUT
        Checkpoint-->>API: 400 Barcode tidak valid
        API-->>Mobile: Response error
        Mobile-->>User: Tampilkan barcode tidak valid
    else Kode GOTRIP_CHECK_IN
        Checkpoint->>DB: Begin transaction
        Checkpoint->>DB: Cari user dan booking status paid
        alt Booking paid tidak ditemukan
            DB-->>Checkpoint: Record tidak ditemukan
            Checkpoint-->>API: 404 Tidak ada booking terbayar yang siap check-in
            API-->>Mobile: Response error
            Mobile-->>User: Tampilkan gagal check-in
        else Booking ditemukan
            Checkpoint->>DB: Update booking status checked_in dan checked_in_at
            Checkpoint->>DB: Update user check_in=true, check_out=false
            DB-->>Checkpoint: Commit transaction
            Checkpoint-->>API: 200 Check-in berhasil
            API-->>Mobile: Response sukses
            Mobile-->>User: Tampilkan check-in berhasil
        end
    else Kode GOTRIP_CHECK_OUT
        Checkpoint->>DB: Begin transaction
        Checkpoint->>DB: Cari user dan booking status checked_in
        alt Booking aktif tidak ditemukan
            DB-->>Checkpoint: Record tidak ditemukan
            Checkpoint-->>API: 404 Tidak ada booking aktif yang bisa check-out
            API-->>Mobile: Response error
            Mobile-->>User: Tampilkan gagal check-out
        else Booking aktif ditemukan
            Checkpoint->>DB: Update booking status checked_out dan checked_out_at
            Checkpoint->>DB: Update user check_in=false, check_out=true
            DB-->>Checkpoint: Commit transaction
            Checkpoint-->>API: 200 Check-out berhasil
            API-->>Mobile: Response sukses
            Mobile-->>User: Tampilkan check-out berhasil
        end
    end
```

## 6. Navigasi dan Cuaca Mobile

```mermaid
sequenceDiagram
    autonumber
    actor User as User/Pendaki
    participant Mobile as Aplikasi Mobile Flutter
    participant GPS as GPS Perangkat
    participant RouteData as Data Rute Lokal
    participant Weather as Open-Meteo API

    User->>Mobile: Buka halaman navigasi/cuaca
    Mobile->>GPS: Minta izin lokasi dan posisi terkini
    GPS-->>Mobile: Koordinat user
    Mobile->>RouteData: Ambil titik rute Gunung Sumbing
    RouteData-->>Mobile: Daftar koordinat jalur
    Mobile->>Weather: Request data cuaca/forecast koordinat
    Weather-->>Mobile: Data cuaca dan prakiraan
    Mobile-->>User: Tampilkan peta, posisi, rute, dan cuaca
```

## Ringkasan Status User

```mermaid
stateDiagram-v2
    [*] --> BelumLogin
    BelumLogin --> Login: Registrasi selesai atau user sudah punya akun
    Login --> Home: Login sukses role pendaki
    Home --> Pending: Booking dibuat
    Pending --> MenungguVerifikasi: Upload bukti pembayaran
    MenungguVerifikasi --> Paid: Admin menerima pembayaran
    MenungguVerifikasi --> Cancelled: Admin menolak pembayaran
    Paid --> CheckedIn: Scan GOTRIP_CHECK_IN
    CheckedIn --> CheckedOut: Scan GOTRIP_CHECK_OUT
    CheckedOut --> Home
    Cancelled --> Home
```

