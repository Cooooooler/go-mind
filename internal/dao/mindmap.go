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

	g.Log().Infof(ctx, "开始创建思维导图, ID: %s, 标题: %s", id, in.Title)

	data := g.Map{
		"id":    id,
		"title": in.Title,
		"data":  in.Data,
	}

	_, err := g.DB().Model("mindmap").Data(data).Insert()
	if err != nil {
		g.Log().Errorf(ctx, "创建思维导图失败, ID: %s, 错误: %v", id, err)
		return "", err
	}

	g.Log().Infof(ctx, "思维导图创建成功, ID: %s, 标题: %s", id, in.Title)
	return id, nil
}

// GetList 获取思维导图列表
func (dao *mindMapDao) GetList(ctx context.Context, in model.MindMapGetListInput) (out *model.MindMapGetListOutput, err error) {
	g.Log().Infof(ctx, "开始获取思维导图列表, 标题过滤: %s, 页码: %d, 每页大小: %d", in.Title, in.Page, in.Size)

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
		g.Log().Errorf(ctx, "查询思维导图总数失败, 错误: %v", err)
		return nil, err
	}
	out.Total = count

	g.Log().Infof(ctx, "查询到思维导图总数: %d", count)

	// 查询列表
	if count > 0 {
		list, err := g.DB().Model("mindmap").
			Fields("id,title,data,created_at,updated_at").
			Where(where).
			Page(in.Page, in.Size).
			Order("created_at desc").
			All()
		if err != nil {
			g.Log().Errorf(ctx, "查询思维导图列表失败, 错误: %v", err)
			return nil, err
		}

		if err := list.Structs(&out.List); err != nil {
			g.Log().Errorf(ctx, "转换思维导图列表数据失败, 错误: %v", err)
			return nil, err
		}

		g.Log().Infof(ctx, "成功获取思维导图列表, 数量: %d", len(out.List))
	}

	return out, nil
}
