+++
date = '2026-08-19T17:45:10+08:00'
draft = false
title = 'Git Hooks 应用详解'
slug = 'git-hooks-application-guide'
aliases = ['/posts/githooks应用详解/']
description = '详解 Git Hooks 的工作原理与常用钩子类型，并针对 Java、.NET 和 JavaScript/TypeScript 项目给出 pre-commit 自动化与代码质量拦截的最佳实践方案。'
categories = ['开发工具']
tags = ['Git', 'Git Hooks', 'Husky', 'Husky.Net', 'Lefthook', 'Commitlint', '工程化']
+++

Git Hooks 是 Git 在特定事件发生之前或之后执行的脚本，是实现研发流程自动化、代码质量控制和规范落地的关键工具。通过 Git Hooks，我们可以在代码提交（Commit）、推送（Push）等环节自动执行代码检查、格式化、单元测试等任务，将问题拦截在开发本地。

本文档详细介绍 Git Hooks 的工作原理，并分别针对 Java、.NET 和 JavaScript/TypeScript 项目提供最佳实践方案。

## 1. Git Hooks 简介

Git Hooks 脚本默认存储在仓库的 `.git/hooks` 目录下。

### 1.1 常用钩子类型

*   **pre-commit**: 最常用的钩子。在 `git commit` 执行前运行。常用于：
    *   代码风格检查 (Lint)
    *   代码格式化 (Format)
    *   静态代码分析
    *   运行单元测试
    *   检查是否有敏感信息泄露
*   **commit-msg**: 在用户输入提交信息后运行。常用于：
    *   校验提交信息是否符合 [Git Commit 提交规范](./git%20commit提交规范.md) (如 Conventional Commits)
*   **pre-push**: 在 `git push` 执行前运行。常用于：
    *   运行集成测试
    *   防止推送到受保护的分支

### 1.2 团队共享痛点

默认的 `.git/hooks` 目录不会被提交到远程仓库，因此团队成员无法直接共享钩子脚本。为了解决这个问题，通常采用以下两种策略：
1.  **Git 2.9+ `core.hooksPath`**: 将钩子脚本放在仓库内（如 `.githooks/`），通过 `git config core.hooksPath .githooks` 指定目录。
2.  **工具封装**: 使用各语言生态下的工具（如 Husky, Lefthook）自动配置和管理钩子。

---

## 2. JavaScript / TypeScript 项目实践

在前端生态中，**Husky** 是当之无愧的标准工具，通常配合 **lint-staged** 和 **commitlint** 使用。

### 2.1 推荐工具栈
*   **Husky**: 轻松启用 Git Hooks。
*   **lint-staged**: 只对暂存区（Staged）的文件运行检查，提高速度。
*   **Commitlint**: 校验 Commit Message 格式。
*   **Prettier / ESLint**: 格式化与代码检查。

### 2.2 配置步骤

1.  **安装依赖**
    ```bash
    npm install --save-dev husky lint-staged @commitlint/{config-conventional,cli}
    ```

2.  **初始化 Husky**
    ```bash
    npx husky init
    ```
    这会在 `.husky/` 目录下创建钩子脚本，并修改 `package.json` 的 `prepare` 脚本。

3.  **配置 pre-commit (Lint & Format)**
    修改 `.husky/pre-commit` 文件：
    ```bash
    npx lint-staged
    ```
    在 `package.json` 中添加配置：
    ```json
    "lint-staged": {
      "*.{js,ts,vue,jsx,tsx}": [
        "eslint --fix",
        "prettier --write"
      ],
      "*.{json,css,md}": [
        "prettier --write"
      ]
    }
    ```

4.  **配置 commit-msg (规范校验)**
    创建 `.husky/commit-msg` 文件：
    ```bash
    echo "npx --no-install commitlint --edit \$1" > .husky/commit-msg
    ```
    创建 `commitlint.config.js`:
    ```javascript
    module.exports = { extends: ['@commitlint/config-conventional'] };
    ```

---

## 3. .NET 项目实践

在 .NET 生态中，推荐使用 **Husky.Net**。它受 npm husky 启发，但作为 .NET Tool 运行，无需 Node.js 环境，且与 `dotnet format` 完美集成。

### 3.1 推荐工具栈
*   **Husky.Net**: .NET 版本的 Husky。
*   **CSharpier / dotnet format**: 代码格式化。

### 3.2 配置步骤

1.  **安装 Husky.Net**
    在项目根目录运行：
    ```bash
    dotnet new tool-manifest
    dotnet tool install Husky
    dotnet husky install
    ```

