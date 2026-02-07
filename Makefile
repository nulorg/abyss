# Abyss Makefile

BINARY=abyss
CORE_DIR=../abyss-core
FRONTEND_DIR=$(CORE_DIR)/www

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: help build build-frontend build-all test vet clean cross

help:
	@echo "Usage:"
	@echo "  make build-all      Build frontend + backend"
	@echo "  make build          Build backend only (frontend must exist)"
	@echo "  make build-frontend Build frontend only"
	@echo "  make cross          Cross-compile for multiple platforms"
	@echo "  make test           Run tests"
	@echo "  make vet            Run go vet"
	@echo "  make clean          Remove binaries"

build-all: build-frontend build

build-frontend:
	@echo "==> Building frontend..."
	cd $(FRONTEND_DIR) && pnpm install && pnpm run build

build:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "==> Building backend..."
	go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

cross:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "==> Cross-compiling..."
	GOOS=linux GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY)-linux-amd64 .
	GOOS=linux GOARCH=arm64 go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY)-linux-arm64 .
	GOOS=darwin GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY)-darwin-amd64 .
	GOOS=darwin GOARCH=arm64 go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY)-darwin-arm64 .
	GOOS=windows GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY)-windows-amd64.exe .

test:
	go test ./...

vet:
	go vet ./...

clean:
	rm -rf $(BINARY) $(BINARY)-*
