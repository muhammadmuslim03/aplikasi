package routes

import (
	paymentController "gotrip-backend/controllers/payment"

	"github.com/gin-gonic/gin"
)

func RegisterPaymentRoutes(api *gin.RouterGroup) {
	api.POST("/payments/create/:ticket_id", paymentController.ContinuePayment)
	api.GET("/payments/status/:ticket_id", paymentController.GetPaymentStatus)
}

func RegisterPaymentWebhook(r *gin.Engine) {
	r.POST("/api/payments/webhook", paymentController.MidtransWebhook)
}
