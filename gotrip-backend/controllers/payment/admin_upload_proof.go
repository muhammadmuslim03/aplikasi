package payment

import (
	"fmt"
	"os"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

// AdminUploadProof untuk Admin mengupload bukti
func AdminUploadProof(c *gin.Context) {
	id := c.PostForm("booking_id")

	var booking models.Booking
	if err := config.DB.First(&booking, id).Error; err != nil {
		c.JSON(404, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	file, err := c.FormFile("proof")
	if err != nil {
		c.JSON(400, gin.H{"error": "File tidak ditemukan"})
		return
	}

	filename := fmt.Sprintf("uploads/proof_admin_%d_%d.png", booking.ID, time.Now().Unix())

	os.MkdirAll("uploads", 0755)
	c.SaveUploadedFile(file, filename)

	booking.ProofImage = filename
	config.DB.Save(&booking)

	c.JSON(200, gin.H{
		"message": "Bukti pembayaran berhasil diupload",
		"path":    filename,
	})
}