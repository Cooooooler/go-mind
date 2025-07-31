package controller

import (
	"context"
	v1 "go-mind/api/mindmap/v1"
	"go-mind/internal/model"
	"go-mind/internal/service"
)

type mindMapController struct{}

var (
	MindMap = mindMapController{}
)

// Create 创建思维导图
func (c *mindMapController) Create(ctx context.Context, req *v1.CreateReq) (res *v1.CreateRes, err error) {
	res = &v1.CreateRes{}

	// 调用service创建思维导图
	id, err := service.MindMap.Create(ctx, model.MindMapCreateInput{
		Title: req.Title,
		Data:  req.Data,
	})
	if err != nil {
		return nil, err
	}

	res.ID = id
	return res, nil
}

// GetList 获取思维导图列表
func (c *mindMapController) GetList(ctx context.Context, req *v1.GetListReq) (res *v1.GetListRes, err error) {
	res = &v1.GetListRes{}

	// 调用service获取列表
	list, err := service.MindMap.GetList(ctx, model.MindMapGetListInput{
		Title: req.Title,
		Page:  1,
		Size:  100, // 默认获取100条
	})
	if err != nil {
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

	return res, nil
}
