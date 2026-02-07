# Abyss Makefile

BINARY=abyss

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: help build test vet clean

help:
	@echo "Usage:"
	@echo "  make build    Build the binary (requires ABYSS_PUBLIC_KEY)"
	@echo "  make test     Run tests"
	@echo "  make vet      Run go vet"
	@echo "  make clean    Remove binary"

build:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

test:
	go test ./...

vet:
	go vet ./...

clean:
	rm -rf $(BINARY)