2.  **添加 pre-commit 任务**
    Husky.Net 使用 `task-runner.json` 定义任务。
    ```bash
    dotnet husky add pre-commit -c "dotnet husky run"
    ```
    编辑 `.husky/task-runner.json`，配置只对暂存文件运行格式化（类似 lint-staged）：
    ```json
    {
      "tasks": [
        {
          "name": "dotnet-format",
          "command": "dotnet",
          "args": ["format", "--include", "${staged}"],
          "include": ["**/*.cs"]
        }
      ]
    }
    ```
    *注意：.NET 10 环境下，建议确保 `dotnet format` 配置了 `--verify-no-changes` 用于 CI 环境，本地开发则自动修复。*

3.  **配置 commit-msg**
    ```bash
    dotnet husky add commit-msg -c "dotnet husky run --name commit-lint"
    ```
    在 `task-runner.json` 中添加正则校验：
    ```json
    {
      "name": "commit-lint",
      "command": "dotnet",
      "args": ["husky", "exec", ".husky/csx/commit-lint.csx", "--args", "${args}"],
      // 或者使用简单的正则匹配脚本
    }
    ```

---

## 4. Java 项目实践

Java 生态过去常依赖 Maven/Gradle 插件，但配置较为繁琐且执行速度慢。现代 Java 项目（尤其是微服务或多语言混合仓库）推荐使用 **Lefthook** 或 **Spotless** + **Git Hooks**。

### 4.1 方案 A：Lefthook (推荐 - 跨平台/高性能)
Lefthook 是一个用 Go 编写的快速、跨语言的 Git Hooks 管理器。它不需要 Node.js，只有一个二进制文件，非常适合后端项目。

1.  **安装 Lefthook**
    *   **MacOS/Linux**: `brew install lefthook`
    *   **Windows**: `winget install lefthook` 或直接下载 exe 放入 PATH。
    *   **Java 项目集成**: 可以通过 Maven/Gradle wrapper 触发安装，或者直接在文档中要求开发者安装。

2.  **配置文件 `lefthook.yml`**
    在项目根目录创建：
    ```yaml
    pre-commit:
      parallel: true
      commands:
        spotless:
          glob: "*.java"
          run: ./mvnw spotless:check
        checkstyle:
          glob: "*.java"
          run: ./mvnw checkstyle:check

    commit-msg:
      commands:
        commitlint:
          #此脚本依赖 Bash 环境（如 macOS/Linux 或 Windows 下的 Git Bash），Windows 用户需确保安装了 Git Bash 并在 Lefthook 中配置 runner: sh
          run: |
            # 简单的 shell 脚本校验，或者调用 java 程序校验
            if ! grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+" {1}; then
              echo "❌ Commit message format error."
              exit 1
            fi
    ```

3.  **启用钩子**
    ```bash
    lefthook install
    ```

### 4.2 方案 B：Maven 插件 (传统方式)
使用 `git-commit-id-maven-plugin` 的扩展或 `com.diffplug.spotless` 配合 `maven-antrun-plugin` 自动安装钩子脚本。

但更轻量的方式是直接编写一个 shell 脚本放在 `scripts/pre-commit`，然后在构建时复制到 `.git/hooks`。

**Spotless 配置示例 (pom.xml)**:
```xml
<plugin>
    <groupId>com.diffplug.spotless</groupId>
    <artifactId>spotless-maven-plugin</artifactId>
    <version>2.43.0</version>
    <configuration>
        <java>
            <googleJavaFormat>
                <style>GOOGLE</style>
            </googleJavaFormat>
        </java>
    </configuration>
</plugin>
```
配合 pre-commit 钩子执行 `mvn spotless:apply`。

---

## 5. 总结与建议

| 特性            | JavaScript/Node | .NET (C#)        | Java                                         |
| :-------------- | :-------------- | :--------------- | :------------------------------------------- |
| **推荐工具**    | **Husky**       | **Husky.Net**    | **Lefthook**                                 |
| **代码格式化**  | Prettier        | dotnet format    | Spotless / Google Java Format                |
| **Lint 检查**   | ESLint          | Roslyn Analyzers | Checkstyle / PMD                             |
| **Commit 校验** | Commitlint      | Husky.Net Task   | Lefthook regex / Conventional Commits Plugin |

### 最佳实践 Tips

1.  **不要过度拦截**: pre-commit 应该只运行快速的检查（格式化、Lint）。耗时的单元测试或集成测试建议放在 CI/CD 流水线中，或者放在 pre-push 钩子中。
2.  **提供跳过机制**: 紧急情况下（如修复线上严重 Bug），允许开发者通过 `git commit --no-verify` (或 `-n`) 跳过钩子。
3.  **保持幂等性**: 钩子脚本应该是幂等的，多次运行结果一致。
4.  **统一规范**: 结合 [Git Commit 提交规范](./git%20commit提交规范.md) 文档，确保工具检查规则与文档描述一致。
