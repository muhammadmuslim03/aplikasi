package booking

import (
	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

// AdminUpdateStatus untuk Admin
func AdminUpdateStatus(c *gin.Context) {
	id := c.Param("id")
	var booking models.Booking

	if err := config.DB.First(&booking, id).Error; err != nil {
		c.JSON(404, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	var input struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": "Input tidak valid"})
		return
	}

	booking.Status = input.Status
	config.DB.Save(&booking)

	c.JSON(200, gin.H{
		"message": "Status booking diperbarui",
		"data":    booking,
	})
}

// UpdateBookingStatus untuk Pendaki (Jika pendaki diizinkan update statusnya, mungkin hanya untuk "Batal" atau "Selesai")
func UpdateBookingStatus(c *gin.Context) {
	id := c.Param("id")

	var body struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	var booking models.Booking
	if err := config.DB.First(&booking, id).Error; err != nil {
		c.JSON(404, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	booking.Status = body.Status
	config.DB.Save(&booking)

	c.JSON(200, gin.H{
		"message": "Status berhasil diperbarui",
		"status":  booking.Status,
	})
}