---
kind: configuration_system
name: Hugo + Blowfish 站点配置体系（config/_default TOML 分层）
category: configuration_system
scope:
    - '**'
source_files:
    - config/_default/hugo.toml
    - config/_default/params.toml
    - config/_default/languages.zh-cn.toml
    - config/_default/menus.zh-cn.toml
    - config/_default/markup.toml
    - .hugo-version
    - themes/blowfish/config/_default/params.toml
---

## 1. 使用的系统与框架

本项目是 **Hugo extended** 静态站点，主题采用第三方 **Blowfish**（通过 `.gitmodules` 作为 submodule 引入）。站点自身的运行时配置全部使用 Hugo 原生支持的 **TOML** 格式，位于 `config/_default/` 目录；没有自定义的配置文件加载逻辑、环境变量注入或 secrets 管理——所有值直接写在 TOML 中。

## 2. 关键文件与职责划分

核心配置集中在 `config/_default/`，按 Hugo 约定拆分为多个 TOML 片段：

- `hugo.toml` — Hugo 核心站点配置：`baseURL`、`title`、`theme = 'blowfish'`、`defaultContentLanguage = 'zh-cn'`、`enableGitInfo`、分页、sitemap、taxonomies（tag/category/author/series）、mediaTypes/outputFormats（额外输出每篇文章的 Markdown 原文以支持「下载本文」功能）、related 索引权重等。
- `params.toml` — Blowfish 主题参数：外观（colorScheme、defaultAppearance、autoSwitchAppearance）、搜索、代码复制、无障碍、导航布局、首页布局、文章/列表/分类页显示开关、评论（giscus）、相关文章等。注释指向官方文档 `https://blowfish.page/docs/configuration/#theme-parameters`。
- `languages.zh-cn.toml` — 单语言（简体中文）定义：locale、label、weight、params.displayName/isoCode/dateFormat/description，以及 params.author（name、image、headline、bio、links 含 github 与 rss）。
- `menus.zh-cn.toml` — 顶部 main 菜单与页脚 footer 菜单条目（首页/文章/备忘/分类/标签/关于），每个条目含 name/pageRef/url/weight。
- `markup.toml` — Goldmark 渲染器设置：wrapStandAloneImageWithinParagraph=false、block attribute=true、unsafe=true、passthrough 数学公式分隔符（`\[\]`、`$$`、`\(\)`）、highlight 行号、tableOfContents startLevel=2/endLevel=4。

辅助文件：
- `.hugo-version` — 锁定 Hugo 版本，配合 GitHub Actions 构建。
- `themes/blowfish/config/_default/` — 主题自带默认配置，站点级 `config/_default/` 会覆盖同名键。

## 3. 架构与约定

- **Hugo 标准 config 目录结构**：站点根目录下的 `config/_default/*.toml` 是 Hugo 识别的默认配置片段，由 Hugo 在启动时自动合并。
- **主题覆盖模式**：项目通过 git submodule 引入 `themes/blowfish`，站点配置只声明需要覆盖的主题参数（如 `params.toml`），其余沿用主题默认值。
- **多片段拆分**：将 Hugo 核心、主题参数、语言、菜单、Markdown 渲染各拆为独立 TOML 文件，便于维护。
- **中文优先**：`defaultContentLanguage = 'zh-cn'`，且语言配置仅定义了 `zh-cn`，未启用多语言切换。
- **无环境分层**：仓库中不存在 `config/development/`、`config/production/` 等多环境目录，也没有 `.env` 文件或环境变量读取逻辑。
- **无 secrets 管理**：所有敏感信息（如 baseURL、RSS 地址、GitHub 链接）均以明文形式写入 TOML。

## 4. 观察到的约定与约束

- 站点根目录必须存在 `config/_default/` 目录，其中至少包含 `hugo.toml`（否则 Hugo 无法识别 theme/baseURL 等基础项）。
- 主题参数统一放在 `params.toml` 的 `[params.*]` 段下，遵循 Blowfish 主题定义的键名（如 `colorScheme`、`defaultAppearance`、`header.layout`、`homepage.layout`、`article.showComments` 等）。
- 语言相关元数据（displayName、isoCode、dateFormat、author 信息）集中放在 `languages.zh-cn.toml` 的 `[params]` / `[params.author]` 段下。
- 菜单条目统一使用 `[[main]]` / `[[footer]]` 数组表语法，并通过 `weight` 控制排序。
- Markdown 渲染能力（KaTeX 数学公式、Mermaid 图表、代码高亮）依赖 `markup.toml` 中的 goldmark extensions/passthrough/highlight 配置，注释明确说明这些设置是「主题正常运行所必需的」。
- 站点额外输出了每篇文章的 Markdown 原文（`outputFormats.MD` + `outputs.page = ['HTML', 'MD']`），这是为「下载本文」功能而做的定制约定。
- Hugo 版本通过 `.hugo-version` 文件锁定，CI 流水线据此安装对应版本的 Hugo。

本仓库没有实现环境变量注入、feature flags、密钥轮换或运行时配置热更新等高级特性；配置系统即 Hugo 原生的 TOML 配置 + Blowfish 主题参数的组合。