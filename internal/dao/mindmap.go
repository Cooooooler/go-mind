package dao

import (
	"context"
	"fmt"
	"go-mind/internal/model"
	"time"

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

// Delete 删除思维导图
func (dao *mindMapDao) Delete(ctx context.Context, id string) error {
	g.Log().Infof(ctx, "开始删除思维导图, ID: %s", id)

	// 先检查思维导图是否存在
	count, err := g.DB().Model("mindmap").Where("id", id).Count()
	if err != nil {
		g.Log().Errorf(ctx, "检查思维导图是否存在失败, ID: %s, 错误: %v", id, err)
		return err
	}

	if count == 0 {
		g.Log().Warningf(ctx, "思维导图不存在, ID: %s", id)
		return fmt.Errorf("思维导图不存在")
	}

	// 删除思维导图
	result, err := g.DB().Model("mindmap").Where("id", id).Delete()
	if err != nil {
		g.Log().Errorf(ctx, "删除思维导图失败, ID: %s, 错误: %v", id, err)
		return err
	}

	affectedRows, err := result.RowsAffected()
	if err != nil {
		g.Log().Errorf(ctx, "获取删除影响行数失败, ID: %s, 错误: %v", id, err)
		return err
	}

	if affectedRows == 0 {
		g.Log().Warningf(ctx, "删除思维导图失败, 影响行数为0, ID: %s", id)
		return fmt.Errorf("删除失败")
	}

	g.Log().Infof(ctx, "思维导图删除成功, ID: %s, 影响行数: %d", id, affectedRows)
	return nil
}

// Update 更新思维导图
func (dao *mindMapDao) Update(ctx context.Context, in model.MindMapUpdateInput) error {
	g.Log().Infof(ctx, "开始更新思维导图, ID: %s, 标题: %s", in.ID, in.Title)

	// 先检查思维导图是否存在
	count, err := g.DB().Model("mindmap").Where("id", in.ID).Count()
	if err != nil {
		g.Log().Errorf(ctx, "检查思维导图是否存在失败, ID: %s, 错误: %v", in.ID, err)
		return err
	}

	if count == 0 {
		g.Log().Warningf(ctx, "思维导图不存在, ID: %s", in.ID)
		return fmt.Errorf("思维导图不存在")
	}

	// 更新思维导图
	now := time.Now()
	data := g.Map{
		"title":      in.Title,
		"data":       in.Data,
		"updated_at": now,
	}

	result, err := g.DB().Model("mindmap").Data(data).Where("id", in.ID).Update()
	if err != nil {
		g.Log().Errorf(ctx, "更新思维导图失败, ID: %s, 错误: %v", in.ID, err)
		return err
	}

	affectedRows, err := result.RowsAffected()
	if err != nil {
		g.Log().Errorf(ctx, "获取更新影响行数失败, ID: %s, 错误: %v", in.ID, err)
		return err
	}

	if affectedRows == 0 {
		g.Log().Warningf(ctx, "更新思维导图失败, 影响行数为0, ID: %s", in.ID)
		return fmt.Errorf("更新失败")
	}

	g.Log().Infof(ctx, "思维导图更新成功, ID: %s, 标题: %s, 影响行数: %d", in.ID, in.Title, affectedRows)
	return nil
}
