package export

import (
	"encoding/csv"
	"os"
	"strconv"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

// ExportCSV untuk Admin
func ExportCSV(c *gin.Context) {
	file, err := os.Create("booking-export.csv")
	if err != nil {
		c.JSON(500, gin.H{"error": "Gagal membuat file"})
		return
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	writer.Write([]string{
		"ID", "Nama", "Email", "Tanggal", "Total Harga", "Status",
	})

	var bookings []models.Booking
	config.DB.Find(&bookings)

	for _, b := range bookings {
		writer.Write([]string{
			strconv.Itoa(int(b.ID)),
			b.Nama,
			b.Email,
			b.Tanggal.Format("2006-01-02"),
			strconv.Itoa(b.TotalHarga),
			b.Status,
		})
	}

	c.File("booking-export.csv")
}