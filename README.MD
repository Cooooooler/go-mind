# Go-Mind 思维导图后端服务

基于 GoFrame 框架开发的思维导图后端 API 服务。

## 功能特性

- 创建思维导图
- 获取思维导图列表
- 支持标题搜索过滤
- MySQL 数据库存储

## 技术栈

- GoFrame v2
- MySQL
- Go 1.21+

## 快速开始

### 1. 环境准备

确保已安装：

- Go 1.21+
- MySQL 5.7+

### 2. 数据库配置

1. 创建数据库：

```sql
CREATE DATABASE xmind CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 执行初始化 SQL：

```sql
-- 创建思维导图表
CREATE TABLE IF NOT EXISTS `mindmap` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `title` varchar(255) NOT NULL DEFAULT '' COMMENT '标题',
  `data` json DEFAULT NULL COMMENT '思维导图数据',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_title` (`title`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='思维导图表';
```

### 3. 配置修改

编辑 `manifest/config/config.yaml` 文件，确保数据库连接配置正确：

```yaml
database:
  default:
    link: 'mysql:root@tcp(127.0.0.1:3306)/xmind'
    debug: true
```

### 4. 运行应用

#### 方式一：直接运行

```bash
# 安装依赖
go mod tidy

# 直接运行应用
go run main.go
```

#### 方式二：使用 Makefile（推荐）

```bash
# 查看所有可用命令
make help

# 直接运行应用
make run

# 后台启动服务
make start

# 查看服务状态
make status

# 查看服务日志
make logs

# 停止服务
make stop

# 重启服务
make restart

# 平滑重启服务
make graceful
```

#### 方式三：使用重启脚本

```bash
# 启动服务
./restart.sh start

# 平滑重启
./restart.sh graceful

# 查看状态
./restart.sh status

# 查看日志
./restart.sh logs
```

服务将在 `http://localhost:8000` 启动

## API 接口

### 创建思维导图

**POST** `/api/mindmap/create`

请求体：

```json
{
  "title": "我的思维导图",
  "data": {
    "nodeData": {
      "id": "root",
      "topic": "中心主题"
    }
  }
}
```

响应：

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "id": "458392eb-c6c6-45aa-b67f-d7c7f8e922b1"
  }
}
```

### 获取思维导图列表

**GET** `/api/mindmap/list?title=关键词`

响应：

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "list": [
      {
        "id": "458392eb-c6c6-45aa-b67f-d7c7f8e922b1",
        "title": "我的思维导图",
        "data": "{\"nodeData\": {\"id\": \"root\", \"topic\": \"中心主题\"}}",
        "createdAt": "2025-07-31 11:15:51",
        "updatedAt": "2025-07-31 11:15:51"
      }
    ],
    "total": 1
  }
}
```

## 项目结构

```
go-mind/
├── api/                    # API定义
│   └── mindmap/v1/        # 思维导图API
├── internal/              # 内部代码
│   ├── controller/        # 控制器层
│   ├── service/          # 服务层
│   ├── dao/              # 数据访问层
│   └── model/            # 数据模型
├── manifest/             # 配置文件
│   ├── config/          # 应用配置
│   └── sql/             # SQL脚本
└── main.go              # 主入口文件
```

## 开发说明

- 使用 GoFrame 的自动路由注册功能
- 支持 CORS 跨域请求
- 数据库操作使用 GoFrame 的 ORM
- JSON 字段存储思维导图数据

## 重启功能说明

### 平滑重启 (Graceful Restart)

- 支持零停机时间重启
- 新进程启动后，旧进程优雅关闭
- 不会中断正在处理的请求
- 使用 `make graceful` 或 `./restart.sh graceful` 触发

### 热重启 (Hot Reload)

- 监听文件变化自动重启
- 开发模式下自动检测代码变更
- 排除 `logs`、`tmp`、`temp` 目录
- 配置文件已启用 `hotReload: true`

### 信号处理

- `SIGTERM`: 优雅停止
- `SIGUSR1`: 平滑重启
- `SIGINT`: 强制停止

### 日志管理

- 按日期自动分割日志文件
- 支持日志压缩和自动清理
- 日志文件格式: `go-mind-{Y-m-d}.log`
