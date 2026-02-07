# syntax=docker/dockerfile:1
# Build stage
FROM golang:1.25-alpine AS builder

ARG ABYSS_PUBLIC_KEY

# Install build dependencies
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Set GOPRIVATE
ENV GOPRIVATE=github.com/nulorg/abyss-core

# Copy mod files first for better caching
COPY go.mod go.sum ./

# Download dependencies with secret mount for GitHub token
RUN --mount=type=secret,id=github_token \
    git config --global url."https://$(cat /run/secrets/github_token)@github.com/".insteadOf "https://github.com/" && \
    go mod download

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
