package main

import (
	"gotrip-backend/config"

	authController "gotrip-backend/controllers/auth"
	checkpointController "gotrip-backend/controllers/checkpoint"
	dashboardController "gotrip-backend/controllers/dashboard"
	exportController "gotrip-backend/controllers/export"
	paymentController "gotrip-backend/controllers/payment"
	ticketController "gotrip-backend/controllers/ticket"
	userController "gotrip-backend/controllers/user"

	"gotrip-backend/middlewares"

	"github.com/gin-gonic/gin"
)

func main() {

	config.ConnectDatabase()

	r := gin.Default()

	// CORS
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, PATCH")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Static upload
	r.Static("/uploads", "./uploads")

	// ================= AUTH =================
	auth := r.Group("/auth")
	{
		auth.POST("/register", authController.Register)
		auth.POST("/login", authController.Login)

		// 🔥 hanya dipakai sekali untuk buat admin pertama
		auth.POST("/init-admin", authController.InitAdmin)
	}

	// ================= API =================
	api := r.Group("/api", middlewares.AuthMiddleware())
	{
		// USER
		api.POST("/bookings", ticketController.CreateBooking)
		api.GET("/bookings", ticketController.GetBookings)
		api.PATCH("/bookings/:id/proof", ticketController.UploadProof)
		api.POST("/tickets", ticketController.CreateTicket)
		api.GET("/tickets", ticketController.GetTickets)
		api.PATCH("/tickets/:id/proof", ticketController.UploadProof)
		api.POST("/checkpoint/scan", checkpointController.ScanBarcode)

		api.GET("/profile", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"user_id": c.GetUint("user_id"),
				"role":    c.GetString("role"),
			})
		})

		// ================= ADMIN =================
		admin := api.Group("/web-admin", middlewares.RoleMiddleware("admin"))
		{
			admin.GET("/dashboard", dashboardController.AdminDashboard)
			admin.GET("/chart/pendapatan", dashboardController.ChartPendapatan)
			admin.GET("/chart/pendaki", dashboardController.ChartPendaki)

			admin.GET("/pendaki", userController.GetPendaki)
			admin.DELETE("/pendaki/:id", userController.DeletePendaki)

			admin.GET("/bookings", ticketController.GetAllBookingsAdmin)
			admin.GET("/tickets", ticketController.GetAllTicketsAdmin)
			admin.GET("/barcodes", checkpointController.GetBarcodes)

			admin.PUT("/verify-payment/:id", paymentController.AdminVerifyPayment)

			admin.GET("/export/csv", exportController.ExportCSV)
			admin.GET("/export/pdf", exportController.ExportAllPDF)

			admin.POST("/register", authController.RegisterAdmin)
		}
	}

	r.Run("0.0.0.0:8080")
}
