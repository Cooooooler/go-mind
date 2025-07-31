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

```bash
# 安装依赖
go mod tidy

# 运行应用
go run main.go
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
