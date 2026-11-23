---
kind: external_dependency
name: GitHub Pages 托管与部署
slug: github-pages
category: external_dependency
category_hints:
    - vendor_identity
scope:
    - '**'
---

### GitHub Pages
- 站点最终部署目标为 `https://zuoxiange.github.io/`，推送 `main` 分支后由 `.github/workflows/deploy.yml` 自动构建并部署到 GitHub Pages。
- PR 触发 `.github/workflows/build.yml` 执行 front matter 校验 + `hugo --minify` 构建检查。