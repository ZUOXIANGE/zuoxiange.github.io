---
kind: external_dependency
name: Hugo 静态站点生成器（extended 版）
slug: hugo
category: external_dependency
category_hints:
    - framework_behavior
scope:
    - '**'
---

### Hugo
- 本仓库的静态站点生成器，使用 extended 版本以支持 Goldmark 扩展与 Mermaid 渲染；版本由 `.hugo-version` 锁定（v0.164.0），本地与 CI 保持一致。
- 站点配置集中在 `config/_default/hugo.toml`：启用 CJK、GitInfo、Emoji、RobotsTXT，输出 HTML/RSS/JSON 首页 + HTML/MD 单页（额外输出 Markdown 原文用于「下载本文」功能）。
- 主题通过 git submodule 引入 Blowfish，升级用 `git submodule update --remote --merge`，站点级定制放在 `layouts/`、`assets/css/custom.css`、`config/` 以避免被覆盖。
- 构建命令为 `hugo server`（开发）与 `hugo --minify`（CI）。