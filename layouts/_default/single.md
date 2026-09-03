{{- /* 站点级自定义：MD 输出格式模板。为每篇单页文章输出以中文标题开头的 Markdown 正文（不含 front matter），供「下载本文」功能使用（不修改主题）。 */ -}}
# {{ .Title }}

{{ strings.TrimLeft "\r\n" .RawContent }}
