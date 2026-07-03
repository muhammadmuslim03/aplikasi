package routes

import (
	ticketController "gotrip-backend/controllers/ticket"

	"github.com/gin-gonic/gin"
)

func RegisterTicketRoutes(api *gin.RouterGroup) {
	api.POST("/tickets", ticketController.CreateTicket)
	api.GET("/tickets", ticketController.GetTickets)
}
