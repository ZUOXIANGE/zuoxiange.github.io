---
kind: dependency_management
name: Hugo + Blowfish 主题依赖管理（Git Submodule、Dependabot、Hugo 版本巡检）
category: dependency_management
scope:
    - '**'
source_files:
    - .gitmodules
    - .hugo-version
    - .github/dependabot.yml
    - .github/workflows/check-hugo-update.yml
    - themes/blowfish/package.json
    - themes/blowfish/go.mod
    - .githooks/pre-commit
    - scripts/setup-hooks.ps1
---

## 1. 使用的系统与工具

本仓库是 Hugo 站点，依赖来源分三层：
- **Hugo CLI**：通过根目录 `.hugo-version` 锁定版本 `0.168.0`，由 GitHub Actions 定时任务自动检测并提 PR。
- **Blowfish 主题**：作为 Git submodule 引入，地址为 `https://github.com/nunocoracao/blowfish.git`，路径 `themes/blowfish`。
- **Node.js 依赖**：仅存在于子模块 `themes/blowfish/package.json` 中，用于构建 Tailwind CSS 与复制第三方 JS/CSS 到 `assets/lib/`；站点本身没有自己的 `package.json`。

自动化更新工具：
- GitHub Dependabot（`.github/dependabot.yml`）负责 `github-actions` 和 `gitsubmodule` 两个 ecosystem。
- 自定义 workflow `.github/workflows/check-hugo-update.yml` 每周检查 Hugo 最新发布版并创建 PR。

## 2. 关键文件

- `.gitmodules` — 定义 blowfish 主题的 submodule 注册。
- `.hugo-version` — 声明 Hugo CLI 版本 `0.168.0`。
- `.github/dependabot.yml` — Dependabot 配置，启用 `github-actions` 与 `gitsubmodule` 两个生态的周更。
- `.github/workflows/check-hugo-update.yml` — 每周一 UTC 0:00 比较 `.hugo-version` 与 GitHub Releases API，若发现新版本则更新文件并通过 `peter-evans/create-pull-request@v8` 提交 PR。
- `themes/blowfish/package.json` — 主题自身的 npm 依赖声明，使用 `vendor-copy` 将 mermaid/chart.js/katex/fuse/typeit/packery/tw-elements/lite-youtube-embed/medium-zoom 等库复制到 `assets/lib/` 下供 Hugo 静态资源引用。
- `themes/blowfish/go.mod` — 主题 Go module 声明（`github.com/nunocoracao/blowfish/v3`，Go 1.16），无外部依赖。
- `.githooks/pre-commit` + `scripts/setup-hooks.ps1` — 本地 pre-commit hook，调用 `scripts/check-frontmatter.ps1` 校验文章 front matter，未通过则阻止提交。

## 3. 架构与约定

- **主题以 submodule 形式集成**：站点不直接拷贝 Blowfish 源码，而是通过 git submodule 引用上游仓库。更新主题需升级 submodule 指向。
- **Hugo 版本集中声明于 `.hugo-version`**：CI 读取该文件与 GitHub Releases API 对比，语义版本号比较使用 `sort -V`，仅当最新版严格大于当前版时才触发更新。
- **前端依赖 vendoring 在主题内完成**：`themes/blowfish/package.json` 的 `devVendorCopy` 字段定义了从 `node_modules` 到 `assets/lib/<lib>/` 的映射，构建产物被 Hugo 直接引用，站点层无需关心 Node 依赖。
- **Dependabot 仅覆盖两类依赖**：GitHub Actions 自身 action 版本与 blowfish 主题 submodule 指针；Hugo CLI 版本走独立 workflow，不走 Dependabot。
- **本地开发钩子**：通过 `git config core.hooksPath .githooks` 启用，pre-commit 阶段执行 PowerShell 脚本校验 front matter 必填字段。

## 4. 约定与约束

- Hugo CLI 版本必须与 `.hugo-version` 保持一致，由 `check-hugo-update.yml` 在 CI 中强制比对（`current != latest` 时即视为不一致）。[来源：`.github/workflows/check-hugo-update.yml` 第 35–45 行]
- Blowfish 主题只能通过 submodule 路径 `themes/blowfish` 引用，其 URL 固定为 `https://github.com/nunocoracao/blowfish.git`。[来源：`.gitmodules`]
- Dependabot 对 `github-actions` 和 `gitsubmodule` 两个生态均设置 `open-pull-requests-limit: 10`，并分别打上 `dependencies` + `github-actions` / `submodule` 标签。[来源：`.github/dependabot.yml`]
- Hugo 版本更新 PR 的分支名固定为 `ci/update-hugo`，commit message 格式为 `chore: bump Hugo to <version>`。[来源：`.github/workflows/check-hugo-update.yml` 第 56–57 行]
- 站点根目录不包含任何语言包管理器清单（无 `go.mod`、`package.json`、`requirements.txt` 等），所有第三方依赖声明集中在 `themes/blowfish/` 内部。[证据：根目录扫描结果]
- 本地 pre-commit 钩子通过 `pwsh -NoProfile -File scripts/check-frontmatter.ps1 || exit 1` 执行，失败即中止提交。[来源：`.githooks/pre-commit`]