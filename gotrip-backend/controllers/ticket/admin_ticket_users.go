package ticket

import (
	"gotrip-backend/config"
	"gotrip-backend/models"
)

func attachUsersToBookings(bookings []models.Booking) {
	userIDs := make([]uint, 0, len(bookings))
	seen := make(map[uint]bool)

	for _, booking := range bookings {
		if booking.UserID == 0 || seen[booking.UserID] {
			continue
		}

		seen[booking.UserID] = true
		userIDs = append(userIDs, booking.UserID)
	}

	if len(userIDs) == 0 {
		return
	}

	var users []models.User
	if err := config.DB.Where("id IN ?", userIDs).Find(&users).Error; err != nil {
		return
	}

	usersByID := make(map[uint]*models.User, len(users))
	for i := range users {
		usersByID[users[i].ID] = &users[i]
	}

	for i := range bookings {
		bookings[i].User = usersByID[bookings[i].UserID]
	}
}

func attachUserToBooking(booking *models.Booking) {
	if booking.UserID == 0 {
		return
	}

	var user models.User
	if err := config.DB.First(&user, booking.UserID).Error; err != nil {
		return
	}

	booking.User = &user
}

func attachPaymentFields(bookings []models.Booking) {
	for i := range bookings {
		attachPaymentField(&bookings[i])
	}
}

func attachPaymentField(booking *models.Booking) {
	if booking.Payment == nil {
		return
	}

	if booking.ProofImage == "" {
		booking.ProofImage = booking.Payment.ProofImage
	}
	booking.PaymentMethod = booking.Payment.PaymentMethod
	booking.PaymentStatus = booking.Payment.Status

	if booking.RejectNote == nil {
		booking.RejectNote = booking.Payment.RejectNote
	}
}
