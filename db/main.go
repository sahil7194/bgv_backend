package main

import (
	"fmt"
	"log"
	"os"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/joho/godotenv"
)

func main() {

	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env:", err)
	}

	if len(os.Args) < 2 {
		fmt.Println("please pass argument like down or up")

		os.Exit(1)
	}

	arrgument := os.Args[1]

	dbUrl := os.Getenv("DB_URL")

	m, err := migrate.New(
		"file://db/migrations",
		dbUrl)

	if err != nil {
		log.Fatal(err)
	}

	switch {
	case arrgument == "up":
		if err := m.Up(); err != nil {
			log.Fatal(err)
		}

		fmt.Println("migration successfully up done")
	case arrgument == "down":
		if err := m.Down(); err != nil {
			log.Fatal(err)
		}

		fmt.Println("migration successfully down done")
	default:
		fmt.Println("Invalid Arrgument")
	}
}
