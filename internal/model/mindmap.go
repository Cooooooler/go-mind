package model

import (
	v1 "go-mind/api/mindmap/v1"
	"time"
)

// MindMap 思维导图模型
type MindMap struct {
	Id        string            `json:"id"         description:"UUID"`
	Title     string            `json:"title"      description:"标题"`
	Data      v1.MindElixirData `json:"data"       description:"思维导图数据"`
	CreatedAt *time.Time        `json:"createdAt"  description:"创建时间"`
	UpdatedAt *time.Time        `json:"updatedAt"  description:"更新时间"`
}

// MindMapCreateInput 创建思维导图输入
type MindMapCreateInput struct {
	Title string            `json:"title" v:"required" dc:"标题"`
	Data  v1.MindElixirData `json:"data" v:"required" dc:"思维导图数据"`
}

// MindMapGetListInput 获取思维导图列表输入
type MindMapGetListInput struct {
	Title string `json:"title" dc:"标题过滤"`
	Page  int    `json:"page" dc:"页码"`
	Size  int    `json:"size" dc:"每页大小"`
}

// MindMapGetListOutput 获取思维导图列表输出
type MindMapGetListOutput struct {
	List  []MindMap `json:"list" description:"列表"`
	Total int       `json:"total" description:"总数"`
	Page  int       `json:"page" description:"页码"`
	Size  int       `json:"size" description:"每页大小"`
}

// MindMapDeleteInput 删除思维导图输入
type MindMapDeleteInput struct {
	ID string `json:"id" v:"required" dc:"思维导图UUID"`
}
