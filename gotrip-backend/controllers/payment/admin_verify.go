package payment

import (
    "gotrip-backend/config"
    "gotrip-backend/models"
    "net/http"
    "github.com/gin-gonic/gin"
)

type VerifyRequest struct {
    Action     string `json:"action" binding:"required"` // "accept" atau "reject"
    RejectNote string `json:"reject_note"`               // opsional
}

func AdminVerifyPayment(c *gin.Context) {
    id := c.Param("id")

    var req VerifyRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
        return
    }

    var booking models.Booking
    if err := config.DB.First(&booking, id).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
        return
    }

    // PROSES VERIFIKASI
    if req.Action == "accept" {
        booking.Status = "Lunas"
        booking.RejectNote = nil 
    } else if req.Action == "reject" {
        booking.Status = "Ditolak"
        
        note := req.RejectNote
        booking.RejectNote = &note 

    } else {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Action tidak valid"})
        return
    }

    config.DB.Save(&booking)

    c.JSON(200, gin.H{
        "message": "Status pembayaran diperbarui",
        "data":    booking,
    })
}