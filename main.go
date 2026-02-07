package main

import (
	"github.com/nulorg/abyss-core/bootstrap"
	www "github.com/nulorg/abyss-www"
)

func main() {
	opts := &bootstrap.RunnerOptions{}
	opts.Assets = www.Assets
	bootstrap.Main(opts)
}
