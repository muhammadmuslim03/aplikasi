package dashboard

import (
	"database/sql"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

func AdminDashboard(c *gin.Context) {

	var totalUsers int64
	var totalBookings int64
	var totalPending int64
	var totalHikers int64
	var totalActiveHikers int64
	var totalFinishedHikers int64

	var totalRevenue sql.NullFloat64
	paidStatuses := []string{"paid", "checked_in", "checked_out"}

	// jumlah user pendaki
	config.DB.Model(&models.User{}).
		Where("role = ?", "pendaki").
		Count(&totalUsers)

	// total booking
	config.DB.Model(&models.Booking{}).
		Count(&totalBookings)

	// pending
	config.DB.Model(&models.Booking{}).
		Where("status = ?", "pending").
		Count(&totalPending)

	// pendapatan
	config.DB.Model(&models.Booking{}).
		Where("status IN ?", paidStatuses).
		Select("COALESCE(SUM(total_price),0)").
		Scan(&totalRevenue)

	// total pendaki dari booking
	config.DB.Model(&models.Booking{}).
		Select("COALESCE(SUM(total_members),0)").
		Scan(&totalHikers)

	// pendaki yang sedang berada di jalur
	config.DB.Model(&models.Booking{}).
		Where("status = ?", "checked_in").
		Select("COALESCE(SUM(total_members),0)").
		Scan(&totalActiveHikers)

	// pendaki yang sudah selesai dan check-out
	config.DB.Model(&models.Booking{}).
		Where("status = ?", "checked_out").
		Select("COALESCE(SUM(total_members),0)").
		Scan(&totalFinishedHikers)

	finalRevenue := 0.0
	if totalRevenue.Valid {
		finalRevenue = totalRevenue.Float64
	}

	c.JSON(200, gin.H{
		"total_users":           totalUsers,
		"total_tickets":         totalBookings,
		"total_bookings":        totalBookings,
		"total_pending":         totalPending,
		"total_revenue":         finalRevenue,
		"total_hikers":          totalHikers,
		"total_active_hikers":   totalActiveHikers,
		"total_finished_hikers": totalFinishedHikers,
	})
}
