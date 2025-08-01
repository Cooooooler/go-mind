package service

import (
	"context"
	"go-mind/internal/dao"
	"go-mind/internal/model"

	"github.com/gogf/gf/v2/frame/g"
)

type mindMapService struct{}

var (
	MindMap = mindMapService{}
)

// Create 创建思维导图
func (s *mindMapService) Create(ctx context.Context, in model.MindMapCreateInput) (string, error) {
	g.Log().Infof(ctx, "Service层: 开始创建思维导图, 标题: %s", in.Title)

	id, err := dao.MindMap.Create(ctx, in)
	if err != nil {
		g.Log().Errorf(ctx, "Service层: 创建思维导图失败, 标题: %s, 错误: %v", in.Title, err)
		return "", err
	}

	g.Log().Infof(ctx, "Service层: 思维导图创建成功, ID: %s, 标题: %s", id, in.Title)
	return id, nil
}

// GetList 获取思维导图列表
func (s *mindMapService) GetList(ctx context.Context, in model.MindMapGetListInput) (out *model.MindMapGetListOutput, err error) {
	g.Log().Infof(ctx, "Service层: 开始获取思维导图列表, 标题过滤: %s", in.Title)

	// 设置默认分页参数
	if in.Page <= 0 {
		in.Page = 1
	}
	if in.Size <= 0 {
		in.Size = 10
	}

	out, err = dao.MindMap.GetList(ctx, in)
	if err != nil {
		g.Log().Errorf(ctx, "Service层: 获取思维导图列表失败, 错误: %v", err)
		return nil, err
	}

	g.Log().Infof(ctx, "Service层: 成功获取思维导图列表, 总数: %d", out.Total)
	return out, nil
}
