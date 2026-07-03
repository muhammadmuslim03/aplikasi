package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/joho/godotenv"
)

var loadEnvOnce sync.Once

func LoadEnv() {
	loadEnvOnce.Do(func() {
		_ = godotenv.Load(".env", "gotrip-backend/.env", "../.env")
	})
}

func Env(key string, fallback string) string {
	LoadEnv()

	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}

	return value
}

func EnvInt(key string, fallback int) int {
	value := Env(key, "")
	if value == "" {
		return fallback
	}

	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}

	return parsed
}

func EnvDurationMinutes(key string, fallbackMinutes int) time.Duration {
	return time.Duration(EnvInt(key, fallbackMinutes)) * time.Minute
}

func JWTSecret() []byte {
	return []byte(Env("JWT_SECRET", "your-secret-key-go-trip-2025"))
}

func DatabaseDSN() string {
	if dsn := Env("DATABASE_DSN", ""); dsn != "" {
		return dsn
	}

	return fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		Env("DB_HOST", "localhost"),
		Env("DB_USER", "postgres"),
		Env("DB_PASSWORD", "secret"),
		Env("DB_NAME", "gotrip_db"),
		Env("DB_PORT", "5432"),
		Env("DB_SSLMODE", "disable"),
	)
}
