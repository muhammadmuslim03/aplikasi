package payment

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type VerifyRequest struct {
	Action     string `json:"action" binding:"required"`
	RejectNote string `json:"reject_note"`
}

func AdminVerifyPayment(c *gin.Context) {
	id := strings.TrimSpace(c.Param("id"))
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID booking tidak valid"})
		return
	}

	var req VerifyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	var booking models.Booking
	if err := config.DB.Preload("Payment").First(&booking, "id = ?", id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari booking"})
		return
	}

	if booking.Status != "waiting_verification" || booking.Payment == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking tidak sedang menunggu verifikasi pembayaran"})
		return
	}

	switch strings.ToLower(strings.TrimSpace(req.Action)) {
	case "accept":
		now := time.Now()
		booking.Status = "paid"
		booking.RejectNote = nil
		booking.Payment.Status = "paid"
		booking.Payment.RejectNote = nil
		booking.Payment.VerifiedAt = &now

	case "reject":
		note := strings.TrimSpace(req.RejectNote)
		if note == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Catatan penolakan wajib diisi"})
			return
		}

		booking.Status = "cancelled"
		booking.RejectNote = &note
		booking.Payment.Status = "rejected"
		booking.Payment.RejectNote = &note

	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Action tidak valid"})
		return
	}

	if err := config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(&booking).Error; err != nil {
			return err
		}

		return tx.Save(booking.Payment).Error
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui booking"})
		return
	}

	booking.ProofImage = booking.Payment.ProofImage
	booking.PaymentMethod = booking.Payment.Method
	booking.PaymentStatus = booking.Payment.Status

	c.JSON(http.StatusOK, gin.H{
		"message": "Status pembayaran diperbarui",
		"data":    booking,
	})
}
