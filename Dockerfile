# Stage 1: Build the Go binary in release mode
FROM golang:1.23-alpine AS builder

# Install git if needed for module dependencies
RUN apk update && apk add --no-cache git

WORKDIR /src

# Copy dependency files first for caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the binary in release mode by stripping debug info and symbol table
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app .

# Stage 2: Create a minimal image containing only the release binary
FROM scratch

# Copy the compiled binary from the builder stage
COPY --from=builder /app /app

# Expose the port your app uses (adjust if needed)
EXPOSE 8080

# Run in production mode
ENV GIN_MODE=release

# Set the binary as the container entrypoint
ENTRYPOINT ["/app"]
