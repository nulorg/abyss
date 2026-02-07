BINARY=abyss
CMD=.
GOPATH_BIN=$(shell go env GOPATH)/bin
CORE_DIR=../abyss-core
FRONTEND_DIR=$(CORE_DIR)/www

# Load .env file if it exists (for local development)
-include .env
export

# ABYSS_PUBLIC_KEY (base64 Ed25519 public key) - REQUIRED for compilation
# Can be set via:
#   1. Environment variable: export ABYSS_PUBLIC_KEY=...
#   2. .env file: ABYSS_PUBLIC_KEY=...
#   3. Command line: make build ABYSS_PUBLIC_KEY=...
ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: help all build build-backend build-frontend build-all test fmt vet lint clean install-deps release install docker

# Default target
all: build

help:
	@echo "Makefile targets:"
	@echo ""
	@echo "  all (default)       Build backend"
	@echo "  build               Build backend binary"
	@echo "  build-backend       Build backend binary"
	@echo "  build-frontend      Build frontend (if abyss-core is present)"
	@echo "  build-all           Build both frontend and backend"
	@echo "  install             Build and install to GOPATH/bin"
	@echo "  docker              Build Docker image"
	@echo "  test                Run Go tests"
	@echo "  fmt                 Format Go code"
	@echo "  vet                 Run go vet"
	@echo "  lint                Run golangci-lint"
	@echo "  install-deps        Download Go dependencies"
	@echo "  release             Run goreleaser"
	@echo "  clean               Remove build artifacts"
	@echo ""
	@echo "Environment variables:"
	@echo "  ABYSS_PUBLIC_KEY    Ed25519 public key (base64) - required for build"
	@echo ""
	@echo "Local development:"
	@echo "  Create .env file with ABYSS_PUBLIC_KEY=<your-key>"

# Build backend
build: build-backend

# Build both
build-all: build-frontend build-backend

# Install to GOPATH/bin
install:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set. Set it via .env file, environment variable, or command line)
endif
	@echo "Installing to $(GOPATH_BIN)..."
	@go install -ldflags="$(LDFLAGS)" -trimpath $(CMD)

# Backend build
build-backend:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set. Set it via .env file, environment variable, or command line)
endif
	@echo "Building backend..."
	@go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) $(CMD)

# Docker build
docker:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set. Set it via .env file, environment variable, or command line)
endif
	@echo "Building Docker image..."
	@docker build --build-arg ABYSS_PUBLIC_KEY="$(ABYSS_PUBLIC_KEY)" -t abyss:local .

# Frontend build (only if available locally)
build-frontend:
	@if [ -d "$(FRONTEND_DIR)" ]; then \
		echo "Building frontend in $(FRONTEND_DIR)..."; \
		cd $(FRONTEND_DIR) && pnpm install && pnpm run build; \
	else \
		echo "Skip building frontend: $(FRONTEND_DIR) not found. Use pre-built dist in abyss-core."; \
	fi

# Backend test
test:
	@echo "Running tests..."
	@go test ./...

# Backend format
fmt:
	@echo "Formatting Go code..."
	@gofmt -w .

# Backend vet
vet:
	@echo "Running go vet..."
	@go vet ./...

# Lint with golangci-lint
lint:
	@echo "Running golangci-lint..."
	@command -v golangci-lint >/dev/null 2>&1 || { echo "golangci-lint not found"; exit 1; }
	@golangci-lint run ./...

# Backend dependencies
install-deps:
	@echo "Downloading Go dependencies..."
	@go mod download

# Release
release:
	@echo "Running goreleaser..."
	@goreleaser release

# Clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BINARY)
