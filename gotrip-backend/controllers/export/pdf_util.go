package export

import (
	"fmt"

	"gotrip-backend/models"

	"github.com/phpdave11/gofpdf"
)

// Global constants for PDF table
var headers = []string{"No", "Nama", "Tanggal", "Total", "Status"}
var colWidths = []float64{10, 55, 40, 30, 40}

// =====================================================
// 🔵 UTIL: Generate PDF Table (Reusable)
// =====================================================
func buildPDFTable(pdf *gofpdf.Fpdf, bookings []models.Booking, title string) {

	pdf.AddPage()
	pdf.SetFont("Arial", "B", 16)

	// Title
	pdf.Cell(0, 10, title)
	pdf.Ln(12)

	// Header
	pdf.SetFont("Arial", "B", 12)
	pdf.SetFillColor(52, 152, 219)
	pdf.SetTextColor(255, 255, 255)

	for i, h := range headers {
		pdf.CellFormat(colWidths[i], 10, h, "1", 0, "C", true, 0, "")
	}
	pdf.Ln(-1)

	// Body
	pdf.SetFont("Arial", "", 11)
	pdf.SetTextColor(0, 0, 0)

	for idx, b := range bookings {
		row := []string{
			fmt.Sprintf("%d", idx+1),
			b.Nama,
			b.Tanggal.Format("2006-01-02"),
			fmt.Sprintf("Rp %d", b.TotalHarga),
			b.Status,
		}

		for i, col := range row {
			pdf.CellFormat(colWidths[i], 9, col, "1", 0, "C", false, 0, "")
		}

		pdf.Ln(-1)
	}
}
