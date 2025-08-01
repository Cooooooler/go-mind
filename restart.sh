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



# 获取应用PID
get_pid() {
    if [ -f "$PID_FILE" ]; then
        cat "$PID_FILE"
    else
        # 优先查找gf run main.go进程，然后是go run main.go进程，最后是go-mind二进制进程
        PID=$(pgrep -f "gf run main.go" | head -1)
        if [ -z "$PID" ]; then
            PID=$(pgrep -f "go run main.go" | head -1)
        fi
        if [ -z "$PID" ]; then
            PID=$(pgrep -f "go-mind" | head -1)
        fi
        echo $PID
    fi
}

# 检查应用是否运行（改进版）
is_running() {
    # 首先检查PID文件
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            return 0
        else
            # PID文件存在但进程不存在，清理PID文件
            rm -f "$PID_FILE"
        fi
    fi
    
    # 如果PID文件不存在或进程不存在，检查是否有相关进程
    if pgrep -f "gf run main.go" > /dev/null 2>&1; then
        # 找到gf run main.go进程但没有PID文件，创建PID文件
        PID=$(pgrep -f "gf run main.go" | head -1)
        echo $PID > "$PID_FILE"
        return 0
    elif pgrep -f "go run main.go" > /dev/null 2>&1; then
        # 找到go run main.go进程但没有PID文件，创建PID文件
        PID=$(pgrep -f "go run main.go" | head -1)
        echo $PID > "$PID_FILE"
        return 0
    elif pgrep -f "go-mind" > /dev/null 2>&1; then
        # 找到go-mind二进制进程但没有PID文件，创建PID文件
        PID=$(pgrep -f "go-mind" | head -1)
        echo $PID > "$PID_FILE"
        return 0
    fi
    
    return 1
}

# 清理PID文件
cleanup_pid() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ! ps -p $PID > /dev/null 2>&1; then
            rm -f "$PID_FILE"
        fi
    fi
    
    # 清理所有PID文件
    if [ -f "${PID_FILE}.all" ]; then
        rm -f "${PID_FILE}.all"
    fi
}

