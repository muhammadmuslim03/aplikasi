package ticket

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

func CheckInTicket(c *gin.Context) {
	booking, ok := findBookingForHikingAction(c)
	if !ok {
		return
	}

	switch booking.Status {
	case "paid":
		now := time.Now()
		booking.Status = "checked_in"
		booking.CheckedInAt = &now

	case "checked_in":
		c.JSON(http.StatusConflict, gin.H{"error": "Booking sudah check-in"})
		return

	case "checked_out":
		c.JSON(http.StatusConflict, gin.H{"error": "Booking sudah check-out"})
		return

	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Booking harus berstatus terbayar sebelum check-in",
		})
		return
	}

	saveHikingAction(c, &booking, "Pendaki berhasil check-in")
}

func CheckOutTicket(c *gin.Context) {
	booking, ok := findBookingForHikingAction(c)
	if !ok {
		return
	}

	switch booking.Status {
	case "checked_in":
		now := time.Now()
		booking.Status = "checked_out"
		booking.CheckedOutAt = &now

	case "checked_out":
		c.JSON(http.StatusConflict, gin.H{"error": "Booking sudah check-out"})
		return

	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Booking harus sudah check-in sebelum check-out",
		})
		return
	}

	saveHikingAction(c, &booking, "Pendaki berhasil check-out")
}

func findBookingForHikingAction(c *gin.Context) (models.Booking, bool) {
	id := strings.TrimSpace(c.Param("id"))
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID booking tidak valid"})
		return models.Booking{}, false
	}

	var booking models.Booking
	if err := config.DB.First(&booking, "id = ?", id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
			return models.Booking{}, false
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari booking"})
		return models.Booking{}, false
	}

	return booking, true
}

func saveHikingAction(c *gin.Context, booking *models.Booking, message string) {
	if err := config.DB.Save(booking).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui booking"})
		return
	}

	if err := config.DB.Preload("Payment").First(booking, "id = ?", booking.ID).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{
			"message": message,
			"data":    booking,
		})
		return
	}

	attachUserToBooking(booking)
	attachPaymentField(booking)

	c.JSON(http.StatusOK, gin.H{
		"message": message,
		"data":    booking,
	})
}
