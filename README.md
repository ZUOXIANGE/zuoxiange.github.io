# 我的博客

基于 [Hugo](https://gohugo.io/) 与 [Blowfish](https://blowfish.page/) 主题的个人博客，通过 GitHub Actions 自动部署到 GitHub Pages。

在线访问：<https://zuoxiange.github.io/>

## 技术栈

- [Hugo](https://gohugo.io/)（extended 版，v0.164.0+）— 静态站点生成器
- [Blowfish](https://blowfish.page/) — Hugo 主题（以 git submodule 方式引入）
- [GitHub Actions](https://github.com/features/actions) — 推送到 `main` 分支时自动构建并部署到 GitHub Pages

## 目录结构

```
├── archetypes/          # 新文章模板
├── config/_default/     # 站点配置（hugo、params、语言、菜单、markup）
├── content/posts/       # 博客文章（Markdown）
├── layouts/             # 站点层模板覆盖（自定义主题部分）
├── themes/blowfish/     # 主题（git submodule）
└── .github/workflows/   # CI/CD 部署流程
```

## 本地开发

### 环境要求

- [Hugo extended](https://gohugo.io/installation/) v0.164.0 或更高版本

### 首次克隆

主题以 submodule 方式引入，克隆后需先初始化：

```bash
git clone https://github.com/ZUOXIANGE/zuoxiange.github.io.git
cd zuoxiange.github.io
git submodule update --init --recursive
```

### 启动开发服务器

```bash
hugo server
```

浏览器访问 <http://localhost:1313/>，修改文件会自动热更新。

## 写文章

使用 Hugo 命令创建新文章：

```bash
hugo new content/posts/文章标题.md
```

新文章默认是草稿（`draft = true`），发布前需要：

1. 将文章 Front Matter 中的 `draft = true` 改为 `draft = false`
2. 或本地预览时用 `hugo server -D` 显示草稿

Front Matter 示例：

```toml
+++
date = '2026-08-18'
draft = false
title = '文章标题'
description = '文章简介'
tags = ['标签1', '标签2']
categories = ['分类']
+++
```

## 部署

推送代码到 `main` 分支后，GitHub Actions 会自动：

1. 拉取主题 submodule
2. 使用 Hugo extended 构建静态文件到 `public/`
3. 部署到 GitHub Pages

无需手动操作，等待 Actions 构建完成即可。

## 主题配置

主题参数集中配置在 [config/_default/params.toml](config/_default/params.toml)，主要可调项：

- 首页布局（`[homepage] layout`）：`profile` / `hero` / `card` / `landing` 等
- 配色方案（`colorScheme`）：内置多种主题色
- 作者信息（`config/_default/languages.zh-cn.toml` 中的 `[params.author]`）

完整参数说明见 [Blowfish 官方文档](https://blowfish.page/docs/configuration/)。
