package dashboard

import (
	"database/sql"
	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
)

func AdminDashboard(c *gin.Context) {
    var totalPendakiUser int64
    var totalBooking int64
    var totalPending int64
    var totalPendakiBooking int64
    
    var totalPendapatan sql.NullFloat64 

    config.DB.Model(&models.User{}).Where("role = ?", "pendaki").Count(&totalPendakiUser)

    config.DB.Model(&models.Booking{}).Count(&totalBooking)

    config.DB.Model(&models.Booking{}).
        Where("status = ?", "Terbayar").
        Select("SUM(total_harga)").Scan(&totalPendapatan)

    config.DB.Model(&models.Booking{}).
        Where("status = ?", "Menunggu Konfirmasi").
        Count(&totalPending)

    config.DB.Model(&models.Booking{}).
        Select("COALESCE(SUM(jumlah_orang), 0)").
        Scan(&totalPendakiBooking)
    
    pendapatanFinal := 0.0
    if totalPendapatan.Valid {
        pendapatanFinal = totalPendapatan.Float64
    }

    c.JSON(200, gin.H{
        "total_pendaki":         totalPendakiUser,
        "total_booking":         totalBooking,
        "total_pendapatan":      pendapatanFinal, 
        "total_pending":         totalPending,
        "total_pendaki_booking": totalPendakiBooking,  
    })
}