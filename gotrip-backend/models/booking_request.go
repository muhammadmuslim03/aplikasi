package models

// === BOOKING REQUEST (Input dari Pendaki) ===
type BookingRequest struct {
    Nama           string `form:"nama" binding:"required"`      
    Email          string `form:"email" binding:"required"`     
    Telepon        string `form:"telepon" binding:"required"`   
    Darurat        string `form:"darurat"`                      
    Tanggal        string `form:"tanggal" binding:"required"`
    JumlahOrang    int    `form:"jumlah_orang" binding:"required,min=1"` 
    JumlahOjek     int    `form:"jumlah_ojek"`                  
    TermasukOjek   bool   `form:"termasuk_ojek"`                
    TotalHarga     string `form:"total_harga" binding:"required"`
}