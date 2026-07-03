package ticket

import (
	"errors"
	"net/http"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CreateBooking(c *gin.Context) {
	createBooking(c)
}

func CreateTicket(c *gin.Context) {
	createBooking(c)
}

func createBooking(c *gin.Context) {
	userID := c.GetUint("user_id")

	var input models.CreateBookingRequest
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	hikingDate, err := time.Parse("2006-01-02", input.HikingDate)
	if err != nil {
		c.JSON(400, gin.H{"error": "Format tanggal salah"})
		return
	}

	var hikingRoute models.HikingRoute
	if err := config.DB.First(&hikingRoute, "id = ?", input.RouteID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Jalur pendakian tidak ditemukan"})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari jalur pendakian"})
		return
	}

	if !hikingRoute.IsOpen {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Jalur pendakian sedang ditutup"})
		return
	}

	booking := models.Booking{
		UserID:    userID,
		RouteID:   input.RouteID,
		RouteName: hikingRoute.RouteName,

		BookingDate: time.Now(),
		HikingDate:  hikingDate,

		TotalMembers: input.TotalMembers,
		TotalPrice:   input.TotalPrice,

		IncludeOjek: input.IncludeOjek,
		OjekCount:   input.OjekCount,

		Status: "pending",
	}

	if err := config.DB.Create(&booking).Error; err != nil {
		c.JSON(500, gin.H{"error": "Gagal membuat booking"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Booking berhasil dibuat",
		"ticket":  booking,
	})
}
