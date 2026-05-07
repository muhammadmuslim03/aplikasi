package route

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UpdateHikingRouteStatusRequest struct {
	IsOpen       *bool  `json:"is_open" binding:"required"`
	ClosedReason string `json:"closed_reason"`
}

func GetHikingRoutes(c *gin.Context) {
	var routes []models.HikingRoute

	if err := config.DB.Order("id ASC").Find(&routes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data jalur"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": routes})
}

func UpdateHikingRouteStatus(c *gin.Context) {
	routeID, err := strconv.Atoi(strings.TrimSpace(c.Param("id")))
	if err != nil || routeID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID jalur tidak valid"})
		return
	}

	var req UpdateHikingRouteStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status jalur wajib diisi"})
		return
	}

	var hikingRoute models.HikingRoute
	if err := config.DB.First(&hikingRoute, "id = ?", routeID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Jalur pendakian tidak ditemukan"})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari jalur pendakian"})
		return
	}

	hikingRoute.IsOpen = *req.IsOpen
	if hikingRoute.IsOpen {
		hikingRoute.ClosedReason = ""
	} else {
		hikingRoute.ClosedReason = strings.TrimSpace(req.ClosedReason)
	}

	if err := config.DB.Save(&hikingRoute).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status jalur"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Status jalur diperbarui",
		"data":    hikingRoute,
	})
}
