package services

import (
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"time"

	"gotrip-backend/models"

	"gorm.io/gorm"
)

func ApplyMidtransNotification(db *gorm.DB, notification MidtransNotification, midtransService *MidtransService) (*models.Payment, *models.Booking, error) {
	var savedPayment models.Payment
	var savedTicket models.Booking

	err := db.Transaction(func(tx *gorm.DB) error {
		payment, ticket, err := findPaymentAndTicketByOrderID(tx, notification.OrderID)
		if err != nil {
			return err
		}

		if err := validateNotificationAmount(notification, payment, ticket); err != nil {
			return err
		}

		mappedStatus := midtransService.MapMidtransStatus(notification.TransactionStatus, notification.FraudStatus)
		now := time.Now()

		payment.Provider = midtransService.ProviderName()
		payment.ProviderTransactionID = notification.OrderID
		payment.PaymentMethod = notification.EffectivePaymentMethod()
		payment.VANumber = notification.FirstVANumber()
		payment.QRString = notification.QRString

		if payment.Amount == 0 {
			payment.Amount = ticket.TotalPrice
		}

		// Once a ticket is paid, later duplicate/non-terminal notifications must not downgrade it.
		if payment.Status == "paid" || ticket.Status == "paid" {
			if mappedStatus == "paid" {
				payment.Status = "paid"
				if payment.PaidAt == nil {
					payment.PaidAt = &now
				}
				payment.VerifiedAt = &now
				if ticket.QRCodeData == nil || *ticket.QRCodeData == "" {
					qrData, err := GenerateTicketQRCodeData(ticket)
					if err != nil {
						return err
					}
					ticket.QRCodeData = &qrData
				}
			}
		} else {
			switch mappedStatus {
			case "paid":
				payment.Status = "paid"
				payment.PaidAt = &now
				payment.VerifiedAt = &now
				ticket.Status = "paid"

				qrData, err := GenerateTicketQRCodeData(ticket)
				if err != nil {
					return err
				}
				ticket.QRCodeData = &qrData

			case "expired":
				payment.Status = "expired"
				ticket.Status = "expired"

			case "cancelled":
				payment.Status = "cancelled"
				ticket.Status = "cancelled"

			case "failed":
				payment.Status = "failed"
				ticket.Status = "pending"

			case "refunded":
				payment.Status = "refunded"

			case "pending":
				fallthrough
			default:
				payment.Status = "pending"
				ticket.Status = "pending"
			}
		}

		if err := tx.Save(&ticket).Error; err != nil {
			return err
		}

		if err := tx.Save(payment).Error; err != nil {
			return err
		}

		savedPayment = *payment
		savedTicket = ticket

		return nil
	})

	if err != nil {
		return nil, nil, err
	}

	return &savedPayment, &savedTicket, nil
}

func findPaymentAndTicketByOrderID(tx *gorm.DB, orderID string) (*models.Payment, models.Booking, error) {
	var payment models.Payment
	if err := tx.Where("provider_transaction_id = ?", orderID).First(&payment).Error; err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, models.Booking{}, err
		}

		ticketID := TicketIDFromMidtransOrderID(orderID)
		if ticketID == "" {
			return nil, models.Booking{}, gorm.ErrRecordNotFound
		}

		if err := tx.Where("booking_id = ?", ticketID).First(&payment).Error; err != nil {
			return nil, models.Booking{}, err
		}
	}

	var ticket models.Booking
	if err := tx.First(&ticket, "id = ?", payment.BookingID).Error; err != nil {
		return nil, models.Booking{}, err
	}

	return &payment, ticket, nil
}

func validateNotificationAmount(notification MidtransNotification, payment *models.Payment, ticket models.Booking) error {
	if notification.GrossAmount == "" {
		return errors.New("gross_amount kosong")
	}

	grossAmount, err := strconv.ParseFloat(notification.GrossAmount, 64)
	if err != nil {
		return fmt.Errorf("gross_amount tidak valid: %w", err)
	}

	expectedAmount := payment.Amount
	if expectedAmount == 0 {
		expectedAmount = ticket.TotalPrice
	}

	if math.Abs(grossAmount-expectedAmount) > 1 {
		return fmt.Errorf("gross_amount %.2f tidak sesuai dengan amount %.2f", grossAmount, expectedAmount)
	}

	return nil
}

func TicketIDFromMidtransOrderID(orderID string) string {
	value := strings.TrimSpace(orderID)
	if !strings.HasPrefix(value, "GOTRIP-") {
		return ""
	}

	value = strings.TrimPrefix(value, "GOTRIP-")
	lastDash := strings.LastIndex(value, "-")
	if lastDash <= 0 {
		return ""
	}

	return value[:lastDash]
}
