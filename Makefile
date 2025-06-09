# Makefile
.DEFAULT_GOAL := help

# Variables
BINARY_NAME=cmd/server/main.go
WASM_OUTPUT=cmd/server/assets/json.wasm

.PHONY: help install dev test clean-services clean up down 

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
	@make build-wasm
	@go run ./cmd/server/main.go

# Production build target
build: build-wasm build-server

# Build WebAssembly
build-wasm:
	@echo "Building WebAssembly..."
	GOOS=js GOARCH=wasm go build -o $(WASM_OUTPUT) ./cmd/wasm/main.go

# Build Go server (for production)
build-server:
	@echo "Building Go server..."
	GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o $(BINARY_NAME) cmd/server/main.go

down: ## Turns docker composer down
	@docker compose down
	@echo "✅ Services down"

downnet: # Destroy network
	@docker network remove jsonnet

clean: clean-links down downnet ## Clean services and links

up: ## Runs services network using docker compose
	@docker compose up -d --build --force-recreate
	@echo "✅ Services should be running now"

logs:
	@docker compose logs -f

gen-json: ## Generates unformatted json to test
	python ./scripts/generateJson.py

compose: up logs ## RUns using docker compose

