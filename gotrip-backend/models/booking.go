package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Booking struct {
	ID        string `gorm:"type:uuid;primaryKey" json:"id"`
	UserID    uint   `json:"user_id"`
	User      *User  `gorm:"-" json:"user,omitempty"`
	RouteID   int    `json:"route_id"`
	RouteName string `json:"route_name"`

	BookingDate time.Time `json:"booking_date"`
	HikingDate  time.Time `json:"hiking_date"`

	TotalMembers int     `json:"total_members"`
	TotalPrice   float64 `json:"total_price"`

	IncludeOjek bool `json:"include_ojek"`
	OjekCount   int  `json:"ojek_count"`

	Status        string     `gorm:"type:varchar(40);default:'pending'" json:"status"`
	RejectNote    *string    `json:"reject_note"`
	CheckedInAt   *time.Time `json:"checked_in_at"`
	CheckedOutAt  *time.Time `json:"checked_out_at"`
	Payment       *Payment   `json:"payment,omitempty"`
	ProofImage    string     `gorm:"-" json:"proof_image,omitempty"`
	PaymentMethod string     `gorm:"-" json:"payment_method,omitempty"`
	PaymentStatus string     `gorm:"-" json:"payment_status,omitempty"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (Booking) TableName() string {
	return "bookings"
}

func (b *Booking) BeforeCreate(tx *gorm.DB) (err error) {
	if b.ID == "" {
		b.ID = uuid.New().String()
	}
	return
}

type Ticket = Booking
