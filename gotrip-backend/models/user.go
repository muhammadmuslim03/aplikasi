package models

import "time"

type User struct {
	ID         uint       `json:"id" gorm:"primaryKey"`
	Name       string     `json:"name"`
	Email      string     `json:"email" gorm:"unique"`
	Password   string     `json:"-"`
	Phone      string     `json:"phone"`
	NIK        string     `json:"nik" gorm:"unique"`
	Role       string     `json:"role" gorm:"type:varchar(20);default:'pendaki'"`
	CheckIn    bool       `json:"check_in" gorm:"default:false"`
	CheckOut   bool       `json:"check_out" gorm:"default:false"`
	CheckInAt  *time.Time `json:"check_in_at"`
	CheckOutAt *time.Time `json:"check_out_at"`
	CreatedAt  time.Time  `json:"created_at"`
}

type UserResponse struct {
	ID         uint       `json:"id"`
	Name       string     `json:"name"`
	Email      string     `json:"email"`
	Phone      string     `json:"phone"`
	NIK        string     `json:"nik"`
	Role       string     `json:"role"`
	CheckIn    bool       `json:"check_in"`
	CheckOut   bool       `json:"check_out"`
	CheckInAt  *time.Time `json:"check_in_at"`
	CheckOutAt *time.Time `json:"check_out_at"`
}
