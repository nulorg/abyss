package main

import (
	"embed"

	"github.com/nulorg/abyss-core/bootstrap"
)

//go:embed www/dist/*
var assets embed.FS

func main() {
	opts := &bootstrap.RunnerOptions{}
	opts.Assets = assets
	bootstrap.Main(opts)
}
