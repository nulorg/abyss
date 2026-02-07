# Makefile

BINARY=abyss

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: build test clean

build:
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

test:
	go test ./...

clean:
	rm -rf $(BINARY)
