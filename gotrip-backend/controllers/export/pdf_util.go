package export

import (
	"fmt"

	"gotrip-backend/models"

	"github.com/phpdave11/gofpdf"
)

var headers = []string{"No", "User ID", "Tanggal Naik", "Total", "Status"}
var colWidths = []float64{10, 30, 50, 40, 40}

func buildPDFTable(pdf *gofpdf.Fpdf, bookings []models.Booking, title string) {

	pdf.AddPage()
	pdf.SetFont("Arial", "B", 16)

	pdf.Cell(0, 10, title)
	pdf.Ln(12)

	// HEADER
	pdf.SetFont("Arial", "B", 12)
	pdf.SetFillColor(52, 152, 219)
	pdf.SetTextColor(255, 255, 255)

	for i, h := range headers {
		pdf.CellFormat(colWidths[i], 10, h, "1", 0, "C", true, 0, "")
	}
	pdf.Ln(-1)

	// BODY
	pdf.SetFont("Arial", "", 11)
	pdf.SetTextColor(0, 0, 0)

	for i, booking := range bookings {
		row := []string{
			fmt.Sprintf("%d", i+1),
			fmt.Sprintf("%d", booking.UserID),
			booking.HikingDate.Format("2006-01-02"),
			fmt.Sprintf("Rp %d", int(booking.TotalPrice)),
			booking.Status,
		}

		for j, col := range row {
			pdf.CellFormat(colWidths[j], 9, col, "1", 0, "C", false, 0, "")
		}
		pdf.Ln(-1)
	}
}
