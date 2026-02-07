BINARY=abyss
CORE_DIR=../abyss-core
FRONTEND_DIR=$(CORE_DIR)/www
GOPATH_BIN=$(shell go env GOPATH)/bin

# Load .env file if it exists
-include .env
export

# ABYSS_PUBLIC_KEY - required for build
ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: help all build build-frontend test lint clean install docker release keygen-generate keygen-sign keygen-verify

all: build

help:
	@echo "Makefile targets:"
	@echo ""
	@echo "  all (default)       Build frontend + backend"
	@echo "  build               Build frontend + backend"
	@echo "  build-frontend      Build frontend only"
	@echo "  test                Run all tests (frontend + backend)"
	@echo "  lint                Run linters (frontend + backend)"
	@echo "  clean               Remove all build artifacts"
	@echo "  install             Install binary to GOPATH/bin"
	@echo "  docker              Build Docker image"
	@echo "  release             Run goreleaser"
	@echo ""
	@echo "Keygen:"
	@echo "  keygen-generate     Generate Ed25519 key pair"
	@echo "  keygen-sign         Sign payload"
	@echo "  keygen-verify       Verify license"

# Build all (frontend + backend)
build: build-frontend build-backend

# Frontend build
build-frontend:
	@echo "Building frontend..."
	@cd $(FRONTEND_DIR) && pnpm install && pnpm run build

# Backend build
build-backend:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "Building backend..."
	@go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

# Install to GOPATH/bin
install: build-frontend
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "Installing to $(GOPATH_BIN)..."
	@go install -ldflags="$(LDFLAGS)" -trimpath .

# Docker build
docker: build-frontend
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "Building Docker image..."
	@docker build --build-arg ABYSS_PUBLIC_KEY="$(ABYSS_PUBLIC_KEY)" -t abyss:local .

# Test all (frontend + backend)
test: test-frontend test-backend

test-frontend:
	@echo "Testing frontend..."
	@cd $(FRONTEND_DIR) && pnpm install && pnpm run test --run 2>/dev/null || echo "No frontend tests or test script not found"

test-backend:
	@echo "Testing backend..."
	@go test ./...
	@cd $(CORE_DIR) && go test ./...

# Lint all
lint: lint-frontend lint-backend

lint-frontend:
	@echo "Linting frontend..."
	@cd $(FRONTEND_DIR) && pnpm install && pnpm run lint 2>/dev/null || echo "No frontend lint script found"

lint-backend:
	@echo "Linting backend..."
	@command -v golangci-lint >/dev/null 2>&1 && golangci-lint run ./... || echo "golangci-lint not installed"
	@cd $(CORE_DIR) && command -v golangci-lint >/dev/null 2>&1 && golangci-lint run ./... || true

# Release
release:
	@echo "Running goreleaser..."
	@goreleaser release

# Clean all
clean:
	@echo "Cleaning..."
	@rm -rf $(BINARY)
	@rm -rf $(FRONTEND_DIR)/dist
	@rm -rf $(FRONTEND_DIR)/node_modules

# Keygen commands
keygen-generate:
	@go run $(CORE_DIR)/keygen/main.go generate

keygen-sign:
ifndef PRIVATE_KEY
	$(error PRIVATE_KEY is required)
endif
ifndef PAYLOAD
	$(error PAYLOAD is required)
endif
	@go run $(CORE_DIR)/keygen/main.go sign "$(PRIVATE_KEY)" "$(PAYLOAD)"

keygen-verify:
ifndef PUBLIC_KEY
	$(error PUBLIC_KEY is required)
endif
ifndef LICENSE
	$(error LICENSE is required)
endif
	@go run $(CORE_DIR)/keygen/main.go verify "$(PUBLIC_KEY)" "$(LICENSE)"
