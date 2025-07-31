package main

import (
	_ "go-mind/internal/packed"

	_ "github.com/go-sql-driver/mysql"
	_ "github.com/gogf/gf/contrib/drivers/mysql/v2"

	"github.com/gogf/gf/v2/os/gctx"

	"go-mind/internal/cmd"
)

func main() {
	cmd.Main.Run(gctx.New())
}
