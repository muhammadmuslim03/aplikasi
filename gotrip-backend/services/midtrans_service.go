package services

import (
	"bytes"
	"crypto/sha512"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"net/http"
	"net/url"
	"strings"
	"time"

	"gotrip-backend/config"
	"gotrip-backend/models"
)

const midtransProvider = "midtrans"

var ErrMidtransConfig = errors.New("konfigurasi Midtrans belum lengkap")

type MidtransService struct {
	ServerKey       string
	Environment     string
	NotificationURL string
	AppBaseURL      string
	HTTPClient      *http.Client
}

type MidtransTransaction struct {
	OrderID    string
	SnapToken  string
	PaymentURL string
	ExpiredAt  time.Time
	Amount     float64
}

type MidtransVANumber struct {
	Bank     string `json:"bank"`
	VANumber string `json:"va_number"`
}

type MidtransNotification struct {
	TransactionTime   string             `json:"transaction_time"`
	TransactionStatus string             `json:"transaction_status"`
	TransactionID     string             `json:"transaction_id"`
	StatusMessage     string             `json:"status_message"`
	StatusCode        string             `json:"status_code"`
	SignatureKey      string             `json:"signature_key"`
	PaymentType       string             `json:"payment_type"`
	OrderID           string             `json:"order_id"`
	GrossAmount       string             `json:"gross_amount"`
	FraudStatus       string             `json:"fraud_status"`
	VANumbers         []MidtransVANumber `json:"va_numbers"`
	PermataVANumber   string             `json:"permata_va_number"`
	QRString          string             `json:"qr_string"`
}

type MidtransStatusResponse struct {
	TransactionStatus string             `json:"transaction_status"`
	TransactionID     string             `json:"transaction_id"`
	StatusCode        string             `json:"status_code"`
	StatusMessage     string             `json:"status_message"`
	PaymentType       string             `json:"payment_type"`
	OrderID           string             `json:"order_id"`
	GrossAmount       string             `json:"gross_amount"`
	FraudStatus       string             `json:"fraud_status"`
	VANumbers         []MidtransVANumber `json:"va_numbers"`
	PermataVANumber   string             `json:"permata_va_number"`
	QRString          string             `json:"qr_string"`
}

func NewMidtransServiceFromEnv() (*MidtransService, error) {
	serverKey := config.Env("MIDTRANS_SERVER_KEY", "")
	if serverKey == "" {
		return nil, fmt.Errorf("%w: MIDTRANS_SERVER_KEY belum dikonfigurasi", ErrMidtransConfig)
	}

	environment := strings.ToLower(config.Env("MIDTRANS_ENVIRONMENT", "sandbox"))
	if environment != "production" {
		environment = "sandbox"
	}

	return &MidtransService{
		ServerKey:       serverKey,
		Environment:     environment,
		NotificationURL: config.Env("MIDTRANS_NOTIFICATION_URL", ""),
		AppBaseURL:      strings.TrimRight(config.Env("APP_BASE_URL", ""), "/"),
		HTTPClient:      &http.Client{Timeout: 20 * time.Second},
	}, nil
}

func (s *MidtransService) ProviderName() string {
	return midtransProvider
}

