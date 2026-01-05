package booking

import (
	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

// AdminGetAllBookings untuk Admin (Semua booking)
func AdminGetAllBookings(c *gin.Context) {
	var bookings []models.Booking

	config.DB.Order("created_at DESC").Find(&bookings)

	c.JSON(200, gin.H{
		"data": bookings,
	})
}

// GetAllBookings - (Duplikat, gunakan AdminGetAllBookings di atas, atau satukan logic jika memang ada perbedaan)
func GetAllBookings(c *gin.Context) {
	var bookings []models.Booking

	// Menggunakan Preload("User") untuk mengambil data user terkait, ini bagus
	if err := config.DB.
		Preload("User").
		Find(&bookings).Error; err != nil {

		c.JSON(500, gin.H{
			"message": "Gagal mengambil data booking",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(200, gin.H{
		"message":  "Success",
		"bookings": bookings,
	})
}