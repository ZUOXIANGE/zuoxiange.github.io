---
kind: frontend_style
name: Blowfish 主题 + Tailwind CSS 样式体系与站点级定制
category: frontend_style
scope:
    - '**'
source_files:
    - themes/blowfish/tailwind.config.js
    - themes/blowfish/assets/css/main.css
    - assets/css/custom.css
    - config/_default/params.toml
---

## 1. 系统与方法论

本仓库是一个基于 Hugo extended 的个人博客，前端样式完全由子模块引入的 **Blowfish** 主题提供。主题采用以下技术栈：

- **Tailwind CSS v4**（`@import "tailwindcss"`），通过 `themes/blowfish/tailwind.config.js` 配置。
- **CSS Layers**（`layer(utilities)` / `layer(components)`）组织样式优先级。
- **CSS 自定义属性（CSS Variables）**作为设计令牌：`--color-neutral-*`、`--color-primary-*`、`--color-secondary-*`，在亮/暗模式下由主题方案文件切换。
- **darkMode: "class"**：通过给 `<html>` 添加 `.dark` 类切换暗色模式，而非媒体查询。
- **@tailwindcss/typography**（`prose`）+ **@tailwindcss/forms** 插件。
- 响应式断点被重写为 `sm:640px, md:853px, lg:1024px, xl:1280px, 2xl:1536px`。

站点自身不编写 Tailwind 原子类，而是在 `assets/css/custom.css` 中用传统 CSS 覆盖主题行为。

## 2. 关键文件

- `themes/blowfish/tailwind.config.js` — Tailwind 主题扩展、颜色映射、`prose` 排版样式。
- `themes/blowfish/assets/css/main.css` — 主题主入口，`@config "../../tailwind.config.js"` 并导入组件层（chroma、tabs、zen-mode、gist、a11y、admonition）。
- `themes/blowfish/assets/css/schemes/*.css` — 17 套内置配色方案（blowfish、github、ocean、neon、one-light、slate 等），每套定义一组 CSS 变量。
- `themes/blowfish/assets/css/components/` — 主题组件样式（chroma 语法高亮、tabs、zen-mode、admonition 等）。
- `assets/css/custom.css` — 站点级自定义样式（约 400 行），是本次仓库唯一新增的样式源。
- `config/_default/params.toml` — 主题参数，声明 `colorScheme = 'blowfish'`、`defaultAppearance = 'light'`、`autoSwitchAppearance = true` 等视觉开关。

## 3. 架构与约定

### 3.1 主题 + 站点分层

| 层级 | 位置 | 职责 |
|---|---|---|
| 主题源码 | `themes/blowfish/` | 完整可独立使用的 Hugo 主题，含 Tailwind 构建、图标、JS、多语言 i18n |
| 站点配置 | `config/_default/params.toml` | 选择主题配色 (`colorScheme`)、外观默认值、功能开关 |
| 站点样式覆盖 | `assets/css/custom.css` | 仅覆盖主题行为，不修改主题源码 |

站点通过 Hugo 的 `layouts/partials/*` 覆盖主题 partial（如 `comments.html`、`footer.html`、`article-meta/basic.html`、`toc.html`），实现 giscus 评论、Mermaid 放大预览、VS Code 风格代码块等增强，而不改动主题本身。

### 3.2 设计令牌（Design Tokens）

所有颜色通过 CSS 变量暴露，Tailwind 在 `tailwind.config.js` 中将 `primary`/`secondary`/`neutral` 三色系映射到 `rgba(var(--color-primary-*, <alpha-value>))` 形式。站点自定义样式也统一使用这些变量（例如 `rgba(var(--color-neutral-300), 1)`），从而保证亮/暗模式自动生效。

### 3.3 代码高亮（Chroma）

站点在 `custom.css` 中覆盖了 Chroma 生成的 `.chroma *` 类，将语法配色从主题的 GitHub Light/Dark 替换为 **VS Code Light+ / Dark+** 两套硬编码调色板，并补齐了遗漏 token（`.n`, `.nx`, `.na`, `.l`, `.ld`, `.lnt`, `.bg`, `.go`, `.ge`, `.gh`, `.gu`, `.gp`, `.gs`, `.gt`, `.gl`）。同时定义了 VS Code 风格的容器：

- `.highlight-wrapper`：带圆角、细边框和极浅阴影的容器。
- `.codeblock-title`：模拟 VS Code 标题栏，包含红黄绿三色窗口按钮（`.window-dot-red/yellow/green`）和语言标签。
- `.copy-button`：悬停显示的复制胶囊按钮。
- 行号列 `.chroma .ln` 固定宽度、右对齐、不可选中。

### 3.4 文章阅读体验

- 正文最大宽度从默认的 `max-w-prose(65ch)` 放宽至 `120ch`（`#single_header`, `.article-content`, `article > footer`）。
- 相关文章卡片摘要截断为 2 行（`-webkit-line-clamp: 2`），隐藏分类/标签胶囊以压缩高度。
- 桌面端（`min-width: 1024px`）目录面板脱离文档流，使用 `position: fixed` 悬浮于文章右侧，展开时限制 `max-height: calc(100vh - 6rem)` 并在内部滚动；打印时隐藏。

### 3.5 Mermaid 图表放大

`.mermaid` 元素上叠加一个放大镜伪元素提示，点击后通过 JS 打开全屏遮罩（`.mermaid-zoom-overlay`，`z-index: 1000`），以原始分辨率渲染 SVG，避免缩放模糊。

### 3.6 响应式策略

- 全局断点由 Tailwind 配置重写（`md: 853px` 非标准 768px）。
- 站点自定义样式主要使用原生 `@media (min-width: 1024px)` 针对桌面端目录面板。
- 主题已内置 RTL 支持（`rtl:` 前缀工具类）。
- 尊重 `prefers-reduced-motion`：禁用 landing hero 的 staggered 动画并关闭平滑滚动。

## 4. 约定与约束

- **站点样式只放在 `assets/css/custom.css`**：主题源码位于 git submodule，不应直接修改 `themes/blowfish/` 下的样式。
- **颜色必须使用 CSS 变量**：`--color-neutral-*` / `--color-primary-*` / `--color-secondary-*`，禁止在站点样式中硬编码色值以保证暗模式兼容（`custom.css` 中除 Chroma 配色外均遵循此约定）。
- **暗模式通过 `.dark` 类切换**：所有暗态规则使用 `.dark .selector` 选择器（见 `custom.css` 中 `.dark .highlight-wrapper`、`.dark .chroma` 等）。
- **主题配色由 `config/_default/params.toml` 的 `colorScheme` 控制**，当前值为 `'blowfish'`。
- **Tailwind 入口为 `themes/blowfish/assets/css/main.css`**，站点无需重新编译 Tailwind，Hugo 会按主题配置处理。
- **Chroma 语法高亮覆盖需保持亮/暗双份规则**：`custom.css` 中每个 `.chroma .xxx` 都对应一份 `.dark .chroma .xxx`，防止回落到主题默认配色。
- **组件类名命名沿用主题约定**：站点覆盖的类（如 `.highlight-wrapper`、`.copy-button`、`.article-link--related`）与 Blowfish 主题输出一致，确保升级主题后仍可覆盖。