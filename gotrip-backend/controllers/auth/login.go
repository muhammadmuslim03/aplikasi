package auth

import (
    "time"

    "gotrip-backend/config"
    "gotrip-backend/models"

    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"
    "golang.org/x/crypto/bcrypt"
)

var jwtSecret = []byte("your-secret-key-go-trip-2025")

// ================= LOGIN =================
func Login(c *gin.Context) {
    var input models.LoginRequest
    if err := c.ShouldBindJSON(&input); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }

    // Cari user berdasarkan email
    var user models.User
    if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
        c.JSON(401, gin.H{"error": "Email atau password salah"})
        return
    }

    // Cek password
    if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
        c.JSON(401, gin.H{"error": "Email atau password salah"})
        return
    }

    // ================================
    // 🔥 VALIDASI ROLE
    // ================================
    if input.Role != "" && input.Role != user.Role {
        c.JSON(403, gin.H{
            "error": "Akses ditolak: Anda tidak memiliki hak login ke aplikasi ini",
        })
        return
    }

    // Generate JWT
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
        "user_id": user.ID,
        "role":    user.Role,
        "exp":     time.Now().Add(time.Hour * 24 * 7).Unix(),
    })

    tokenString, err := token.SignedString(jwtSecret)
    if err != nil {
        c.JSON(500, gin.H{"error": "Gagal membuat token"})
        return
    }

    c.JSON(200, models.AuthResponse{
        Token: tokenString,
        User: models.UserResponse{
            ID:       user.ID,
            Username: user.Username,
            Email:    user.Email,
            Role:     user.Role,
        },
    })
}
