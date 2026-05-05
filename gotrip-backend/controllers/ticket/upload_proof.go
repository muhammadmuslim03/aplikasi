package ticket

import (
	"net/http"
	"path/filepath"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func UploadProof(c *gin.Context) {
	bookingID := c.Param("id")

	file, err := c.FormFile("proof_image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File tidak ditemukan"})
		return
	}

	paymentMethod := c.PostForm("payment_method")

	ext := filepath.Ext(file.Filename)
	fileName := time.Now().Format("20060102150405") + "_" + bookingID + ext

	filePath := "uploads/" + fileName

	if err := c.SaveUploadedFile(file, filePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal upload file"})
		return
	}

	var booking models.Booking
	if err := config.DB.Preload("Payment").First(&booking, "id = ?", bookingID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	payment := booking.Payment
	if payment == nil {
		payment = &models.Payment{
			BookingID: booking.ID,
			UserID:    booking.UserID,
		}
	}

	payment.Method = paymentMethod
	payment.ProofImage = filePath
	payment.Status = "waiting_verification"
	payment.RejectNote = nil

	booking.Status = "waiting_verification"
	booking.RejectNote = nil

	err = config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(&booking).Error; err != nil {
			return err
		}

		if err := tx.Save(payment).Error; err != nil {
			return err
		}

		return nil
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pembayaran"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Bukti pembayaran berhasil diupload",
		"file":    filePath,
	})
}
