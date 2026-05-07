package models

import "time"

type HikingRoute struct {
	ID           int       `gorm:"primaryKey;autoIncrement:false" json:"id"`
	RouteName    string    `gorm:"type:varchar(120);not null" json:"route_name"`
	Description  string    `gorm:"type:text" json:"description"`
	IsOpen       bool      `gorm:"not null;default:true" json:"is_open"`
	ClosedReason string    `gorm:"type:text" json:"closed_reason,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

func (HikingRoute) TableName() string {
	return "hiking_routes"
}
