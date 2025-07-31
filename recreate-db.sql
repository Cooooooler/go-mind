-- 删除旧表（如果存在）
DROP TABLE IF EXISTS `mindmap`;

-- 创建思维导图表（使用UUID）
CREATE TABLE IF NOT EXISTS `mindmap` (
  `id` varchar(36) NOT NULL COMMENT 'UUID',
  `title` varchar(255) NOT NULL DEFAULT '' COMMENT '标题',
  `data` json DEFAULT NULL COMMENT '思维导图数据',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_title` (`title`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='思维导图表';

-- 显示创建结果
SHOW TABLES;
DESCRIBE mindmap; 