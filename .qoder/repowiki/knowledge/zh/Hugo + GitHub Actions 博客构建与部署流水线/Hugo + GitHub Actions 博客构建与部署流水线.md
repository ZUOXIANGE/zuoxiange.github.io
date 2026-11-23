---
kind: build_system
name: Hugo + GitHub Actions 博客构建与部署流水线
category: build_system
scope:
    - '**'
source_files:
    - .github/workflows/build.yml
    - .github/workflows/deploy.yml
    - .github/workflows/check-hugo-update.yml
    - .hugo-version
    - .gitmodules
    - scripts/setup-hooks.ps1
    - scripts/check-frontmatter.ps1
    - .github/dependabot.yml
---

## 1. 构建系统概览

本项目是一个基于 Hugo extended 与 Blowfish 主题的个人技术博客，构建与发布完全由 GitHub Actions 驱动，本地无需 Makefile 或 Docker。核心流程：
- 使用 `hugo --minify --gc --cleanDestinationDir` 将 Markdown 内容编译为静态站点输出到 `public/`。
- 通过 `actions/upload-pages-artifact@v5` + `actions/deploy-pages@v5` 发布到 GitHub Pages。
- 主题作为 Git submodule（`themes/blowfish`）引入，CI 中通过 `submodules: recursive` 拉取。
- Hugo 版本锁定在 `.hugo-version`（当前 `0.168.0`），由 `peaceiris/actions-hugo@v3` 的 `extended: true` 自动读取。

## 2. 关键文件

- `.github/workflows/build.yml` — PR 触发构建检查，运行 front matter 校验与 `hugo build`。
- `.github/workflows/deploy.yml` — push 到 `main` 或手动触发时构建并部署到 GitHub Pages。
- `.github/workflows/check-hugo-update.yml` — 每周一 UTC 0 点检查 Hugo 新版本，若发现更新则自动创建 PR 修改 `.hugo-version`。
- `.hugo-version` — 固定 Hugo 版本号，是 CI 与本地环境的唯一版本来源。
- `.gitmodules` — 声明 `themes/blowfish` 子模块，指向 `https://github.com/nunocoracao/blowfish.git`。
- `scripts/setup-hooks.ps1` — 启用仓库内 `.githooks/` 目录下的 git hooks（Windows PowerShell）。
- `scripts/check-frontmatter.ps1` — 在构建前校验文章 front matter 必填字段。
- `.github/dependabot.yml` — 依赖自动更新（针对 npm 等包管理器）。

## 3. 架构与约定

### 3.1 工作流职责分离

| 工作流 | 触发条件 | 职责 |
|---|---|---|
| `build.yml` | `pull_request` → `main` | 预检：checkout + 子模块 + setup hugo + cache + front matter 校验 + `hugo build` |
| `deploy.yml` | `push` → `main` / `workflow_dispatch` | 完整构建 + 上传 artifact + 部署到 GitHub Pages |
| `check-hugo-update.yml` | `schedule: '0 0 * * 1'` / `workflow_dispatch` | 对比 `.hugo-version` 与 GitHub Releases API，若新版更高则 `create-pull-request` |

### 3.2 缓存策略

两个构建工作流均使用 `actions/cache@v6` 缓存 `resources` 目录，key 为 `${{ runner.os }}-hugo-${{ hashFiles('config/**') }}`，restore-keys 为 `${{ runner.os }}-hugo-`，以加速重复构建。

### 3.3 版本管理

- Hugo 版本：集中维护于 `.hugo-version`，CI 通过 `cat .hugo-version` 读取，`peaceiris/actions-hugo@v3` 的 `extended: true` 自动匹配该版本。
- 主题版本：通过 Git submodule 锁定到特定 commit，不在代码中硬编码版本号。
- 依赖更新：`check-hugo-update.yml` 调用 `api.github.com/repos/gohugoio/hugo/releases/latest` 获取最新版本号，用 `sort -V` 做语义化版本比较，仅当最新版严格大于当前版时才更新。

### 3.4 构建产物

- 构建命令：`hugo --minify --gc --cleanDestinationDir`
- 输出目录：`public/`（已包含 CSS/JS 哈希化资源、分类/标签归档、sitemap、RSS 等）
- 部署目标：GitHub Pages（`environment: github-pages`，使用 `id-token: write` 进行 OIDC 认证）

### 3.5 本地开发辅助

- `scripts/setup-hooks.ps1`：执行一次后设置 `core.hooksPath = .githooks`，启用仓库内置的 pre-commit hook。
- `.githooks/pre-commit`：提交前钩子（具体逻辑见文件）。

## 4. 约定与约束

- **Hugo 版本必须与 `.hugo-version` 一致**：CI 通过 `peaceiris/actions-hugo@v3` 的 `extended: true` 从该文件读取版本，本地也需安装对应版本以保证构建结果一致。
- **主题必须作为 Git submodule 存在**：所有工作流的 checkout step 都带 `submodules: recursive`，缺失子模块会导致构建失败。
- **front matter 必填字段校验是构建前置步骤**：`build.yml` 和 `deploy.yml` 均在 hugo build 之前执行 `./scripts/check-frontmatter.ps1`，未通过校验会中断流水线。
- **构建产物必须位于 `public/`**：`deploy.yml` 的 upload artifact 步骤指定 `path: ./public`，这是 GitHub Pages 的标准输入路径。
- **Hugo 版本升级走自动化 PR**：`check-hugo-update.yml` 每周自动检测并通过 `peter-evans/create-pull-request@v8` 创建名为 `ci/update-hugo` 的分支 PR，标题格式为 `chore: bump Hugo to <version>`，变更内容仅为 `.hugo-version` 文件。
- **Pages 部署使用 OIDC token**：`deploy.yml` 请求 `id-token: write` 权限，通过 `actions/deploy-pages@v5` 完成无密钥部署。
- **并发控制**：`deploy.yml` 设置 `concurrency.group: pages` 且 `cancel-in-progress: false`，避免并行部署覆盖；`check-hugo-update.yml` 设置 `concurrency.group: hugo-update` 防止重复的更新检查任务同时运行。