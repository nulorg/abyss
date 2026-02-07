# Abyss Local Makefile
# For quick local operations within the abyss directory only
# For full workspace operations (including abyss-core), use the parent Makefile

BINARY=abyss

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: build test clean

build:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set. Use parent Makefile for full build)
endif
	@go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

test:
	@go test ./...

clean:
	@rm -rf $(BINARY)
