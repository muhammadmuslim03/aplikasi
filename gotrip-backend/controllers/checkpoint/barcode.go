package checkpoint

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

const (
	CheckInCode  = "GOTRIP_CHECK_IN"
	CheckOutCode = "GOTRIP_CHECK_OUT"
)

type ScanRequest struct {
	Code string `json:"code" binding:"required"`
}

func GetBarcodes(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"check_in": gin.H{
				"label": "Barcode Check-in",
				"code":  CheckInCode,
			},
			"check_out": gin.H{
				"label": "Barcode Check-out",
				"code":  CheckOutCode,
			},
		},
	})
}

func ScanBarcode(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req ScanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kode barcode wajib diisi"})
		return
	}

	code := strings.ToUpper(strings.TrimSpace(req.Code))

	switch code {
	case CheckInCode:
		handleCheckIn(c, userID)
	case CheckOutCode:
		handleCheckOut(c, userID)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Barcode tidak valid"})
	}
}

func handleCheckIn(c *gin.Context, userID uint) {
	var booking models.Booking
	var user models.User
	now := time.Now()

	err := config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.First(&user, userID).Error; err != nil {
			return err
		}

		if err := tx.
			Where("user_id = ? AND status = ?", userID, "paid").
			Order("hiking_date ASC, created_at ASC").
			First(&booking).Error; err != nil {
			return err
		}

		booking.Status = "checked_in"
		booking.CheckedInAt = &now

		user.CheckIn = true
		user.CheckOut = false
		user.CheckInAt = &now
		user.CheckOutAt = nil

		if err := tx.Save(&booking).Error; err != nil {
			return err
		}

		return tx.Save(&user).Error
	})
	if err != nil {
		writeScanError(c, err, "Tidak ada booking terbayar yang siap check-in")
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Check-in berhasil",
		"action":  "check_in",
		"data": gin.H{
			"booking": booking,
			"user":    user,
		},
	})
}

func handleCheckOut(c *gin.Context, userID uint) {
	var booking models.Booking
	var user models.User
	now := time.Now()

	err := config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.First(&user, userID).Error; err != nil {
			return err
		}

		if err := tx.
			Where("user_id = ? AND status = ?", userID, "checked_in").
			Order("checked_in_at DESC, updated_at DESC").
			First(&booking).Error; err != nil {
			return err
		}

		booking.Status = "checked_out"
		booking.CheckedOutAt = &now

		user.CheckIn = false
		user.CheckOut = true
		user.CheckOutAt = &now

		if err := tx.Save(&booking).Error; err != nil {
			return err
		}

		return tx.Save(&user).Error
	})
	if err != nil {
		writeScanError(c, err, "Tidak ada booking aktif yang bisa check-out")
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Check-out berhasil",
		"action":  "check_out",
		"data": gin.H{
			"booking": booking,
			"user":    user,
		},
	})
}

func writeScanError(c *gin.Context, err error, notFoundMessage string) {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		c.JSON(http.StatusNotFound, gin.H{"error": notFoundMessage})
		return
	}

	c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses barcode"})
}
