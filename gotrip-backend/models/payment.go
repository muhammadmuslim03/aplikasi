package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Payment struct {
	ID        string `gorm:"type:uuid;primaryKey" json:"id"`
	BookingID string `gorm:"type:uuid;index;unique" json:"ticket_id"`
	UserID    uint   `json:"user_id"`

	Provider              string     `gorm:"type:varchar(40);default:'manual'" json:"provider"`
	ProviderTransactionID string     `gorm:"type:varchar(120);index" json:"provider_transaction_id"`
	PaymentMethod         string     `gorm:"column:method" json:"payment_method"`
	Amount                float64    `json:"amount"`
	Status                string     `gorm:"type:varchar(40);default:'pending'" json:"status"`
	PaymentURL            string     `gorm:"type:text" json:"payment_url"`
	SnapToken             string     `gorm:"type:text" json:"snap_token"`
	VANumber              string     `gorm:"type:varchar(120)" json:"va_number"`
	QRString              string     `gorm:"type:text" json:"qr_string"`
	ExpiredAt             *time.Time `json:"expired_at"`
	PaidAt                *time.Time `json:"paid_at"`

	ProofImage string     `json:"proof_image"`
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
