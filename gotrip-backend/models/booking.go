package models

import "time"

// === BOOKING (Database Model) ===
type Booking struct {
	ID           uint      `gorm:"primaryKey" json:"id"`
	UserID       uint      `json:"user_id"`
	Nama         string    `json:"nama"`
	Email        string    `json:"email"`
	Telepon      string    `json:"telepon"`
	Darurat      string    `json:"darurat"`
	Tanggal      time.Time `json:"tanggal"`
	JumlahOrang  int       `json:"jumlah_orang"`
	JumlahOjek   int       `json:"jumlah_ojek"`
	TermasukOjek bool      `json:"termasuk_ojek"`
	TotalHarga   int       `json:"total_harga"`
	ProofImage   string    `json:"proof_image"`

	Status     string  `json:"status" gorm:"default:'Menunggu Konfirmasi'"`
	RejectNote *string `json:"reject_note" gorm:"type:text"`

	CreatedAt time.Time `json:"created_at"`
}

type BookingResponse struct {
	ID           uint   `json:"id"`
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
	RejectNote   string `json:"reject_note"`
}
