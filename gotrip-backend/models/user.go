package models

import "time"

// === USER (Database Model) ===
type User struct {
    ID        uint      `gorm:"primaryKey" json:"id"`
    Username  string    `gorm:"not null" json:"username"`
    Email     string    `gorm:"unique;not null" json:"email"`
    Password  string    `gorm:"not null" json:"-"`
    Role      string    `gorm:"type:varchar(20);default:'pendaki'" json:"role"`
    CreatedAt time.Time `json:"created_at"`
}

// === USER RESPONSE (Data User yang Aman untuk ditampilkan) ===
type UserResponse struct {
    ID       uint   `json:"id"`
    Username string `json:"username"`
    Email    string `json:"email"`
    Role     string `json:"role"`
}