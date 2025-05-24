#!/bin/bash


# Watch wasm/main.go and rebuild wasm
#watchexec --project-origin . -e go -w wasm "GOOS=js GOARCH=wasm go build -o ./assets/json.wasm ./cmd/wasm/main.go"

# Watch server/main.go and restart the server
watchexec --workdir . -e go -w server "go run cmd/server/main.go" &


# Wait for both processes
wait

