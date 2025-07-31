package dao

import (
	"context"
	"go-mind/internal/model"

	"github.com/gogf/gf/v2/frame/g"
	"github.com/google/uuid"
)

type mindMapDao struct{}

var (
	MindMap = mindMapDao{}
)

// Create 创建思维导图
func (dao *mindMapDao) Create(ctx context.Context, in model.MindMapCreateInput) (string, error) {
	// 生成UUID
	id := uuid.New().String()

	data := g.Map{
		"id":    id,
		"title": in.Title,
		"data":  in.Data,
	}

	_, err := g.DB().Model("mindmap").Data(data).Insert()
	if err != nil {
		return "", err
	}

	return id, nil
}

// GetList 获取思维导图列表
func (dao *mindMapDao) GetList(ctx context.Context, in model.MindMapGetListInput) (out *model.MindMapGetListOutput, err error) {
	out = &model.MindMapGetListOutput{
		Page: in.Page,
		Size: in.Size,
	}

	// 构建查询条件
	where := g.Map{}
	if in.Title != "" {
		where["title like ?"] = "%" + in.Title + "%"
	}

	// 查询总数
	count, err := g.DB().Model("mindmap").Where(where).Count()
	if err != nil {
		return nil, err
	}
	out.Total = count

	// 查询列表
	if count > 0 {
		list, err := g.DB().Model("mindmap").
			Fields("id,title,data,created_at,updated_at").
			Where(where).
			Page(in.Page, in.Size).
			Order("created_at desc").
			All()
		if err != nil {
			return nil, err
		}

		if err := list.Structs(&out.List); err != nil {
			return nil, err
		}
	}

	return out, nil
}
