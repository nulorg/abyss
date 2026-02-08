# Build stage
FROM golang:1.25-alpine AS builder

ARG ABYSS_PUBLIC_KEY

# Install build dependencies
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy mod files and vendor (pre-downloaded by CI)
COPY go.mod go.sum ./
COPY vendor/ ./vendor/

# Copy source code
COPY . .

# Build static binary with vendored dependencies
RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -ldflags="-s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=${ABYSS_PUBLIC_KEY}" -trimpath -o abyss .

# Runtime stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/abyss .

EXPOSE 8080

ENTRYPOINT ["./abyss"]
