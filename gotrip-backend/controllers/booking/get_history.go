package booking

import (
    "net/http"

    "gotrip-backend/config"
    "gotrip-backend/models"

    "github.com/gin-gonic/gin"
)

// GetHistory untuk pendaki (Booking per user)
func GetHistory(c *gin.Context) {
    userID, _ := c.Get("user_id")
    uid := userID.(uint)

    var bookings []models.Booking

    if err := config.DB.Where("user_id = ?", uid).
        Order("created_at DESC").
        Find(&bookings).Error; err != nil {

        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Gagal mengambil history",
        })
        return
    }

    var history []gin.H
    for _, b := range bookings {
        
        // 🔥 LOGIKA BARU: Mengambil nilai string dari pointer (b.RejectNote)
        var rejectNoteValue string
        if b.RejectNote != nil {
            // Jika pointer tidak nil, ambil nilainya
            rejectNoteValue = *b.RejectNote 
        }
        
        history = append(history, gin.H{
            "id":            b.ID,
            "nama":          b.Nama,
            "email":         b.Email,
            "telepon":       b.Telepon,
            "darurat":       b.Darurat,
            "tanggal":       b.Tanggal.Format("2006-01-02"),
            "jumlah_orang":  b.JumlahOrang,
            "jumlah_ojek":   b.JumlahOjek,
            "termasuk_ojek": b.TermasukOjek,
            "total_harga":   b.TotalHarga,
            "status":        b.Status,
            "proof_image":   b.ProofImage,
            // Mengirimkan string biasa (bukan pointer) ke JSON
            "reject_note":   rejectNoteValue, 
        })
    }

    c.JSON(http.StatusOK, gin.H{
        "history": history,
    })
}