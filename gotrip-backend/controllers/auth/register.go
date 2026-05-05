package auth

import (
	"gotrip-backend/config"
	"gotrip-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func Register(c *gin.Context) {
	var input models.RegisterRequest

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	var existing models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existing).Error; err == nil {
		c.JSON(400, gin.H{"error": "Email sudah terdaftar"})
		return
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(input.Password), 14)

	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Phone:    input.Phone,
		NIK:      input.NIK,
		Password: string(hashedPassword),
		Role:     "pendaki",
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": "Gagal menyimpan user"})
		return
	}

	c.JSON(201, gin.H{
		"message": "Registrasi berhasil",
	})
}

func InitAdmin(c *gin.Context) {
	var count int64
	config.DB.Model(&models.User{}).Where("role = ?", "admin").Count(&count)

	if count > 0 {
		c.JSON(403, gin.H{"error": "Admin sudah ada"})
		return
	}

	var input models.RegisterRequest
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(input.Password), 14)

	admin := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Phone:    input.Phone,
		NIK:      input.NIK,
		Password: string(hashedPassword),
		Role:     "admin",
	}

	config.DB.Create(&admin)

	c.JSON(201, gin.H{
		"message": "Admin pertama berhasil dibuat",
	})
}

func RegisterAdmin(c *gin.Context) {
	var input models.RegisterRequest

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	var existing models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email sudah terdaftar",
		})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), 14)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal hash password",
		})
		return
	}

	admin := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Phone:    input.Phone,
		NIK:      input.NIK,
		Password: string(hashedPassword),
		Role:     "admin",
	}

	if err := config.DB.Create(&admin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal membuat admin",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Admin berhasil dibuat",
		"data": gin.H{
			"id":    admin.ID,
			"email": admin.Email,
			"role":  admin.Role,
		},
	})
}