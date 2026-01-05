package models

// === ADMIN BOOKING RESPONSE ===
type AdminBookingResponse struct {
    ID           uint   `json:"id"`
    UserID       uint   `json:"user_id"`
    Nama         string `json:"nama"`
    Email        string `json:"email"`
    Telepon      string `json:"telepon"`
    Darurat      string `json:"darurat"`
    Tanggal      string `json:"tanggal"`
    JumlahOrang  int    `json:"jumlah_orang"`
    JumlahOjek   int    `json:"jumlah_ojek"`
    TermasukOjek bool   `json:"termasuk_ojek"`
    TotalHarga   int    `json:"total_harga"`
    ProofImage   string `json:"proof_image"`
    Status       string `json:"status"`
    CreatedAt    string `json:"created_at"`
}

// === ADMIN REQUESTS ===
type AdminUpdateStatusRequest struct {
    Status string `json:"status" binding:"required"`
}

// === ADMIN DASHBOARD ===
type DashboardSummary struct {
    TotalPendaki    int `json:"total_pendaki"`
    TotalBooking    int `json:"total_booking"`
    TotalTerbayar   int `json:"total_terbayar"`
    TotalPending    int `json:"total_pending"`
    TotalPendapatan int `json:"total_pendapatan"`
}