package services

import (
	"encoding/json"

	"gotrip-backend/models"
)

func GenerateTicketQRCodeData(ticket models.Booking) (string, error) {
	payload := map[string]interface{}{
		"ticket_id":   ticket.ID,
		"user_id":     ticket.UserID,
		"route_name":  ticket.RouteName,
		"hiking_date": ticket.HikingDate.Format("2006-01-02"),
		"status":      "paid",
	}

	data, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	return string(data), nil
}
