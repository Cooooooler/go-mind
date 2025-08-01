#!/bin/bash

# Go-Mind 重启脚本
# 支持平滑重启和强制重启

APP_NAME="go-mind"
APP_PORT="8000"
PID_FILE="./go-mind.pid"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查应用是否运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# 获取应用PID
get_pid() {
    if [ -f "$PID_FILE" ]; then
        cat "$PID_FILE"
    else
        pgrep -f "go run main.go" | head -1
    fi
}

# 启动应用
start() {
    print_message "启动 $APP_NAME..."
    
    if is_running; then
        print_warning "$APP_NAME 已经在运行中 (PID: $(get_pid))"
        return 1
    fi
    
    # 启动应用并保存PID
    nohup go run main.go > ./logs/app.log 2>&1 &
    echo $! > "$PID_FILE"
    
    # 等待应用启动
    sleep 3
    
    if is_running; then
        print_message "$APP_NAME 启动成功 (PID: $(get_pid))"
        print_message "访问地址: http://localhost:$APP_PORT"
        print_message "API文档: http://localhost:$APP_PORT/swagger"
    else
        print_error "$APP_NAME 启动失败"
        return 1
    fi
}

# 停止应用
stop() {
    print_message "停止 $APP_NAME..."
    
    if ! is_running; then
        print_warning "$APP_NAME 未在运行"
        return 0
    fi
    
    PID=$(get_pid)
    
    # 尝试优雅停止
    kill -TERM $PID
    
    # 等待进程结束
    for i in {1..10}; do
        if ! ps -p $PID > /dev/null 2>&1; then
            print_message "$APP_NAME 已停止"
            rm -f "$PID_FILE"
            return 0
        fi
        sleep 1
    done
    
    # 强制停止
    print_warning "优雅停止超时，强制停止..."
    kill -KILL $PID
    sleep 1
    
    if ! ps -p $PID > /dev/null 2>&1; then
        print_message "$APP_NAME 已强制停止"
        rm -f "$PID_FILE"
    else
        print_error "无法停止 $APP_NAME"
        return 1
    fi
}

# 重启应用
restart() {
    print_message "重启 $APP_NAME..."
    stop
    sleep 2
    start
}

# 平滑重启
graceful_restart() {
    print_message "执行平滑重启..."
    
    if ! is_running; then
        print_warning "$APP_NAME 未在运行，直接启动"
        start
        return
    fi
    
    PID=$(get_pid)
    
    # 发送USR1信号触发平滑重启
    kill -USR1 $PID
    
    print_message "平滑重启信号已发送，等待新进程启动..."
    
    # 等待新进程启动
    for i in {1..15}; do
        sleep 1
        NEW_PID=$(pgrep -f "go run main.go" | grep -v $PID | head -1)
        if [ ! -z "$NEW_PID" ]; then
            echo $NEW_PID > "$PID_FILE"
            print_message "平滑重启成功 (新PID: $NEW_PID)"
            return 0
        fi
    done
    
    print_error "平滑重启超时，执行普通重启"
    restart
}

# 查看状态
status() {
    if is_running; then
        PID=$(get_pid)
        print_message "$APP_NAME 正在运行 (PID: $PID)"
        print_message "访问地址: http://localhost:$APP_PORT"
    else
        print_message "$APP_NAME 未在运行"
    fi
}

# 查看日志
logs() {
    if [ -f "./logs/app.log" ]; then
        tail -f ./logs/app.log
    else
        print_error "日志文件不存在"
    fi
}

# 主函数
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    graceful)
        graceful_restart
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    *)
        echo "用法: $0 {start|stop|restart|graceful|status|logs}"
        echo ""
        echo "命令说明:"
        echo "  start     - 启动应用"
        echo "  stop      - 停止应用"
        echo "  restart   - 重启应用"
        echo "  graceful  - 平滑重启应用"
        echo "  status    - 查看应用状态"
        echo "  logs      - 查看应用日志"
        exit 1
        ;;
esac

exit 0 