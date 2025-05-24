# Makefile
.DEFAULT_GOAL := help

# Variables
BINARY_NAME=cmd/server/main.go
WASM_OUTPUT=assets/json.wasm

.PHONY: help install dev test clean-links clean-services clean up down presentation 

help: ## Show help
	@echo "Available make commands:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


install: ## Install dependencies of all available services
	@echo "installing watch files systems"
	@cargo install watchexec-cli
	
	@echo "Installing dependencies ..."
	@go mod tidy
	@echo "✅ go dependencies installed"

	@echo "making dev.sh executable"
	@chmod +x dev.sh


dev: ## Runs dev servers in watch mode using nodemon
	go run ./cmd/server/main.go

# Production build target
build: build-wasm build-server

# Build WebAssembly
build-wasm:
	@echo "Building WebAssembly..."
	GOOS=js GOARCH=wasm go build -o $(WASM_OUTPUT) cmd/wasm/main.go

# Build Go server (for production)
build-server:
	@echo "Building Go server..."
	GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o $(BINARY_NAME) cmd/server/main.go

test: ## Runs tests concurrently
	npx concurrently "cd stock-service && npm run test -- --watchAll" "cd api-service && npm run test -- --watchAll"

clean-links: ## Clean symbolic links
	@find . -type l ! -exec test -e {} \; -delete
	@echo "✅ Removed dangling symlinks"


down: ## Turns docker composer down
	@docker compose down
	@echo "✅ Services down"

downnet: # Destroy network
	@docker network remove jsonnet

clean: clean-links down downnet ## Clean services and links

upnet: ## Creates jsonnet network to be reused
	@docker network create jsonnet

up: ## Runs services network using docker compose
	@docker compose up -d --build --force-recreate
	@echo "✅ Services should be running now"

# up-scale: ## Runs services network using docker compose
# 	@docker compose up -d --build --force-recreate --scale api=2 --scale stocks=5
# 	@echo "✅ Services shouldbe running now"

logs:
	@docker compose logs -f

presentation: clean install setup-env migrate dev ## Runs server all steps to make server run at once

compose: upnet up logs ## RUns using docker compose

# compose-scale: upnet up-scale logs ## RUns using docker compose