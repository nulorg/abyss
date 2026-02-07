# Makefile
# 编译流程: 克隆前端 → 编译前端 → 编译后端

BINARY=abyss
WWW_REPO=git@github.com:nulorg/abyss-www.git

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: build test clean www

# 默认: 完整编译
build: www
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "==> Building backend..."
	go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

# 克隆并编译前端
www:
	@if [ ! -d "www" ]; then \
		echo "==> Cloning abyss-www..."; \
		git clone $(WWW_REPO) www; \
	fi
	@echo "==> Building frontend..."
	cd www && pnpm install && pnpm run build

test:
	go test ./...

clean:
	rm -rf $(BINARY) www
