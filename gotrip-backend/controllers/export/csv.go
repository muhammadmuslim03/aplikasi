package export

import (
	"encoding/csv"
	"fmt"
	"net/http"
	"os"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

func ExportCSV(c *gin.Context) {
	filePath := "booking-export.csv"

	file, err := os.Create(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal membuat file CSV",
		})
		return
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// HEADER
	if err := writer.Write([]string{
		"ID",
		"User ID",
		"Route ID",
		"Booking Date",
		"Hiking Date",
		"Total Members",
		"Total Price",
		"Status",
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal menulis header CSV",
		})
		return
	}

	var bookings []models.Booking

	if err := config.DB.Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal mengambil data booking",
		})
		return
	}

	// DATA
	for _, booking := range bookings {

		bookingDate := ""
		hikingDate := ""

		if !booking.BookingDate.IsZero() {
			bookingDate = booking.BookingDate.Format("2006-01-02")
		}

		if !booking.HikingDate.IsZero() {
			hikingDate = booking.HikingDate.Format("2006-01-02")
		}

		row := []string{
			booking.ID,
			fmt.Sprintf("%d", booking.UserID),
			fmt.Sprintf("%d", booking.RouteID),
			bookingDate,
			hikingDate,
			fmt.Sprintf("%d", booking.TotalMembers),
			fmt.Sprintf("%.0f", booking.TotalPrice),
			booking.Status,
		}

		if err := writer.Write(row); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Gagal menulis data CSV",
			})
			return
		}
	}

	writer.Flush()

	// Kirim file ke client
	c.Header("Content-Description", "File Transfer")
	c.Header("Content-Disposition", "attachment; filename="+filePath)
	c.Header("Content-Type", "text/csv")

	c.File(filePath)
}
