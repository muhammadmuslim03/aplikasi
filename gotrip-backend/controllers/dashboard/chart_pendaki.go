package dashboard

import (
	"gotrip-backend/config"

	"github.com/gin-gonic/gin"
)

func ChartPendaki(c *gin.Context) {
	type Result struct {
		Bulan string `json:"bulan"`
		Total int64  `json:"total"`
	}

	var result []Result

	config.DB.Raw(`
		SELECT TO_CHAR(created_at, 'YYYY-MM') AS bulan,
			   COUNT(*) AS total
		FROM users
		WHERE role = 'pendaki'
		GROUP BY bulan
		ORDER BY bulan ASC
	`).Scan(&result)

	c.JSON(200, gin.H{"data": result})
}