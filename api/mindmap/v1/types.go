package v1

// MindElixirData 思维导图数据结构
type MindElixirData struct {
	NodeData  NodeObj   `json:"nodeData"`
	Arrows    []Arrow   `json:"arrows,omitempty"`
	Summaries []Summary `json:"summaries,omitempty"`
	Direction *int      `json:"direction,omitempty"`
	Theme     *Theme    `json:"theme,omitempty"`
}

// NodeObj 节点对象
type NodeObj struct {
	ID        string     `json:"id"`
	Topic     string     `json:"topic"`
	Children  []NodeObj  `json:"children,omitempty"`
	Tags      []string   `json:"tags,omitempty"`
	Icons     []string   `json:"icons,omitempty"`
	HyperLink string     `json:"hyperLink,omitempty"`
	Note      string     `json:"note,omitempty"`
	Expanded  bool       `json:"expanded,omitempty"`
	Style     *NodeStyle `json:"style,omitempty"`
}

// NodeStyle 节点样式
type NodeStyle struct {
	FontSize   string `json:"fontSize,omitempty"`
	FontFamily string `json:"fontFamily,omitempty"`
	Color      string `json:"color,omitempty"`
	Background string `json:"background,omitempty"`
	Border     string `json:"border,omitempty"`
}

// Arrow 箭头
type Arrow struct {
	ID    string `json:"id"`
	From  string `json:"from"`
	To    string `json:"to"`
	Label string `json:"label,omitempty"`
	Color string `json:"color,omitempty"`
	Width int    `json:"width,omitempty"`
	Style string `json:"style,omitempty"`
}

// Summary 摘要
type Summary struct {
	ID       string   `json:"id"`
	Parent   string   `json:"parent"`
	Children []string `json:"children"`
	Color    string   `json:"color,omitempty"`
}

// Theme 主题
type Theme struct {
	Name    string            `json:"name"`
	Type    string            `json:"type"`
	Palette []string          `json:"palette"`
	CssVar  map[string]string `json:"cssVar"`
}
 