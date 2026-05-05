package ticket

import (
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

	booking := models.Booking{
		UserID:    userID,
		RouteID:   input.RouteID,
		RouteName: getRouteName(input.RouteID),

		BookingDate: time.Now(),
		HikingDate:  hikingDate,

		TotalMembers: input.TotalMembers,
		TotalPrice:   input.TotalPrice,

		IncludeOjek: input.IncludeOjek,
		OjekCount:   input.OjekCount,

		Status: "pending",
	}

	var payment models.Payment
	err = config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&booking).Error; err != nil {
			return err
		}

		payment = models.Payment{
			BookingID: booking.ID,
			UserID:    userID,
			Status:    "pending",
		}

		return tx.Create(&payment).Error
	})
	if err != nil {
		c.JSON(500, gin.H{"error": "Gagal membuat booking"})
		return
	}

	booking.Payment = &payment
	c.JSON(201, booking)
}

func getRouteName(id int) string {
	switch id {
	case 1:
		return "Jalur Garung"
	case 2:
		return "Jalur Bowongso"
	case 3:
		return "Jalur Kaliangkrik"
	default:
		return "Unknown"
	}
}
