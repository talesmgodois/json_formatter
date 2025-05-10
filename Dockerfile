# Build stage for the WASM binary
FROM golang:1.22.4 AS wasm-builder

WORKDIR /app

# Copy go mod files
COPY go.mod .
RUN go mod download

# Copy WASM source files
COPY cmd/wasm cmd/wasm

# Build WASM binary
RUN GOOS=js GOARCH=wasm go build -o assets/json.wasm ./cmd/wasm

# Build stage for the server
FROM golang:1.22.4 AS server-builder

WORKDIR /app

# Copy go mod files
COPY go.mod .
RUN go mod download

# Copy server source files
COPY cmd/server cmd/server
COPY assets assets

# Build server binary
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

# Final stage
FROM alpine:latest

WORKDIR /app

# Copy WASM-related files from the wasm-builder
COPY --from=wasm-builder /app/assets/json.wasm ./assets/json.wasm
# Copy other static assets
COPY assets/index.html ./assets/
COPY assets/styles.css ./assets/
COPY assets/wasm_exec.js ./assets/
# Copy server binary from the server-builder
COPY --from=server-builder /app/server .

# Copy input files
COPY __inputs __inputs

# Expose port (adjust if your server uses a different port)
EXPOSE 9090

# Command to run the server
CMD ["./server"]