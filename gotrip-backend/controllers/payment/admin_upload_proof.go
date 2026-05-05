package payment

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AdminUploadProof(c *gin.Context) {

	id := c.PostForm("booking_id")
	if id == "" {
		id = c.PostForm("ticket_id")
	}

	var booking models.Booking
	if err := config.DB.Preload("Payment").First(&booking, "id = ?", id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	file, err := c.FormFile("proof")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File tidak ditemukan"})
		return
	}

	if err := os.MkdirAll("uploads", os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyiapkan folder upload"})
		return
	}

	ext := filepath.Ext(file.Filename)
	if ext == "" {
		ext = ".png"
	}

	filename := fmt.Sprintf("uploads/proof_%s_%d%s", booking.ID, time.Now().Unix(), ext)

	if err := c.SaveUploadedFile(file, filename); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal upload file"})
		return
	}

	payment := booking.Payment
	if payment == nil {
		payment = &models.Payment{
			BookingID: booking.ID,
			UserID:    booking.UserID,
		}
	}

	payment.Method = c.PostForm("payment_method")
	payment.ProofImage = filename
	payment.Status = "waiting_verification"
	booking.Status = "waiting_verification"

	if err := config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(&booking).Error; err != nil {
			return err
		}

		return tx.Save(payment).Error
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pembayaran"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Bukti pembayaran berhasil diupload",
		"path":    filename,
	})
}
