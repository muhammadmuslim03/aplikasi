package booking

import (
	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

// AdminDeleteBooking untuk Admin
func AdminDeleteBooking(c *gin.Context) {
	id := c.Param("id")
	config.DB.Delete(&models.Booking{}, id)

	c.JSON(200, gin.H{"message": "Booking dihapus"})
}