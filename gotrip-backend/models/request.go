package models

type CreateBookingRequest struct {
	RouteID      int     `json:"route_id" binding:"required"`
	HikingDate   string  `json:"hiking_date" binding:"required"`
	TotalMembers int     `json:"total_members" binding:"required"`
	TotalPrice   float64 `json:"total_price" binding:"required"`

	IncludeOjek bool `json:"include_ojek"`
	OjekCount   int  `json:"ojek_count"`
}

type CreateTicketRequest = CreateBookingRequest
