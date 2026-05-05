package export

import (
	"fmt"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/phpdave11/gofpdf"
)

func ExportDailyPDF(c *gin.Context) {
	generateFilteredPDF(c, "daily")
}

func ExportWeeklyPDF(c *gin.Context) {
	generateFilteredPDF(c, "weekly")
}

func ExportMonthlyPDF(c *gin.Context) {
	generateFilteredPDF(c, "monthly")
}

func generateFilteredPDF(c *gin.Context, mode string) {

	var bookings []models.Booking
	now := time.Now()

	switch mode {
	case "daily":
		config.DB.Where("DATE(created_at) = ?", now.Format("2006-01-02")).Find(&bookings)

	case "weekly":
		weekAgo := now.AddDate(0, 0, -7)
		config.DB.Where("created_at BETWEEN ? AND ?", weekAgo, now).Find(&bookings)

	case "monthly":
		config.DB.Where(
			"EXTRACT(MONTH FROM created_at) = ? AND EXTRACT(YEAR FROM created_at) = ?",
			now.Month(), now.Year(),
		).Find(&bookings)

	default:
		c.JSON(400, gin.H{"error": "Mode tidak valid"})
		return
	}

	pdf := gofpdf.New("P", "mm", "A4", "")
	title := fmt.Sprintf("Laporan Booking (%s)", mode)

	buildPDFTable(pdf, bookings, title)

	filename := fmt.Sprintf("booking-%s.pdf", mode)
	pdf.OutputFileAndClose(filename)
	c.File(filename)
}
