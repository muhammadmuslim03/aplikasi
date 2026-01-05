package auth

import (
	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// ================= REGISTER =================
func Register(c *gin.Context) {
	var input models.RegisterRequest
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	// ✅ Validasi password dan konfirmasi
	if input.Password != input.ConfirmPassword {
		c.JSON(400, gin.H{"error": "Password dan konfirmasi tidak sama"})
		return
	}

	// ✅ Cek apakah email sudah terdaftar
	var existing models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existing).Error; err == nil {
		c.JSON(400, gin.H{"error": "Email sudah terdaftar"})
		return
	}

	// ✅ Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), 14)
	if err != nil {
		c.JSON(500, gin.H{"error": "Gagal mengenkripsi password"})
		return
	}

	// ✅ Gunakan role dari input jika ada, default ke "pendaki"
	role := input.Role
	if role == "" {
		role = "pendaki"
	}

	// ✅ Buat user baru
	user := models.User{
		Username: input.Username,
		Email:    input.Email,
		Password: string(hashedPassword),
		Role:     role,
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": "Gagal menyimpan user"})
		return
	}

	c.JSON(200, gin.H{
		"message": "Registrasi berhasil! Silakan login.",
		"user": gin.H{
			"id":       user.ID,
			"username": user.Username,
			"email":    user.Email,
			"role":     user.Role,
		},
	})
}