func (s *MidtransService) CreateTransaction(ticket models.Booking, user models.User) (*MidtransTransaction, error) {
	orderID := fmt.Sprintf("GOTRIP-%s-%d", ticket.ID, time.Now().Unix())
	amount := int64(math.Round(ticket.TotalPrice))
	if amount <= 0 {
		return nil, errors.New("total pembayaran tidak valid")
	}

	expiryMinutes := config.EnvInt("MIDTRANS_PAYMENT_EXPIRY_MINUTES", 60)
	if expiryMinutes <= 0 {
		expiryMinutes = 60
	}

	expiredAt := time.Now().Add(time.Duration(expiryMinutes) * time.Minute)
	payload := snapRequest{
		TransactionDetails: snapTransactionDetails{
			OrderID:  orderID,
			GrossAmt: amount,
		},
		EnabledPayments: []string{"qris", "bca_va", "bni_va", "bri_va", "permata_va", "other_va"},
		ItemDetails: []snapItemDetail{
			{
				ID:    ticket.ID,
				Price: amount,
				Qty:   1,
				Name:  fmt.Sprintf("Tiket Pendakian GOTRIP - %s", ticket.RouteName),
			},
		},
		CustomerDetails: snapCustomerDetails{
			FirstName: user.Name,
			Email:     user.Email,
			Phone:     user.Phone,
		},
		Expiry: &snapExpiry{
			StartTime: time.Now().Format("2006-01-02 15:04:05 -0700"),
			Unit:      "minute",
			Duration:  expiryMinutes,
		},
		CustomField1: ticket.ID,
		CustomField2: fmt.Sprintf("%d", user.ID),
	}

	if s.AppBaseURL != "" {
		payload.Callbacks = &snapCallbacks{
			Finish: fmt.Sprintf("%s/payment/finish?ticket_id=%s", s.AppBaseURL, url.QueryEscape(ticket.ID)),
		}
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest(http.MethodPost, s.snapTransactionURL(), bytes.NewReader(body))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.SetBasicAuth(s.ServerKey, "")

	res, err := s.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	resBody, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	if res.StatusCode < http.StatusOK || res.StatusCode >= http.StatusMultipleChoices {
		return nil, fmt.Errorf("midtrans create transaction gagal: status=%d body=%s", res.StatusCode, string(resBody))
	}

	var snapRes snapResponse
	if err := json.Unmarshal(resBody, &snapRes); err != nil {
		return nil, err
	}

	if snapRes.Token == "" || snapRes.RedirectURL == "" {
		return nil, errors.New("response Midtrans tidak berisi token atau redirect_url")
	}

	return &MidtransTransaction{
		OrderID:    orderID,
		SnapToken:  snapRes.Token,
		PaymentURL: snapRes.RedirectURL,
		ExpiredAt:  expiredAt,
		Amount:     float64(amount),
	}, nil
}

func (s *MidtransService) VerifySignature(notification MidtransNotification) bool {
	if s.ServerKey == "" || notification.SignatureKey == "" {
		return false
	}

	plain := notification.OrderID + notification.StatusCode + notification.GrossAmount + s.ServerKey
	hash := sha512.Sum512([]byte(plain))
	expected := hex.EncodeToString(hash[:])

	return subtle.ConstantTimeCompare([]byte(expected), []byte(notification.SignatureKey)) == 1
}

func (s *MidtransService) MapMidtransStatus(transactionStatus string, fraudStatus string) string {
	return MapMidtransStatus(transactionStatus, fraudStatus)
}

func MapMidtransStatus(transactionStatus string, fraudStatus string) string {
	switch strings.ToLower(strings.TrimSpace(transactionStatus)) {
	case "settlement":
		return "paid"
	case "capture":
		if strings.ToLower(strings.TrimSpace(fraudStatus)) == "accept" {
			return "paid"
		}
		return "pending"
	case "pending":
		return "pending"
	case "expire":
		return "expired"
	case "cancel":
		return "cancelled"
	case "deny", "failure":
		return "failed"
	case "refund":
		return "refunded"
	default:
		return "pending"
	}
}

func (s *MidtransService) GetPaymentStatus(orderID string) (*MidtransStatusResponse, error) {
	orderID = strings.TrimSpace(orderID)
	if orderID == "" {
		return nil, errors.New("order_id kosong")
	}

	req, err := http.NewRequest(http.MethodGet, fmt.Sprintf("%s/%s/status", s.apiBaseURL(), url.PathEscape(orderID)), nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Accept", "application/json")
	req.SetBasicAuth(s.ServerKey, "")

	res, err := s.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	if res.StatusCode < http.StatusOK || res.StatusCode >= http.StatusMultipleChoices {
		return nil, fmt.Errorf("midtrans status gagal: status=%d body=%s", res.StatusCode, string(body))
	}

	var status MidtransStatusResponse
	if err := json.Unmarshal(body, &status); err != nil {
		return nil, err
	}

	return &status, nil
}

func (n MidtransNotification) FirstVANumber() string {
	if n.PermataVANumber != "" {
		return n.PermataVANumber
	}

	if len(n.VANumbers) > 0 {
		return n.VANumbers[0].VANumber
	}

	return ""
}

func (n MidtransNotification) EffectivePaymentMethod() string {
	if n.PaymentType != "" {
		return n.PaymentType
	}

	return "snap"
}

func (s *MidtransService) snapTransactionURL() string {
	if s.Environment == "production" {
		return "https://app.midtrans.com/snap/v1/transactions"
	}

	return "https://app.sandbox.midtrans.com/snap/v1/transactions"
}

func (s *MidtransService) apiBaseURL() string {
	if s.Environment == "production" {
		return "https://api.midtrans.com/v2"
	}

	return "https://api.sandbox.midtrans.com/v2"
}

type snapRequest struct {
	TransactionDetails snapTransactionDetails `json:"transaction_details"`
	EnabledPayments    []string               `json:"enabled_payments,omitempty"`
	ItemDetails        []snapItemDetail       `json:"item_details,omitempty"`
	CustomerDetails    snapCustomerDetails    `json:"customer_details"`
	Expiry             *snapExpiry            `json:"expiry,omitempty"`
	Callbacks          *snapCallbacks         `json:"callbacks,omitempty"`
	CustomField1       string                 `json:"custom_field1,omitempty"`
	CustomField2       string                 `json:"custom_field2,omitempty"`
}

type snapTransactionDetails struct {
	OrderID  string `json:"order_id"`
	GrossAmt int64  `json:"gross_amount"`
}

type snapItemDetail struct {
	ID    string `json:"id"`
	Price int64  `json:"price"`
	Qty   int    `json:"quantity"`
	Name  string `json:"name"`
}

type snapCustomerDetails struct {
	FirstName string `json:"first_name,omitempty"`
	Email     string `json:"email,omitempty"`
	Phone     string `json:"phone,omitempty"`
}

type snapExpiry struct {
	StartTime string `json:"start_time"`
	Unit      string `json:"unit"`
	Duration  int    `json:"duration"`
}

type snapCallbacks struct {
	Finish string `json:"finish,omitempty"`
}

type snapResponse struct {
	Token       string `json:"token"`
	RedirectURL string `json:"redirect_url"`
}
