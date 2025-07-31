package service

import (
	"context"
	"go-mind/internal/dao"
	"go-mind/internal/model"
)

type mindMapService struct{}

var (
	MindMap = mindMapService{}
)

// Create 创建思维导图
func (s *mindMapService) Create(ctx context.Context, in model.MindMapCreateInput) (string, error) {
	return dao.MindMap.Create(ctx, in)
}

// GetList 获取思维导图列表
func (s *mindMapService) GetList(ctx context.Context, in model.MindMapGetListInput) (out *model.MindMapGetListOutput, err error) {
	// 设置默认分页参数
	if in.Page <= 0 {
		in.Page = 1
	}
	if in.Size <= 0 {
		in.Size = 10
	}

	return dao.MindMap.GetList(ctx, in)
}
