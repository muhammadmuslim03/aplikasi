package main

import (
	"gotrip-backend/config"

	// Controllers
	authController "gotrip-backend/controllers/auth"
	bookingController "gotrip-backend/controllers/booking"
	dashboardController "gotrip-backend/controllers/dashboard"
	exportController "gotrip-backend/controllers/export"
	paymentController "gotrip-backend/controllers/payment"
	userController "gotrip-backend/controllers/user"

	// Middleware
	"gotrip-backend/middlewares"

	"github.com/gin-gonic/gin"
)

func main() {

	// Connect DB
	config.ConnectDatabase()

	r := gin.Default()

	// CORS
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Static folder (image bukti pembayaran)
	r.Static("/uploads", "./uploads")

	// =====================================
	// AUTH (Register, Login)
	// =====================================
	auth := r.Group("/auth")
	{
		auth.POST("/register", authController.Register)
		auth.POST("/login", authController.Login)
	}

	// =====================================
	// PROTECTED ROUTES (JWT)
	// =====================================
	api := r.Group("/api", middlewares.AuthMiddleware())
	{

		// TEST PROFILE
		api.GET("/profile", func(c *gin.Context) {
			role := c.GetString("role")
			userID := c.GetUint("user_id")

			c.JSON(200, gin.H{
				"message": "Halo pengguna!",
				"user_id": userID,
				"role":    role,
			})
		})

		// =====================================
		// PENDAKI (MOBILE USER)
		// =====================================
		pendaki := api.Group("/pendaki", middlewares.RoleMiddleware("pendaki"))
		{
			pendaki.POST("/booking", bookingController.CreateBooking)
			pendaki.GET("/history", bookingController.GetHistory)
		}

		// =====================================
		// ADMIN WEBSITE
		// =====================================
		admin := api.Group("/web-admin", middlewares.RoleMiddleware("admin"))
		{
			// Dashboard (jumlah pendaki, pendapatan)
			admin.GET("/dashboard", dashboardController.AdminDashboard)

			// Grafik
			admin.GET("/chart/pendapatan", dashboardController.ChartPendapatan)
			admin.GET("/chart/pendaki", dashboardController.ChartPendaki)

			// Booking List + Update + Delete
			admin.GET("/bookings", bookingController.AdminGetAllBookings)
			admin.PUT("/booking/:id/status", bookingController.AdminUpdateStatus)
			admin.DELETE("/booking/:id", bookingController.AdminDeleteBooking)

			// Data Pendaki (Admin bisa **lihat, tambah, hapus**)
			admin.GET("/pendaki", userController.GetPendaki)
			admin.DELETE("/pendaki/:id", userController.DeletePendaki)

			// Export CSV / PDF
			admin.GET("/export/csv", exportController.ExportCSV)
			admin.GET("/export/pdf", exportController.ExportAllPDF)
			admin.GET("/export/pdf/daily", exportController.ExportDailyPDF)
			admin.GET("/export/pdf/weekly", exportController.ExportWeeklyPDF)
			admin.GET("/export/pdf/monthly", exportController.ExportMonthlyPDF)

			// Upload bukti pembayaran (admin)
			admin.POST("/upload-proof", paymentController.AdminUploadProof)

			// Verifikasi pembayaran
			admin.PUT("/verify-payment/:id", paymentController.AdminVerifyPayment)
		}
	}

	r.Run("0.0.0.0:8080")
}
