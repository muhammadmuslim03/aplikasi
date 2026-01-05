package dashboard

import (
    "gotrip-backend/config"

    "github.com/gin-gonic/gin"
)

func ChartPendapatan(c *gin.Context) {
    type Result struct {
        Bulan string  `json:"bulan"`
        Total float64 `json:"total"`
    }

    var result []Result

    config.DB.Raw(`
        SELECT TO_CHAR(created_at, 'YYYY-MM') AS bulan,
               COALESCE(SUM(total_harga), 0) AS total
        FROM bookings
        WHERE status = 'Terbayar'
        GROUP BY bulan
        ORDER BY bulan ASC
    `).Scan(&result)

    c.JSON(200, gin.H{"data": result})
}