# Makefile
# 本地使用 go.work，CI 使用 go mod replace

BINARY=abyss
CORE_DIR ?= ../abyss-core

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: build test clean

build:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "Building frontend..."
	@cd $(CORE_DIR)/www && pnpm install && pnpm run build
	@echo "Building backend..."
	@go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

test:
	@go test ./...

clean:
	@rm -rf $(BINARY)
