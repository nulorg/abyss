# Makefile
# www 目录是独立的 git 仓库，由 abyss/.gitignore 忽略

BINARY=abyss

-include .env
export

ABYSS_PUBLIC_KEY ?=
LDFLAGS := -s -w -X github.com/nulorg/abyss-core/bootstrap.BuildPublicKey=$(ABYSS_PUBLIC_KEY)

.PHONY: build test clean www

# 完整编译: 前端 + 后端
build: www
ifndef ABYSS_PUBLIC_KEY
	$(error ABYSS_PUBLIC_KEY is not set)
endif
	@echo "==> Building backend..."
	go build -ldflags="$(LDFLAGS)" -trimpath -o $(BINARY) .

# 编译前端
www:
	@echo "==> Building frontend..."
	cd www && pnpm install && pnpm run build

test:
	go test ./...

clean:
	rm -rf $(BINARY) www/dist
