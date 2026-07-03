package auth

import (
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

func Login(c *gin.Context) {
	var input models.LoginRequest

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	if input.Client == "" {
		input.Client = "mobile"
	}

	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(401, gin.H{"error": "Email atau password salah"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		c.JSON(401, gin.H{"error": "Email atau password salah"})
		return
	}

	if user.Role == "admin" && input.Client == "mobile" {
		c.JSON(403, gin.H{"error": "Admin hanya bisa login di web admin"})
		return
	}

	if user.Role == "pendaki" && input.Client == "admin" {
		c.JSON(403, gin.H{"error": "User tidak bisa login di admin"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 24 * 7).Unix(),
	})

	tokenString, _ := token.SignedString(config.JWTSecret())

	c.JSON(200, models.AuthResponse{
		Token: tokenString,
		User: models.UserResponse{
			ID:         user.ID,
			Name:       user.Name,
			Email:      user.Email,
			Phone:      user.Phone,
			NIK:        user.NIK,
			Role:       user.Role,
			CheckIn:    user.CheckIn,
			CheckOut:   user.CheckOut,
			CheckInAt:  user.CheckInAt,
			CheckOutAt: user.CheckOutAt,
		},
	})
}
