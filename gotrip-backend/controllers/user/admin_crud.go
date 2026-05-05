package user

import (
	"errors"
	"net/http"
	"strconv"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GetPendaki(c *gin.Context) {
	search := c.Query("search")

	var users []models.User

	query := config.DB.Where("role = ?", "pendaki")

	if search != "" {
		like := "%" + search + "%"
		query = query.Where("name ILIKE ? OR email ILIKE ?", like, like)
	}

	if err := query.Order("created_at DESC").Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  "error",
			"message": "Gagal mengambil data pendaki",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   users,
	})
}

func DeletePendaki(c *gin.Context) {
	idParam := c.Param("id")

	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(400, gin.H{
			"status":  "error",
			"message": "ID tidak valid",
		})
		return
	}

	var user models.User
	if err := config.DB.Where("id = ? AND role = ?", id, "pendaki").First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"status":  "error",
				"message": "Pendaki tidak ditemukan",
			})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  "error",
			"message": "Gagal mencari pendaki",
		})
		return
	}

	if err := config.DB.Delete(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  "error",
			"message": "Gagal menghapus pendaki",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Pendaki berhasil dihapus",
	})
}
