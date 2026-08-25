# AGENTS.md

面向 AI 编码代理 / 协作者的仓库工作指南。本文件描述本项目的技术栈、命令与硬性约定，改动代码前请先阅读。

## 项目概述

基于 [Hugo](https://gohugo.io/)（extended，v0.164.0）+ [Blowfish](https://blowfish.page/) 主题的个人技术博客，通过 GitHub Actions 部署到 GitHub Pages（<https://zuoxiange.github.io/>）。

- 单语言站点：`zh-cn`
- 主题以 **git submodule** 引入（[.gitmodules](.gitmodules)）
- 内容分两个区块：`content/posts/`（正式文章）、`content/notes/`（备忘）
- CI/CD：推送 `main` 自动部署，PR 自动构建校验

## 常用命令

```bash
# 启动本地开发服务器（预览草稿加 -D）
hugo server
hugo server -D

# 新建文章 / 笔记（默认 draft = true）
hugo new content/posts/标题.md
hugo new content/notes/标题.md

# front matter 必填字段校验（提交前 / CI 都会跑）
pwsh -NoProfile -File scripts/check-frontmatter.ps1

# 生产构建
hugo --minify --gc --cleanDestinationDir

# 启用仓库内 git hooks（一次即可）
pwsh -NoProfile -File scripts/setup-hooks.ps1
```

## 目录速览

- `config/_default/` — 所有站点配置（hugo / params / languages.zh-cn / menus.zh-cn / markup）
- `content/posts/`、`content/notes/` — 文章与备忘
- `layouts/partials/` — 站点级模板覆盖（不要改主题）
- `assets/css/custom.css` — 站点级代码块样式；`assets/img/` — 自定义图片
- `scripts/` — front matter 校验、hooks 启用脚本
- `.githooks/` — 仓库内 git hooks（pre-commit）
- `.github/workflows/` — build.yml（PR 检查）、deploy.yml（发布）
- `themes/blowfish/` — 主题 submodule，**禁止直接修改**

## 硬性约定

### 主题与配置

- **禁止修改 `themes/blowfish/` 内任何文件**（submodule，改动会在升级时被覆盖）。站点级自定义一律通过以下方式：
  - 模板覆盖 → 新建/修改 `layouts/partials/` 下的同名 partial
  - 样式 → `assets/css/custom.css`
  - 主题参数 → `config/_default/params.toml`（含 hugo.toml / languages / menus / markup）
- `config/_default/markup.toml` 中的 `goldmark.renderer.unsafe = true` 是主题运行所必需，不要关闭。
- 日期格式使用 Go 参考布局 `2006-01-02`（见 `languages.zh-cn.toml`），不要改成其他格式。

### 文章内容（posts/ 与 notes/ 通用）

新文章由 `archetypes/default.md` 生成，默认 `draft = true`。**发布必须改为 `draft = false`**。

Front matter 必填字段（缺失会同时被 pre-commit 与 CI 拦截）：

| 字段 | 说明 |
| --- | --- |
| `slug` | 英文 slug，生成英文 URL，避免中文文件名 URL |
| `description` | 文章简介，SEO 约定 |
| `categories` | 分类（非空数组） |
| `tags` | 标签（非空数组） |

完整示例：

```toml
+++
date = '2026-08-18T00:00:00+08:00'
draft = false
title = '文章标题'
slug = 'english-slug-for-url'
aliases = ['/posts/中文文件名/']
description = '文章简介'
categories = ['分类']
tags = ['标签1', '标签2']
+++
```

内容规范：

- 每篇文章必须写 `description`
- **不要**为文章添加特色图（feature image）、`<!--more-->` 摘要标记或系列分组
- 图表直接用 ` ```mermaid ` 代码围栏书写即可渲染（无需 `{{< mermaid >}}` shortcode）

### 代码块

- 语法高亮行号由 `markup.toml` 控制（`lineNos = true`、`lineNumbersInTable = false`，后者避免长代码被裁切）
- 高亮配色与视觉样式在 `assets/css/custom.css`（暗色 One Dark、亮色 GitHub light）
- 语言标签栏由 `layouts/partials/extend-footer.html` 依据 `code[data-lang]` 注入，无需手动添加

## 构建与验证

1. 修改代码/内容后，运行 `hugo server` 确认构建无报错、页面渲染正常
2. 运行 `pwsh -NoProfile -File scripts/check-frontmatter.ps1` 确认必填字段完整
3. CI 中 `hugo --minify --gc --cleanDestinationDir` 会完整构建，PR 未通过构建会被拦截

## CI/CD

- `push` 到 `main` → [deploy.yml](.github/workflows/deploy.yml) 构建并部署 GitHub Pages
- PR 到 `main` → [build.yml](.github/workflows/build.yml) 运行 front matter 校验 + 构建检查
- 两者都通过 `actions-hugo` 使用 `.hugo-version` 锁定的版本，保证本地与 CI 一致

## 已知坑

- Hugo server 若在 `assets/css` 等资源目录创建前启动，打包可能缺少新资源，改动资源后建议重启 server
- Blowfish v3 存在 `mediumZoom is not defined` 兼容问题，已在 `layouts/partials/footer.html` 中通过 `DOMContentLoaded` + 存在性守卫修复，不要重复添加 zoom 初始化逻辑
- 更新主题：`git submodule update --remote --merge`，升级后站点级自定义不受影响
