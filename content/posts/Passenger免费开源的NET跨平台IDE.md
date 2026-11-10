+++
date = '2026-11-10T08:40:00+08:00'
draft = false
title = 'Passenger：一个免费开源的 .NET IDE，顺手把 Godot 4 也管了'
slug = 'passenger-free-dotnet-ide'
description = 'Passenger 是用 Avalonia 写的跨平台 .NET IDE，MIT 协议免费开源，自带调试器、Hot Reload、性能剖析和 XAML 实时可视化树，还通过 MCP 让编码 agent 直接操作 IDE。'
categories = ['开发工具']
tags = ['Passenger', '.NET', 'C#', 'IDE', 'Godot', 'MCP']
+++

写 .NET 的 IDE，选择其实不算多。Rider 好用，商业授权要钱；Visual Studio 功能最全，但基本困在 Windows 上；VS Code 配几个插件也能写，只是调试、热重载这些真正耗时间的环节，体验总差一口气。

今年 10 月 GitHub 上冒出来一个叫 [Passenger](https://github.com/Zaneris/passenger) 的项目，想干的正是把这些缝补上：一个 MIT 协议、三平台可用、装完就能开工的 .NET IDE。项目 10 月中旬才公开，11 月 6 日就发到了 0.3.0，节奏相当快。0.3.0 的主标题也很有意思——这一版的重心是 **Godot 4 游戏开发**。

## 它到底是什么

Passenger 自己是一个用 [Avalonia](https://avaloniaui.net/) 写的 C# 桌面应用。用 .NET 的 UI 框架去写 .NET 的 IDE，这一点本身就挺自洽。

按仓库里的说法，它想把原本分散在付费 IDE 和各类插件里的东西合到一处：

* 基于 Roslyn 的 C# 编辑器，诊断、补全、重构、调用层级、反编译源码
* 自研调试器，带 Hot Reload
* CPU 和内存剖析器
* Avalonia 与 WPF 的 XAML 工具链
* 一个给编码 agent 用的 MCP server

而且它不收费，不需要注册账号，没有 license key，官方说也没有遥测数据。支持 Windows x64/Arm64、macOS（Apple Silicon）和 Linux x64/Arm64。

顺手提醒一句：它和 Ruby 圈那个 Phusion Passenger 没有关系。Linux 下安装后的命令特意叫 `passenger-ide`，就是为了不和 Phusion 的 `passenger` 撞名。

## 为什么值得装一个试试

### macOS 上的 .NET 终于有个正经选择

微软在 2024 年 8 月停更了 Visual Studio for Mac。此后 Mac 上写 .NET，要么上 Rider，要么忍受 VS Code 的拼接方案。Passenger 原生跑在 Apple Silicon 上，而且是完整的调试器实现，不是"能编译就行"。

它还有个小细节处理得挺体贴：默认快捷键直接用 Visual Studio 那一套，想换成 VS Code 或 IntelliJ IDEA 的，改个设置就行。

### Godot 4 + C# 这块比想象中打磨得细

这是 0.3.0 花力气最多的地方，也是它区别于其他 .NET IDE 的地方。

Godot 自带编辑器对 C# 的支持一直比较勉强：没有 Roslyn 级别的补全和重构，C# 与场景之间的引用关系也才刚起步。Passenger 的思路是把两边打通：

* **C# 对照场景做静态校验**：`GetNode<T>` 的路径和类型、`res://` 和 `uid://` 路径、`[Export]` 的值、signal 和它的 handler，都能补全、能检查，重命名能一路改到场景里
* **GDScript 用自己移植的 Godot parser 和 analyzer**：报的是 Godot 自己的警告和错误，配 Godot 自己的修复建议，多数情况不用启动 Godot 就能拿到结果，还能按 Godot 的代码风格 Reformat
* **Shader 按 Godot 编译器的规则检查**，一次把所有错误和警告都列出来
* **运行中的场景树和值**：Live Visual Tree 跟着游戏实时刷新，加上游戏可以画在代码旁边的独立窗格里（Windows、macOS 和 Linux 的 X11 环境），在游戏里点一下就能选中对应节点，改个数值还能 Keep 回场景文件
* **一份 profile 看两门语言**：GDScript 的函数耗时和 Godot 的帧时间，跟 C# 放进同一棵调用树
* **测试**：GdUnit4、GUT、GoDotTest 都能在 Unit Tests 窗口里跑和调试

还有个挺实用的设计：装上它的 Godot addon 之后，在 Godot 编辑器里按 Play 启动的游戏会直接在 Passenger 里被调试；反过来也能把 Passenger 设成 Godot 的脚本编辑器，双击脚本跳过来。

需要注意的是，它目前测试的是 Godot 4.7 和 4.8 的 beta 版，更早的 4.x 版本没见到明确的支持承诺。另外 C# 项目需要 Godot 的 .NET 版本。

### 调试器是真写了，不是包了一层

这可能是最能说明投入程度的部分。Passenger 的调试器从 SharpDbg 和 ICorDebugSharp 起步，直接走 `ICorDebug`：

* 条件断点、命中次数、日志断点、异常断点
* async 代码单步（连 .NET 11 的 runtime async 也覆盖）
* Smart Step Into、方法返回值、Run to Cursor、Set Next Statement
* 多个程序同时调试，各自一个 tab
* 没有符号的库直接反编译出源码给你看
* Attach to Process 会把本机和所有运行中容器里的 .NET 进程都列出来，选一个就当自己启动的一样调

Hot Reload 在暂停和运行两种状态下都能用。改不进去的编辑会列在 Problems 里说明原因，默认策略是重启程序让改动生效。不挂调试器的话，它也支持走 `dotnet watch`。

数据断点只在 Windows x64 上可用——这是运行时的限制，不是它偷懒。

### 界面框架和数据库查询也照顾到了

**Avalonia / WPF**：`.axaml` 文件的补全、资源补全、绑定路径按 `x:DataType` 校验、XAML 编译器的错误直接标在对应行、Go to Declaration 跳到 C#、跨 C# 和 XAML 的双向重命名、Extract Resource / Extract Style。XAML Preview 边打字边出画面；调试时 Live Visual Tree 会显示每个属性的值是从哪来的、每条样式为什么生效、哪条绑定失败了——失败绑定会作为一条 Problem 出现，可以像异常一样让调试器停下来。XAML Hot Reload 也是现成的。

不过这部分的平台差异要注意：WPF 应用只有在 Windows 上才跑得起来，其他平台只能拿到代码层面的帮助。

**Web 应用和数据**：Requests 窗口读取 ASP.NET Core 和 EF Core 自身的事件，把你运行中的每个 HTTP 请求和它执行的 SQL 并排显示，N+1 和慢查询会被标出来。Migrations 窗口在跑 `dotnet ef` 之前，先把会挡住它的东西（工具没装、Design 包缺失、provider 不对）修好。Blazor 的 WebAssembly 组件可以在浏览器里打断点，服务端代码就在旁边。

**容器和 Aspire**：打开解决方案时会自动把 compose 文件、带 Dockerfile 的项目、`.dcproj` 和 Aspire AppHost 都变成运行配置，每个 .NET 服务都能断点、热重载、剖析。默认它会自己构建 .NET 服务再运行，所以改代码不需要重建镜像。Aspire 窗口能看到每个资源的状态、健康度、地址、日志、trace 和指标曲线，AppHost 还能画成图。

剩下那些 IDE 标配也都在：Git（三段合并解冲突、SSH/GPG/X.509 签名验签）、xUnit/NUnit/MSTest/TUnit 测试、NuGet 管理、Local History、内置终端、CSV/Excel 当表格看、12 套主题（每套都有明暗两版）。

## 最值得关注的一点：让 agent 真的能"跑起来"

今年写代码的方式变了不少，Claude Code、Codex、OpenCode 这类 agent 已经能改文件、跑命令。但它们有个共同的短板：改完之后对不对，只能靠编译报错和翻日志来猜。

Passenger 把自己实现成一个 MCP server，agent 接进来之后，能干的事情就不只是读写文件了：

* 查符号、读诊断、重命名、格式化
* 构建、运行、跑测试
* 下断点、单步、读改变量、触发热重载、剖析
* 启动/调试容器服务或 Aspire 资源，读它的日志、trace、指标
* 查看 Web 应用的路由和实时请求，跑 EF Core 迁移
* 提交代码、解冲突、装 NuGet 包

如果程序是 Avalonia 应用、Godot 游戏，或者 Windows 上的 WPF 应用，agent 还能像人一样去点它、看它——而且是离屏的，不抢你的鼠标和焦点。

接入方式有两种，都是 Passenger 可执行文件的一个参数：

| 参数 | 行为 | 适合场景 |
| --- | --- | --- |
| `--mcp-attach` | 接到你正开着的窗口，agent 的断点和运行都出现在你自己的界面里 | 你想盯着 agent 在做什么 |
| `--mcp FOLDER` | 起一个没有窗口的 Passenger，专给 agent 用 | 你走开，让 agent 自己干 |

`--mcp-attach` 第一次接入时窗口会问你要不要放行（允许 / 不允许 / 这个目录以后都允许），agent 第一次调用有副作用的工具时还会再问一次。两分钟不回答，agent 那边就会收到"没人应答"的结果。`--mcp FOLDER` 则完全不打扰你，因为它本来就没有界面。

配置文件示例（macOS 路径，其他平台换成对应的可执行文件路径）：

```json
{
  "mcpServers": {
    "passenger": {
      "command": "/Applications/Passenger.app/Contents/MacOS/Passenger",
      "args": ["--mcp-attach"]
    }
  }
}
```

命令行方式：

```bash
# Claude Code
claude mcp add passenger -- /Applications/Passenger.app/Contents/MacOS/Passenger --mcp-attach
# Codex CLI
codex mcp add passenger -- /Applications/Passenger.app/Contents/MacOS/Passenger --mcp-attach
```

Windows 下的可执行文件在 `%LOCALAPPDATA%\PassengerIDE\current\Passenger.exe`，Linux 下是 `~/.local/bin/passenger-ide`（`--system` 安装则是 `/usr/local/bin/passenger-ide`）。软件设置里的 MCP Server 一页也把各家 agent 的配置填好了，复制即可。

## 装起来要什么条件

安装包在官网 [passenger-ide.net](https://passenger-ide.net/) 下：

* **macOS**：Apple Silicon 的 dmg，拖进 Applications
* **Windows**：x64 或 Arm64 的安装包，装到当前用户，不需要管理员权限
* **Linux**：x64 或 Arm64 的压缩包，解开跑 `install.sh`（加 `--system` 装给所有人）

安装完的副本会自己更新。运行时依赖不多：

* **.NET SDK 8 或更新版本**，用来构建和运行你打开的项目。没有的话它会告诉你缺什么，你同意后可以一步装上
* **Git**，版本控制要用
* **Node.js**，只有 JS/TS/HTML/CSS/JSON/Dockerfile/YAML 需要；C#、XAML、GDScript 和 shader 不需要
* **Godot 4**（做 C# 要 .NET 版），从 `GODOT` 环境变量、PATH 或应用目录里找，也可以在设置里指定
* **Chromium 系浏览器**，只有 Blazor WebAssembly 调试需要
* **Linux 容器引擎**，Docker Desktop、Colima、OrbStack、Rancher Desktop、Podman 或远程引擎都行

## 现在还不能指望它什么

夸完得说点实话。这是个 0.x 项目，公开一个多月，0.3.0 里的功能清单长得有点不真实——这通常意味着迭代很快，也意味着有些角落还没被足够多的真实项目捶过。

具体的边界：

* **不支持 .NET Framework 和 Mono**，老项目还得回 Visual Studio
* **WPF 只在 Windows 上能运行**，其他平台只能拿到代码帮助
* **macOS 只提供 Apple Silicon 安装包**，Intel Mac 目前装不了
* 调试器要求被调试进程以你的身份运行、`TMPDIR` 正常、`DOTNET_EnableDiagnostics` 不能为 0
* 数据断点仅限 Windows x64

所以建议是：先拿它跑副项目或者新起的项目，别一上来就把公司那套几十个项目的老解决方案整个搬过去。

## 适合谁

* 主要在 macOS 上写 .NET，又不想为 Rider 付钱的人
* 用 C# 写 Godot 4 游戏的人——这块目前几乎没有对手
* 正在搭 agent 工作流，希望 AI 改完代码能自己跑一遍、断点看一眼、确认没问题再交的人

代码在 [github.com/Zaneris/passenger](https://github.com/Zaneris/passenger)，MIT 协议，第三方组件和素材的授权单独列在 `THIRD_PARTY_NOTICES.md`。想自己构建的话需要 .NET 11 SDK 和 [just](https://github.com/casey/just)，CI 之外的构建记得自己设 `AVALONIA_TELEMETRY_OPTOUT=1`，否则 Avalonia 的构建任务会把构建记录发回 AvaloniaUI。

有 bug 直接提 issue 就行，这种刚起步、迭代又勤的项目，反馈通常落得比较快。
