package user

import (
	"gotrip-backend/config"
	"gotrip-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// ==============================
// GET LIST PENDAKI + SEARCH
// ==============================
func GetPendaki(c *gin.Context) {
	search := c.Query("search")

	var users []models.User

	query := config.DB.Where("role = ?", "pendaki")

	if search != "" {
		like := "%" + search + "%"
		query = query.Where("username LIKE ? OR email LIKE ?", like, like)
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

// ==============================
// DELETE PENDAKI
// ==============================
func DeletePendaki(c *gin.Context) {
	id := c.Param("id")

	// Check apakah pendaki ada
	var user models.User
	if err := config.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  "error",
			"message": "Pendaki tidak ditemukan",
		})
		return
	}

	// Delete
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