# 记录所有相关进程的PID到文件
record_all_pids() {
    ALL_PIDS=""
    
    # 1. 从PID文件获取
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            ALL_PIDS="$ALL_PIDS $PID"
        fi
    fi
    
    # 2. 监听端口的进程
    PORT_PID=$(lsof -ti :$APP_PORT 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        ALL_PIDS="$ALL_PIDS $PORT_PID"
    fi
    
    # 3. gf run main.go进程
    GF_RUN_PID=$(pgrep -f "gf run main.go" | head -1)
    if [ ! -z "$GF_RUN_PID" ]; then
        ALL_PIDS="$ALL_PIDS $GF_RUN_PID"
    fi
    
    # 4. go run main.go进程
    GO_RUN_PID=$(pgrep -f "go run main.go" | head -1)
    if [ ! -z "$GO_RUN_PID" ]; then
        ALL_PIDS="$ALL_PIDS $GO_RUN_PID"
    fi
    
    # 5. go-mind二进制进程
    GO_MIND_PID=$(pgrep -f "go-mind" | head -1)
    if [ ! -z "$GO_MIND_PID" ]; then
        ALL_PIDS="$ALL_PIDS $GO_MIND_PID"
    fi
    
    # 去重并排序
    ALL_PIDS=$(echo $ALL_PIDS | tr ' ' '\n' | sort -u | tr '\n' ' ')
    
    # 记录到文件
    if [ ! -z "$ALL_PIDS" ]; then
        echo $ALL_PIDS > "${PID_FILE}.all"
        print_message "记录所有相关进程PID: $ALL_PIDS"
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
    PID=$!
    echo $PID > "$PID_FILE"
    
    # 确保PID文件创建成功
    if [ ! -f "$PID_FILE" ]; then
        print_error "无法创建PID文件: $PID_FILE"
        return 1
    fi
    
    print_message "主进程启动成功 (PID: $PID)"
    
    # 等待应用启动并查找所有相关进程
    sleep 3
    
    # 查找并记录所有相关进程
    ALL_PIDS=""
    
    # 1. 主进程
    if ps -p $PID > /dev/null 2>&1; then
        ALL_PIDS="$ALL_PIDS $PID"
    fi
    
    # 2. 监听端口的进程
    PORT_PID=$(lsof -ti :$APP_PORT 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        ALL_PIDS="$ALL_PIDS $PORT_PID"
        print_message "找到监听端口的进程 (PID: $PORT_PID)"
    fi
    
    # 3. go run main.go进程
    GO_RUN_PID=$(pgrep -f "go run main.go" | head -1)
    if [ ! -z "$GO_RUN_PID" ]; then
        ALL_PIDS="$ALL_PIDS $GO_RUN_PID"
        print_message "找到 go run main.go 进程 (PID: $GO_RUN_PID)"
    fi
    
    # 去重并排序
    ALL_PIDS=$(echo $ALL_PIDS | tr ' ' '\n' | sort -u | tr '\n' ' ')
    
    if [ ! -z "$ALL_PIDS" ]; then
        print_message "应用启动成功，相关进程: $ALL_PIDS"
        print_message "访问地址: http://localhost:$APP_PORT"
        print_message "API文档: http://localhost:$APP_PORT/swagger"
        
        # 记录所有相关进程的PID
        record_all_pids
    else
        print_error "$APP_NAME 启动失败"
        return 1
    fi
}

# 热更新启动应用
hot_start() {
    print_message "启动 $APP_NAME (热更新模式)..."
    
    if is_running; then
        print_warning "$APP_NAME 已经在运行中 (PID: $(get_pid))"
        return 1
    fi
    
    # 启动热更新应用并保存PID
    nohup gf run main.go > ./logs/app.log 2>&1 &
    PID=$!
    echo $PID > "$PID_FILE"
    
    # 确保PID文件创建成功
    if [ ! -f "$PID_FILE" ]; then
        print_error "无法创建PID文件: $PID_FILE"
        return 1
    fi
    
    print_message "热更新主进程启动成功 (PID: $PID)"
    
    # 等待应用启动并查找所有相关进程
    sleep 3
    
    # 查找并记录所有相关进程
    ALL_PIDS=""
    
    # 1. 主进程
    if ps -p $PID > /dev/null 2>&1; then
        ALL_PIDS="$ALL_PIDS $PID"
    fi
    
    # 2. 监听端口的进程
    PORT_PID=$(lsof -ti :$APP_PORT 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        ALL_PIDS="$ALL_PIDS $PORT_PID"
        print_message "找到监听端口的进程 (PID: $PORT_PID)"
    fi
    
    # 3. gf run main.go进程
    GF_RUN_PID=$(pgrep -f "gf run main.go" | head -1)
    if [ ! -z "$GF_RUN_PID" ]; then
        ALL_PIDS="$ALL_PIDS $GF_RUN_PID"
        print_message "找到 gf run main.go 进程 (PID: $GF_RUN_PID)"
    fi
    
    # 4. go run main.go进程（gf run可能会启动）
    GO_RUN_PID=$(pgrep -f "go run main.go" | head -1)
    if [ ! -z "$GO_RUN_PID" ]; then
        ALL_PIDS="$ALL_PIDS $GO_RUN_PID"
        print_message "找到 go run main.go 进程 (PID: $GO_RUN_PID)"
    fi
    
    # 去重并排序
    ALL_PIDS=$(echo $ALL_PIDS | tr ' ' '\n' | sort -u | tr '\n' ' ')
    
    if [ ! -z "$ALL_PIDS" ]; then
        print_message "热更新应用启动成功，相关进程: $ALL_PIDS"
        print_message "访问地址: http://localhost:$APP_PORT"
        print_message "API文档: http://localhost:$APP_PORT/swagger"
        print_message "热更新模式已启用，文件修改将自动重启"
        
        # 记录所有相关进程的PID
        record_all_pids
    else
        print_error "$APP_NAME 热更新启动失败"
        return 1
    fi
}

# 停止应用
stop() {
    print_message "停止 $APP_NAME..."
    
    # 收集所有需要停止的进程ID
    PIDS_TO_STOP=""
    
    # 1. 从PID文件获取进程ID
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            PIDS_TO_STOP="$PIDS_TO_STOP $PID"
            print_message "从PID文件找到进程: $PID"
        fi
    fi
    
    # 2. 查找监听端口的进程
    PORT_PID=$(lsof -ti :$APP_PORT 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        PIDS_TO_STOP="$PIDS_TO_STOP $PORT_PID"
        print_message "找到监听端口 $APP_PORT 的进程: $PORT_PID"
    fi
    
    # 3. 查找gf run main.go进程
    GF_RUN_PID=$(pgrep -f "gf run main.go" | head -1)
    if [ ! -z "$GF_RUN_PID" ]; then
        PIDS_TO_STOP="$PIDS_TO_STOP $GF_RUN_PID"
        print_message "找到 gf run main.go 进程: $GF_RUN_PID"
    fi
    
    # 4. 查找go run main.go进程
    GO_RUN_PID=$(pgrep -f "go run main.go" | head -1)
    if [ ! -z "$GO_RUN_PID" ]; then
        PIDS_TO_STOP="$PIDS_TO_STOP $GO_RUN_PID"
        print_message "找到 go run main.go 进程: $GO_RUN_PID"
    fi
    
    # 5. 查找go-mind二进制进程
    GO_MIND_PID=$(pgrep -f "go-mind" | head -1)
    if [ ! -z "$GO_MIND_PID" ]; then
        PIDS_TO_STOP="$PIDS_TO_STOP $GO_MIND_PID"
        print_message "找到 go-mind 二进制进程: $GO_MIND_PID"
    fi
    
    # 去重并排序
    PIDS_TO_STOP=$(echo $PIDS_TO_STOP | tr ' ' '\n' | sort -u | tr '\n' ' ')
    
    if [ -z "$PIDS_TO_STOP" ]; then
        print_message "$APP_NAME 未在运行"
        cleanup_pid
        return 0
    fi
    
    print_message "准备停止以下进程: $PIDS_TO_STOP"
    
    # 首先尝试优雅停止所有进程
    for PID in $PIDS_TO_STOP; do
        print_message "尝试优雅停止进程 PID: $PID"
        kill -TERM $PID 2>/dev/null
    done
    
    # 等待进程结束
    for i in {1..10}; do
        REMAINING_PIDS=""
        for PID in $PIDS_TO_STOP; do
            if ps -p $PID > /dev/null 2>&1; then
                REMAINING_PIDS="$REMAINING_PIDS $PID"
            fi
        done
        
        if [ -z "$REMAINING_PIDS" ]; then
            print_message "$APP_NAME 已优雅停止"
            cleanup_pid
            return 0
        fi
        
        print_message "等待进程结束... 剩余进程: $REMAINING_PIDS"
        sleep 1
    done
    
    # 强制停止剩余进程
    print_warning "优雅停止超时，强制停止剩余进程..."
    for PID in $REMAINING_PIDS; do
        print_message "强制停止进程 PID: $PID"
        kill -KILL $PID 2>/dev/null
    done
    
    # 最终检查
    sleep 2
    FINAL_REMAINING=""
    for PID in $PIDS_TO_STOP; do
        if ps -p $PID > /dev/null 2>&1; then
            FINAL_REMAINING="$FINAL_REMAINING $PID"
        fi
    done
    
    if [ -z "$FINAL_REMAINING" ]; then
        print_message "$APP_NAME 已成功停止"
        cleanup_pid
        return 0
    else
        print_error "无法停止以下进程: $FINAL_REMAINING"
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
    print_message "检查 $APP_NAME 状态..."
    
    # 检查PID文件
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        print_message "PID文件中的进程ID: $PID"
        if ps -p $PID > /dev/null 2>&1; then
            print_message "PID文件中的进程正在运行"
        else
            print_warning "PID文件中的进程不存在"
        fi
    else
        print_message "PID文件不存在"
    fi
    
    # 检查端口占用
    PORT_PID=$(lsof -ti :$APP_PORT 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        print_message "端口 $APP_PORT 被进程占用 (PID: $PORT_PID)"
    else
        print_message "端口 $APP_PORT 未被占用"
    fi
    
    # 检查进程
    GF_RUN_PID=$(pgrep -f "gf run main.go" | head -1)
    if [ ! -z "$GF_RUN_PID" ]; then
        print_message "找到 gf run main.go 进程 (PID: $GF_RUN_PID)"
    fi
    
    GO_RUN_PID=$(pgrep -f "go run main.go" | head -1)
    if [ ! -z "$GO_RUN_PID" ]; then
        print_message "找到 go run main.go 进程 (PID: $GO_RUN_PID)"
    fi
    
    GO_MIND_PID=$(pgrep -f "go-mind" | head -1)
    if [ ! -z "$GO_MIND_PID" ]; then
        print_message "找到 go-mind 二进制进程 (PID: $GO_MIND_PID)"
    fi
    
    # 综合判断
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
    hot)
        hot_start
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
        echo "用法: $0 {start|hot|stop|restart|graceful|status|logs}"
        echo ""
        echo "命令说明:"
        echo "  start     - 启动应用 (go run main.go)"
        echo "  hot       - 热更新启动应用 (gf run main.go)"
        echo "  stop      - 停止应用"
        echo "  restart   - 重启应用"
        echo "  graceful  - 平滑重启应用"
        echo "  status    - 查看应用状态"
        echo "  logs      - 查看应用日志"
        exit 1
        ;;
esac

exit 0 