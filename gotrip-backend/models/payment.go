package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Payment struct {
	ID         string     `gorm:"type:uuid;primaryKey" json:"id"`
	BookingID  string     `gorm:"type:uuid;index;unique" json:"booking_id"`
	UserID     uint       `json:"user_id"`
	Method     string     `json:"method"`
	ProofImage string     `json:"proof_image"`
	Status     string     `gorm:"type:varchar(40);default:'pending'" json:"status"`
	RejectNote *string    `json:"reject_note"`
	VerifiedAt *time.Time `json:"verified_at"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
}

func (Payment) TableName() string {
	return "payments"
}

func (p *Payment) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == "" {
		p.ID = uuid.New().String()
	}
	return
}
