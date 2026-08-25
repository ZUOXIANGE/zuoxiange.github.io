# ZUOXIANGE Blog

基于 [Hugo](https://gohugo.io/) 与 [Blowfish](https://blowfish.page/) 主题的个人技术博客，通过 GitHub Actions 自动构建并部署到 GitHub Pages。

在线访问：<https://zuoxiange.github.io/>

## 技术栈

- [Hugo](https://gohugo.io/)（extended 版）— 静态站点生成器，版本由 [.hugo-version](.hugo-version) 锁定（v0.164.0），本地与 CI 保持一致
- [Blowfish](https://blowfish.page/) — Hugo 主题，以 git submodule 方式引入（[.gitmodules](.gitmodules)）
- [GitHub Actions](https://github.com/features/actions) — CI/CD，推送 `main` 自动部署，PR 自动构建校验
- PowerShell — 仓库脚本（front matter 校验、git hooks 启用）

## 目录结构

```
├── archetypes/            # 新文章模板（hugo new 时使用）
├── assets/
│   ├── css/custom.css     # 站点级代码块美化（行号、One Dark 高亮等）
│   └── img/               # 作者头像 / 社交分享图 / 站点背景
├── config/_default/       # 站点配置
│   ├── hugo.toml          # 核心配置（taxonomies、related、sitemap 等）
│   ├── params.toml        # 主题行为参数（首页布局、文章显示项等）
│   ├── languages.zh-cn.toml # 语言与作者信息
│   ├── menus.zh-cn.toml   # 导航 / 页脚菜单
│   └── markup.toml        # Goldmark、语法高亮、目录设置
├── content/
│   ├── posts/             # 博客文章
│   ├── notes/             # 备忘 / 随手记录
│   └── about.md           # 关于页
├── layouts/partials/      # 站点层模板覆盖（不修改主题）
│   ├── footer.html        # zoom 兼容修复、mermaid 渲染
│   └── extend-footer.html # 代码块语言标签栏注入
├── scripts/
│   ├── check-frontmatter.ps1 # front matter 必填字段校验
│   └── setup-hooks.ps1    # 启用仓库内 git hooks
├── .githooks/pre-commit   # 提交前自动校验 front matter
├── .github/workflows/     # build.yml（PR 检查）/ deploy.yml（发布）
└── themes/blowfish/       # 主题 submodule（勿直接修改）
```

## 快速开始

### 环境要求

- [Hugo extended](https://gohugo.io/installation/)（版本见 `.hugo-version`）
- PowerShell 7+（运行仓库脚本）

### 首次克隆

主题以 submodule 方式引入，克隆后需先初始化：

```bash
git clone https://github.com/ZUOXIANGE/zuoxiange.github.io.git
cd zuoxiange.github.io
git submodule update --init --recursive
```

### 启用 git hooks（建议）

仓库内置 pre-commit 校验（front matter 必填字段），在仓库根目录执行一次：

```bash
pwsh -NoProfile -File scripts/setup-hooks.ps1
```

### 启动开发服务器

```bash
hugo server
```

浏览器访问 <http://localhost:1313/>，修改文件自动热更新。预览草稿文章使用 `hugo server -D`。

## 写文章

### 博客文章（posts/）

使用 Hugo 命令创建新文章：

```bash
hugo new content/posts/文章标题.md
```

新文章默认是草稿（`draft = true`），发布前需要改为 `draft = false`。

Front Matter 示例（`slug`、`description`、`categories`、`tags` 为必填，缺失会被 CI / pre-commit 拦截）：

```toml
+++
date = '2026-08-18T00:00:00+08:00'
draft = false
title = '文章标题'
slug = 'english-slug-for-url'
aliases = ['/posts/中文文件名/']
description = '文章简介（SEO 约定，必填）'
categories = ['分类']
tags = ['标签1', '标签2']
+++
```

> 说明：
> - `slug` 用于生成英文 URL，避免中文文件名 URL
> - 文章内容中的 ` ```mermaid ` 代码围栏可直接渲染图表，无需 shortcode

### 备忘 / 笔记（notes/）

同样使用 `hugo new` 创建，Front Matter 约定与 posts 一致，仅目录不同：

```bash
hugo new content/notes/标题.md
```

## 质量检查

[scripts/check-frontmatter.ps1](scripts/check-frontmatter.ps1) 会检查 `content/posts/` 下所有文章的 front matter 是否包含非空的 `slug`、`description`、`categories`、`tags`：

```bash
pwsh -NoProfile -File scripts/check-frontmatter.ps1
```

该检查同时被 [.githooks/pre-commit](.githooks/pre-commit)（提交前）和 GitHub Actions（CI）自动执行，未通过会阻止提交 / 构建。

## 部署

- 推送代码到 `main` 分支 → [deploy.yml](.github/workflows/deploy.yml) 自动构建并部署到 GitHub Pages
- 提交 Pull Request → [build.yml](.github/workflows/build.yml) 自动执行 front matter 校验 + `hugo --minify` 构建检查

无需手动操作，等待 Actions 完成即可。

## 站点自定义

为避免修改主题 submodule（升级会被覆盖），站点级定制全部放在独立位置：

- **代码块样式**：语法高亮、行号、语言标签栏等见 [assets/css/custom.css](assets/css/custom.css) 与 [layouts/partials/extend-footer.html](layouts/partials/extend-footer.html)
- **主题组件覆盖**：如 [layouts/partials/footer.html](layouts/partials/footer.html)（修复 zoom 兼容、支持 mermaid）
- **自定义图片**：作者头像 / 社交分享图 / 站点背景存放在 `assets/img/`，通过主题参数引用

## 主题配置

主题参数集中在 [config/_default/params.toml](config/_default/params.toml)，主要可调项：

- 首页布局（`[homepage] layout`）：`profile` / `hero` / `card` / `landing` 等
- 配色方案（`colorScheme`）与外观（`defaultAppearance` / `autoSwitchAppearance`）
- 站点背景与社交分享图（`defaultBackgroundImage` / `defaultSocialImage`）
- 作者信息（[languages.zh-cn.toml](config/_default/languages.zh-cn.toml) 中的 `[params.author]`）

完整参数说明见 [Blowfish 官方文档](https://blowfish.page/docs/configuration/)。

## 更新主题

主题为 git submodule，升级方式：

```bash
git submodule update --remote --merge
```

> 升级后站点级自定义（`layouts/`、`assets/css/custom.css`、`config/`）不受影响；直接修改 `themes/blowfish/` 内的改动会被覆盖。
