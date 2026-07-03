package payment

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"
	"gotrip-backend/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func ContinuePayment(c *gin.Context) {
	userID := c.GetUint("user_id")
	ticketID := strings.TrimSpace(c.Param("ticket_id"))
	if ticketID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ticket_id tidak valid"})
		return
	}

	var ticket models.Booking
	if err := config.DB.Preload("Payment").First(&ticket, "id = ?", ticketID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Ticket tidak ditemukan"})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari ticket"})
		return
	}

	if ticket.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak boleh membayar ticket milik user lain"})
		return
	}

	if ticket.Status == "paid" {
		c.JSON(http.StatusOK, gin.H{
			"message": "Tiket sudah dibayar",
			"ticket":  ticket,
		})
		return
	}

	if ticket.Status == "cancelled" || ticket.Status == "checked_in" || ticket.Status == "checked_out" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ticket tidak dapat dibayar pada status saat ini"})
		return
	}

	if canReusePayment(ticket.Payment) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Payment pending ditemukan",
			"payment": paymentResponse(ticket.Payment),
		})
		return
	}

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari user"})
		return
	}

	midtransService, err := services.NewMidtransServiceFromEnv()
	if err != nil {
		if errors.Is(err, services.ErrMidtransConfig) {
			createManualPayment(c, &ticket, userID)
			return
		}

		writeMidtransConfigError(c, err)
		return
	}

	transaction, err := midtransService.CreateTransaction(ticket, user)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": err.Error()})
		return
	}

	payment := ticket.Payment
	if payment == nil {
		payment = &models.Payment{
			BookingID: ticket.ID,
			UserID:    userID,
		}
	}

	payment.Provider = midtransService.ProviderName()
	payment.ProviderTransactionID = transaction.OrderID
	payment.PaymentMethod = "snap"
	payment.Amount = transaction.Amount
	payment.Status = "pending"
	payment.PaymentURL = transaction.PaymentURL
	payment.SnapToken = transaction.SnapToken
	payment.ExpiredAt = &transaction.ExpiredAt
	payment.PaidAt = nil
	payment.RejectNote = nil

	ticket.Status = "pending"
	ticket.RejectNote = nil

	if err := config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(&ticket).Error; err != nil {
			return err
		}

		return tx.Save(payment).Error
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan payment"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Payment berhasil dibuat",
		"payment": paymentResponse(payment),
	})
}

func createManualPayment(c *gin.Context, ticket *models.Booking, userID uint) {
	payment := ticket.Payment
	if payment == nil {
		payment = &models.Payment{
			BookingID: ticket.ID,
			UserID:    userID,
		}
	}

	payment.Provider = "manual"
	payment.ProviderTransactionID = ""
	payment.PaymentMethod = ""
	payment.Amount = ticket.TotalPrice
	payment.Status = "pending"
	payment.PaymentURL = ""
	payment.SnapToken = ""
	payment.VANumber = ""
	payment.QRString = ""
	payment.ExpiredAt = nil
	payment.PaidAt = nil
	payment.RejectNote = nil

	ticket.Status = "pending"
	ticket.RejectNote = nil

	if err := config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(ticket).Error; err != nil {
			return err
		}

		return tx.Save(payment).Error
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan payment manual"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":                     "MIDTRANS_CONFIG_MISSING",
		"message":                  "Midtrans belum dikonfigurasi. Gunakan pembayaran manual.",
		"payment":                  paymentResponse(payment),
		"manual_payment_available": true,
	})
}

func GetPaymentStatus(c *gin.Context) {
	userID := c.GetUint("user_id")
	ticketID := strings.TrimSpace(c.Param("ticket_id"))
	if ticketID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ticket_id tidak valid"})
		return
	}

	var ticket models.Booking
	if err := config.DB.Preload("Payment").First(&ticket, "id = ?", ticketID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Ticket tidak ditemukan"})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari ticket"})
		return
	}

	if ticket.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak boleh melihat payment ticket milik user lain"})
		return
	}

	var midtransStatus *services.MidtransStatusResponse
	if ticket.Payment != nil && ticket.Payment.Provider == "midtrans" && ticket.Payment.ProviderTransactionID != "" {
		if midtransService, err := services.NewMidtransServiceFromEnv(); err == nil {
			if status, err := midtransService.GetPaymentStatus(ticket.Payment.ProviderTransactionID); err == nil {
				midtransStatus = status
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"ticket_status": ticket.Status,
		"payment":       paymentResponse(ticket.Payment),
		"midtrans":      midtransStatus,
		"ticket":        ticket,
	})
}

func MidtransWebhook(c *gin.Context) {
	var notification services.MidtransNotification
	if err := c.ShouldBindJSON(&notification); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Payload webhook tidak valid"})
		return
	}

	midtransService, err := services.NewMidtransServiceFromEnv()
	if err != nil {
		writeMidtransConfigError(c, err)
		return
	}

	if !midtransService.VerifySignature(notification) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Signature Midtrans tidak valid"})
		return
	}

	payment, ticket, err := services.ApplyMidtransNotification(config.DB, notification, midtransService)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Payment tidak ditemukan"})
			return
		}

		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Webhook Midtrans diproses",
		"payment": paymentResponse(payment),
		"ticket":  ticket,
	})
}

func writeMidtransConfigError(c *gin.Context, err error) {
	if errors.Is(err, services.ErrMidtransConfig) {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"code":                     "MIDTRANS_CONFIG_MISSING",
			"error":                    "Konfigurasi Midtrans belum lengkap",
			"detail":                   err.Error(),
			"hint":                     "Tambahkan MIDTRANS_SERVER_KEY di file .env lalu restart backend",
			"example":                  "Lihat gotrip-backend/.env.example",
			"manual_payment_available": true,
		})
		return
	}

	c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
}

func canReusePayment(payment *models.Payment) bool {
	if payment == nil {
		return false
	}

	if payment.Provider != "midtrans" || payment.Status != "pending" {
		return false
	}

	if payment.PaymentURL == "" || payment.SnapToken == "" || payment.ExpiredAt == nil {
		return false
	}

	return payment.ExpiredAt.After(time.Now())
}

func paymentResponse(payment *models.Payment) gin.H {
	if payment == nil {
		return nil
	}

	return gin.H{
		"ticket_id":      payment.BookingID,
		"payment_id":     payment.ID,
		"provider":       payment.Provider,
		"payment_method": payment.PaymentMethod,
		"payment_url":    payment.PaymentURL,
		"snap_token":     payment.SnapToken,
		"amount":         payment.Amount,
		"va_number":      payment.VANumber,
		"qr_string":      payment.QRString,
		"expired_at":     payment.ExpiredAt,
		"paid_at":        payment.PaidAt,
		"status":         payment.Status,
	}
}
