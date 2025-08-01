# Go-Mind Makefile
# 提供便捷的开发和管理命令

.PHONY: help build run start stop restart graceful status logs clean test

# 默认目标
help:
	@echo "Go-Mind 管理命令:"
	@echo ""
	@echo "开发命令:"
	@echo "  make run        - 直接运行应用 (go run main.go)"
	@echo "  make hot        - 热更新开发模式 (gf run main.go)"
	@echo "  make build      - 编译应用"
	@echo "  make test       - 运行测试"
	@echo ""
	@echo "服务管理:"
	@echo "  make start      - 启动服务 (后台运行)"
	@echo "  make hot        - 启动热更新服务 (后台运行)"
	@echo "  make stop       - 停止服务"
	@echo "  make restart    - 重启服务"
	@echo "  make hot-restart- 重启热更新服务"
	@echo "  make graceful   - 平滑重启服务"
	@echo "  make status     - 查看服务状态"
	@echo "  make logs       - 查看服务日志"
	@echo ""
	@echo "其他命令:"
	@echo "  make clean      - 清理编译文件"
	@echo "  make help       - 显示此帮助信息"

# 开发命令
run:
	@echo "启动 Go-Mind 应用..."
	go run main.go

hot:
	@echo "启动 Go-Mind 热更新开发模式..."
	gf run main.go

build:
	@echo "编译 Go-Mind 应用..."
	go build -o go-mind main.go
	@echo "编译完成: ./go-mind"

test:
	@echo "运行测试..."
	go test ./...

# 服务管理命令
start:
	@echo "启动 Go-Mind 服务..."
	./restart.sh start

hot:
	@echo "启动 Go-Mind 热更新服务..."
	./restart.sh hot

stop:
	@echo "停止 Go-Mind 服务..."
	./restart.sh stop

restart:
	@echo "重启 Go-Mind 服务..."
	./restart.sh restart

hot-restart:
	@echo "重启 Go-Mind 热更新服务..."
	./restart.sh stop
	@echo "等待2秒..."
	@sleep 2
	./restart.sh hot

graceful:
	@echo "平滑重启 Go-Mind 服务..."
	./restart.sh graceful

status:
	@echo "查看 Go-Mind 服务状态..."
	./restart.sh status

logs:
	@echo "查看 Go-Mind 服务日志..."
	./restart.sh logs

# 清理命令
clean:
	@echo "清理编译文件..."
	rm -f go-mind
	rm -f go-mind.pid
	rm -f go-mind.pid.all
	@echo "清理完成"