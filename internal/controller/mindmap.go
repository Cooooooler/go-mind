package controller

import (
	"context"
	v1 "go-mind/api/mindmap/v1"
	"go-mind/internal/model"
	"go-mind/internal/service"

	"github.com/gogf/gf/v2/frame/g"
)

type mindMapController struct{}

var (
	MindMap = mindMapController{}
)

// Create 创建思维导图
func (c *mindMapController) Create(ctx context.Context, req *v1.CreateReq) (res *v1.CreateRes, err error) {
	g.Log().Infof(ctx, "Controller层: 收到创建思维导图请求, 标题: %s", req.Title)

	res = &v1.CreateRes{}

	// 调用service创建思维导图
	id, err := service.MindMap.Create(ctx, model.MindMapCreateInput{
		Title: req.Title,
		Data:  req.Data,
	})
	if err != nil {
		g.Log().Errorf(ctx, "Controller层: 创建思维导图失败, 标题: %s, 错误: %v", req.Title, err)
		return nil, err
	}

	res.ID = id
	g.Log().Infof(ctx, "Controller层: 思维导图创建成功, ID: %s, 标题: %s", id, req.Title)
	return res, nil
}

// GetList 获取思维导图列表
func (c *mindMapController) GetList(ctx context.Context, req *v1.GetListReq) (res *v1.GetListRes, err error) {
	g.Log().Infof(ctx, "Controller层: 收到获取思维导图列表请求, 标题过滤: %s", req.Title)

	res = &v1.GetListRes{}

	// 调用service获取列表
	list, err := service.MindMap.GetList(ctx, model.MindMapGetListInput{
		Title: req.Title,
		Page:  1,
		Size:  100, // 默认获取100条
	})
	if err != nil {
		g.Log().Errorf(ctx, "Controller层: 获取思维导图列表失败, 错误: %v", err)
		return nil, err
	}

	res.Total = list.Total

	// 转换数据格式
	for _, item := range list.List {
		res.List = append(res.List, v1.MindMapItem{
			ID:        item.Id,
			Title:     item.Title,
			Data:      item.Data,
			CreatedAt: item.CreatedAt.Format("2006-01-02 15:04:05"),
			UpdatedAt: item.UpdatedAt.Format("2006-01-02 15:04:05"),
		})
	}

	g.Log().Infof(ctx, "Controller: 成功返回思维导图列表, 数量: %d", len(res.List))
	return res, nil
}
