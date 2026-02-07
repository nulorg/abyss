# Build stage
FROM golang:1.25-alpine AS builder

ARG GITHUB_TOKEN
ARG ABYSS_PUBLIC_KEY

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Configure git for private repo access
RUN git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

WORKDIR /app

# Set GOPRIVATE
ENV GOPRIVATE=github.com/nulorg/abyss-core

# Copy mod files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=${ABYSS_PUBLIC_KEY}" -trimpath -o abyss .

# Runtime stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/abyss .

EXPOSE 8080

ENTRYPOINT ["./abyss"]
