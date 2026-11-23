---
kind: external_dependency
name: GitHub Actions CI/CD 流水线
slug: github-actions
category: external_dependency
category_hints:
    - framework_behavior
scope:
    - '**'
---

### GitHub Actions
- 两条流水线：`build.yml`（PR 触发，运行 front matter 校验脚本 + `hugo --minify` 构建验证）、`deploy.yml`（push main 触发，构建并部署到 GitHub Pages）。
- 依赖 PowerShell 7+ 执行 `scripts/check-frontmatter.ps1` 校验文章 front matter 必填字段（slug、description、categories、tags）。