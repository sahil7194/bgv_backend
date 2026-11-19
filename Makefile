
APP_NAME=backend_bgv

.PHONY: build run dbMigrateBuild dbMigrate test clean up down status

build:
	@mkdir -p bin
	@go build -o bin/$(APP_NAME) .

run: build
	@./bin/$(APP_NAME)

dbMigrateBuild:
	@mkdir -p bin
	@go build -o bin/db_migrate ./db

dbMigrate: dbMigrateBuild
	@./bin/db_migrate $(filter-out dbMigrate,$(MAKECMDGOALS))

up down status:
	@:

test:
	@go test -v ./...

clean:
	@rm -rf bin
