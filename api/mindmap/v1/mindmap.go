package v1

import (
	"github.com/gogf/gf/v2/frame/g"
)

// CreateReq 创建思维导图请求
type CreateReq struct {
	g.Meta `path:"/create" tags:"MindMap" method:"post" summary:"创建思维导图"`
	Data   interface{} `json:"data" v:"required" dc:"思维导图数据"`
	Title  string      `json:"title" v:"required" dc:"标题"`
}

// CreateRes 创建思维导图响应
type CreateRes struct {
	ID string `json:"id" dc:"思维导图UUID"`
}

// GetListReq 获取思维导图列表请求
type GetListReq struct {
	g.Meta `path:"/list" tags:"MindMap" method:"get" summary:"获取思维导图列表"`
	Title  string `json:"title" dc:"标题过滤"`
}

// GetListRes 获取思维导图列表响应
type GetListRes struct {
	List  []MindMapItem `json:"list" dc:"思维导图列表"`
	Total int           `json:"total" dc:"总数"`
}

// MindMapItem 思维导图项
type MindMapItem struct {
	ID        string      `json:"id" dc:"思维导图UUID"`
	Title     string      `json:"title" dc:"标题"`
	Data      interface{} `json:"data" dc:"思维导图数据(JSON格式)"`
	CreatedAt string      `json:"createdAt" dc:"创建时间(格式: 2006-01-02 15:04:05)"`
	UpdatedAt string      `json:"updatedAt" dc:"更新时间(格式: 2006-01-02 15:04:05)"`
}
