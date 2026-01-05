package booking

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

// CreateBooking untuk pendaki
func CreateBooking(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan"})
		return
	}
	uid := userID.(uint)

	var input models.BookingRequest
	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "message": "Gagal mengikat data form"})
		return
	}

	totalHargaInt, err := strconv.Atoi(input.TotalHarga)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format Total Harga tidak valid, harus berupa angka integer murni."})
		return
	}

	uploadDir := "uploads"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat direktori upload"})
		return
	}

	file, err := c.FormFile("proof_image")
	var filename string // Variabel ini akan menyimpan path relatif yang akan disimpan ke DB

	if err == nil && file != nil {
		ext := filepath.Ext(file.Filename)
		baseName := time.Now().Format("20060102150405") + "_" + fmt.Sprintf("%d", uid)
		
		// Jalur lengkap file yang akan disimpan secara fisik
		fullPath := filepath.Join(uploadDir, baseName+ext)
		
		if err := c.SaveUploadedFile(file, fullPath); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan bukti pembayaran"})
			return
		}
		
		// Simpan path relatif "uploads/..." ke database
		filename = fullPath 
		
		fmt.Println("✅ File bukti pembayaran berhasil diupload:", filename)
	} else {
		// Jika tidak ada file, filename akan kosong
		filename = "" 
		fmt.Println("⚠️ Bukti pembayaran tidak disertakan atau error:", err)
	}

	tanggal, err := time.Parse("2006-01-02", input.Tanggal)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format tanggal salah, gunakan YYYY-MM-DD"})
		return
	}

	booking := models.Booking{
		UserID:       uid,
		Nama:         input.Nama,
		Email:        input.Email,
		Telepon:      input.Telepon,
		Darurat:      input.Darurat,
		Tanggal:      tanggal,
		JumlahOrang:  input.JumlahOrang,
		JumlahOjek:   input.JumlahOjek,
		TermasukOjek: input.TermasukOjek,
		TotalHarga:   totalHargaInt,
		ProofImage:   filename, // 🔥 Nilai yang disimpan (misal: "uploads/...")
		Status:       "Menunggu Konfirmasi",
		CreatedAt:    time.Now(),
	}

	if err := config.DB.Create(&booking).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan booking ke database"})
		return
	}

	resp := models.BookingResponse{
		ID:           booking.ID,
		Nama:         booking.Nama,
		Email:        booking.Email,
		Telepon:      booking.Telepon,
		Darurat:      booking.Darurat,
		Tanggal:      tanggal.Format("2006-01-02"),
		JumlahOrang:  booking.JumlahOrang,
		JumlahOjek:   booking.JumlahOjek,
		TermasukOjek: booking.TermasukOjek,
		TotalHarga:   booking.TotalHarga,
		ProofImage:   booking.ProofImage,
		Status:       booking.Status,
	}

	c.JSON(http.StatusCreated, gin.H{"booking": resp, "message": "Booking berhasil dibuat."})
}