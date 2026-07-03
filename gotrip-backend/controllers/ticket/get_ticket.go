package ticket

import (
	"net/http"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

func GetTickets(c *gin.Context) {
	GetBookings(c)
}

func GetBookings(c *gin.Context) {
	userID := c.GetUint("user_id")

	var bookings []models.Booking

	err := config.DB.
		Preload("Payment").
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&bookings).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal mengambil booking",
		})
		return
	}

	attachPaymentFields(bookings)

	c.JSON(http.StatusOK, gin.H{
		"tickets": bookings,
	})
}

func GetAllTicketsAdmin(c *gin.Context) {
	GetAllBookingsAdmin(c)
}

func GetAllBookingsAdmin(c *gin.Context) {
	var bookings []models.Booking

	err := config.DB.
		Preload("Payment").
		Order("created_at DESC").
		Find(&bookings).Error

	if err != nil {
		c.JSON(500, gin.H{
			"error": "Gagal mengambil semua booking",
		})
		return
	}

	attachUsersToBookings(bookings)
	attachPaymentFields(bookings)

	c.JSON(200, gin.H{
		"data": bookings,
	})
}
