package export

import (
	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/phpdave11/gofpdf"
)

// =====================================================
// 🔵 EXPORT SEMUA BOOKING
// =====================================================
func ExportAllPDF(c *gin.Context) {
	var bookings []models.Booking
	config.DB.Order("created_at DESC").Find(&bookings)

	pdf := gofpdf.New("P", "mm", "A4", "")
	buildPDFTable(pdf, bookings, "Laporan Booking GOTRIP (Semua Data)")

	filename := "booking-all.pdf"
	pdf.OutputFileAndClose(filename)
	c.File(filename)
}