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
	dsn := "host=localhost user=postgres password=secret dbname=gotrip_db port=5432 sslmode=disable"
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Gagal koneksi database:", err)
	}

	// Auto migrate tabel
	err = DB.AutoMigrate(
		&models.User{},
		&models.Booking{})
	if err != nil {
		log.Fatal("Gagal migrate tabel:", err)
	}

	fmt.Println("✅ Database terhubung dan tabel dimigrasi.")
}
