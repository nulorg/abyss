# Build stage
FROM golang:1.25-alpine AS builder

ARG GITHUB_TOKEN

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Configure git for private repo access (using ABYSS_GITHUB_TOKEN from organization secrets)
RUN git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

WORKDIR /app

# Set GOPRIVATE
ENV GOPRIVATE=github.com/nulorg/abyss-core

# Copy abyss-core (should be present in build context via CI)
COPY abyss-core/ ./abyss-core/

# Copy abyss mod files
COPY go.mod go.sum ./

# Local module replacement for abyss-core
RUN go mod edit -replace github.com/nulorg/abyss-core=./abyss-core
RUN go mod download

# Copy source code
COPY . .

ARG ABYSS_PUBLIC_KEY

# Build (main.go is now in root)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=${ABYSS_PUBLIC_KEY}" -trimpath -o abyss .

# Runtime stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/abyss .

EXPOSE 8080

ENTRYPOINT ["./abyss"]
