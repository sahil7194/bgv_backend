package config

import (
	"context"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

func ConnectDB() *pgxpool.Pool {
	dbURL := os.Getenv("DB_URL")

	if dbURL == "" {
		log.Fatal("DB_URL is required")
	}

	db, err := pgxpool.New(
		context.Background(),
		dbURL,
	)

	if err != nil {
		log.Fatal("Database connection failed:", err)
	}

	if err := db.Ping(context.Background()); err != nil {
		log.Fatal("Database ping failed:", err)
	}

	return db
}
