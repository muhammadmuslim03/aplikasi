package config

import (
	"fmt"
	"log"

	"gotrip-backend/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	LoadEnv()

	dsn := DatabaseDSN()

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Gagal koneksi database:", err)
	}

	err = DB.AutoMigrate(
		&models.User{},
		&models.Booking{},
		&models.Payment{},
		&models.HikingRoute{},
	)
	if err != nil {
		log.Fatal("Gagal migrate tabel:", err)
	}

	seedHikingRoutes()

	fmt.Println("✅ Database siap")
}

func seedHikingRoutes() {
	routes := []models.HikingRoute{
		{
			ID:          1,
			RouteName:   "Jalur Garung",
			Description: "Jalur paling populer, cocok untuk pendaki pemula",
			IsOpen:      true,
		},
		{
			ID:          2,
			RouteName:   "Jalur Bowongso",
			Description: "Jalur menantang dengan pemandangan indah",
			IsOpen:      true,
		},
		{
			ID:          3,
			RouteName:   "Jalur Kaliangkrik",
			Description: "Jalur alternatif yang lebih sepi",
			IsOpen:      true,
		},
	}

	for _, route := range routes {
		if err := DB.Where("id = ?", route.ID).FirstOrCreate(&route).Error; err != nil {
			log.Fatal("Gagal seed jalur pendakian:", err)
		}
	}
}
