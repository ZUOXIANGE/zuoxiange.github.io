+++
date = '2026-08-18T17:28:12+08:00'
draft = false
title = 'Java开发者快速上手.NET10指南'
description = '专为 Java Spring Boot 开发者编写的 .NET 10 (ASP.NET Core) 快速上手指南，跳过基础语法，直接切入架构映射、核心差异与 .NET 的独特优势。'
categories = ['后端开发']
tags = ['.NET', 'ASP.NET Core', 'Java', 'C#', '后端开发']
+++

# Java Spring Boot 开发者快速上手 ASP.NET Core 10 指南

> 本文专为拥有丰富 Java Spring Boot 开发经验，希望快速掌握并评估 .NET 10 (ASP.NET Core) 的开发者编写。我们将跳过基础编程概念，直接切入核心差异、架构映射以及 .NET 10 的独特优势。

## 1. 为什么要关注 .NET 10？

在 2025 年的今天，.NET 10 已经不仅仅是 Windows 平台的专属。它是一个高性能、跨平台、云原生的统一开发平台。对于 Java 开发者来说，转向或尝试 .NET 10 主要有以下几个驱动力：

*   **极致性能 (Performance)**：在 TechEmpower 等主流基准测试中，ASP.NET Core 持续霸榜。.NET 10 进一步优化了 JIT 编译器和 Native AOT（原生预编译），使得启动速度和内存占用达到了惊人的低水平。
*   **开发体验 (Developer Experience)**：C# 语言特性的演进速度极快（如 LINQ、模式匹配、原本的 async/await），配合 Visual Studio / Rider 等强大的 IDE，编码效率极高。
*   **统一生态 (Unified Ecosystem)**：从 Web、移动端到云原生 (Aspire) 和 AI (Semantic Kernel)，.NET 提供了一站式的解决方案，减少了“胶水代码”。
*   **云原生优先**：.NET Aspire 的成熟使得构建、编排和部署分布式应用变得异常简单。

#### 关键开源项目
*   **Core**: [dotnet/aspnetcore](https://github.com/dotnet/aspnetcore) (Web 框架), [dotnet/runtime](https://github.com/dotnet/runtime) (CLR & Libraries)
*   **ORM**: [dotnet/efcore](https://github.com/dotnet/efcore) (EF Core), [DapperLib/Dapper](https://github.com/DapperLib/Dapper) (Micro-ORM)

---

## 2. 宏观概念映射 (The Mental Model)

为了让你快速建立心理模型，我们需要先对齐双方的生态系统和核心理念。

### 生态系统对照表 (Ecosystem Mapping)

| 概念          | Java / Spring Boot                    | .NET 10 / ASP.NET Core                  | 备注                                                                            |
| :------------ | :------------------------------------ | :-------------------------------------- | :------------------------------------------------------------------------------ |
| **运行时**    | JVM (HotSpot)                         | CLR (CoreCLR)                           | .NET 支持 Native AOT，可编译为无运行时的原生二进制                              |
| **包管理**    | Maven / Gradle                        | NuGet                                   | `.csproj` 文件管理依赖，指令更简洁                                              |
| **入口点**    | `public static void main`             | Top-level Statements (`Program.cs`)     | .NET 10 模板通常只有几行代码                                                    |
| **依赖注入**  | `@Autowired` / `@Bean` / Spring IoC   | Built-in DI (`IServiceCollection`)      | 构造函数注入是首选，原生支持 Scoped/Transient/Singleton                         |
| **Web 框架**  | Spring MVC                            | ASP.NET Core Controllers / Minimal APIs | Minimal API 类似于 Javalin 或 Spring Functional Web                             |
| **配置**      | `application.yml` / `@Value`          | `appsettings.json` / `IOptions<T>`      | .NET 的配置系统分层更清晰，热重载更强                                           |
| **ORM**       | Hibernate / JPA                       | Entity Framework Core (EF Core)         | EF Core 的 LINQ 查询比 JPQL/Criteria API 强大且类型安全                         |
| **DB Driver** | JDBC                                  | ADO.NET                                 | 两者均为底层标准，但 .NET 中 Dapper (Micro-ORM) 极其流行，常作为手写 SQL 的首选 |
| **异步编程**  | `CompletableFuture` / Virtual Threads | `async` / `await` / `Task`              | C# 的 async/await 是状态机实现，早于 Java 且生态极度完善                        |

---

## 3. 开发环境与构建系统 (Environment & Build)

工欲善其事，必先利其器。理解工具链是上手的关键。

### 3.1 开发工具 (IDEs)

Java 开发者习惯了 IntelliJ IDEA，在 .NET 世界也有完美对应的选择。

| Java 习惯         | .NET 推荐                | 描述                                                                                                            |
| :---------------- | :----------------------- | :-------------------------------------------------------------------------------------------------------------- |
| **IntelliJ IDEA** | **JetBrains Rider**      | **首选推荐**。同样的快捷键，同样的 UI，同样的智能提示。除了语言变了，其他体验几乎一致。支持 Windows/Mac/Linux。 |
| **Eclipse**       | **Visual Studio**        | 微软官方旗舰 IDE，功能最全，调试最强，但仅限 Windows。如果你喜欢“大而全”的感觉，这是不二之选。                  |
| **VS Code**       | **VS Code + C# Dev Kit** | 微软官方推出的 C# 开发套件。轻量级，适合快速查看代码或写 Minimal API，但在大型项目重构和导航上不如 Rider/VS。   |

### 3.2 构建系统与文件结构 (Build System & Files)

与 Java 的 `pom.xml` 或 `build.gradle` 不同，.NET 使用 `.csproj` 和 `.sln`（未来是 `.slnx`）。

| 概念         | Java (Maven/Gradle)          | .NET (MSBuild/NuGet)        | 说明                                                                                              |
| :----------- | :--------------------------- | :-------------------------- | :------------------------------------------------------------------------------------------------ |
| **逻辑组织** | 父工程 (Parent POM) / 多模块 | 解决方案 (`.sln` / `.slnx`) | `.sln` 是经典格式（GUID 地狱）；**.NET 10 推荐使用 `.slnx`**，这是全新的、可读性极高的 XML 格式。 |
| **项目描述** | `pom.xml` / `build.gradle`   | `.csproj` (XML)             | `.csproj` 极其简洁，默认包含所有文件，不需要手动列出源码路径。                                    |
| **依赖管理** | `pom.xml` (版本号)           | `Directory.Packages.props`  | .NET 10 推荐使用 **CPM** (Central Package Management) 统一管理版本。                              |
| **构建产物** | `.jar` / `.war`              | `.dll` / `.exe`             | .NET Core 编译生成 `.dll` (跨平台程序集) 和 `.exe` (特定平台启动器)。                             |
| **CLI 工具** | `mvn` / `./gradlew`          | `dotnet`                    | `dotnet build`, `dotnet run`, `dotnet test`，命令极其统一。                                       |

**Maven (`pom.xml`):**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <version>3.2.0</version>
</dependency>
```

**.NET (`.csproj` - 经典模式):**
```xml
<ItemGroup>
    <PackageReference Include="Serilog" Version="3.1.1" />
</ItemGroup>
```

**.NET (CPM 模式 - 推荐):**
在 `Directory.Packages.props` 中统一管理版本：
```xml
<ItemGroup>
    <PackageVersion Include="Serilog" Version="3.1.1" />
</ItemGroup>
```
在 `.csproj` 中仅引用，不带版本号：
```xml
<ItemGroup>
    <PackageReference Include="Serilog" />
</ItemGroup>
```

---

## 4. C# 语言速查 (For Java Developers)

C# 经常被认为是 "Java ++"，拥有更多现代语法糖。

### 4.1 语法差异速查表

| 特性           | Java                       | C#                   | 关键差异                                                                          |
| :------------- | :------------------------- | :------------------- | :-------------------------------------------------------------------------------- |
| **继承**       | `extends` / `implements`   | `:`                  | C# 类和接口继承都用冒号，更简洁。                                                 |
| **注解/特性**  | `@RestController`          | `[ApiController]`    | C# 使用中括号 `[]`。                                                              |
| **泛型**       | `List<Integer>` (类型擦除) | `List<int>` (真泛型) | C# 泛型在运行时保留类型，支持基本类型无装箱，性能更高。                           |
| **Lambda**     | `s -> s.length()`          | `s => s.Length`      | C# 使用胖箭头 `=>`。                                                              |
| **字符串插值** | `String.format` / `+`      | `$"{val}"`           | C# 的 `$` 字符串插值极其直观，支持格式化，如 `$"{date:yyyy}"`。                   |
| **数组/集合**  | `List.of(1, 2)`            | `[1, 2]`             | C# 12+ 集合表达式 (`Collection Expressions`) 统一了数组和集合的初始化。           |
| **Switch**     | `switch`                   | `switch` 表达式      | C# 的模式匹配 (`Pattern Matching`) 极其强大。                                     |
| **空判断**     | `Optional<T>`              | `T?`                 | C# 引用类型可为空是编译期检查，`?.` 和 `??` 操作符极其常用。                      |
| **异常处理**   | Checked Exceptions         | Unchecked Only       | C# 没有受检异常，不需要在方法签名声明 `throws`，代码更清爽。                      |
| **默认参数**   | 不支持 (需重载)            | `void F(int a=1)`    | C# 支持命名参数和默认参数，大幅减少方法重载数量。                                 |
| **值类型**     | 无 (Valhalla 待定)         | `struct`             | C# 有真正的栈上分配的值类型 (`struct`)，高性能场景必备。                          |
| **可见性**     | `package-private` (默认)   | `internal` (默认)    | Java 默认限制在包内，C# 默认限制在程序集 (Project) 内。                           |
| **命名规范**   | `camelCase` (方法)         | `PascalCase` (方法)  | C# 方法、属性、类均使用大驼峰，仅参数/局部变量用小驼峰。                          |
| **相等性**     | `.equals()`                | `==` (可重载)        | C# 的 `string` 使用 `==` 比较值，Java 必须用 `equals`。                           |
| **引用传递**   | 无 (仅值传递)              | `ref` / `out`        | C# 支持修改外部变量的引用，`out` 常用于 `TryParse` 模式。                         |
| **静态导入**   | `import static`            | `using static`       | 语法略有不同，作用一致。                                                          |
| **资源管理**   | `try (var x = ...)`        | `using var x = ...`  | C# 的 `using` 声明不需要大括号嵌套，作用域在当前块结束，代码更扁平。              |
| **对象初始化** | Builder 模式 / Setters     | `new T { P = v }`    | C# 对象初始化器 (`Object Initializers`) 极其方便，大幅减少了 Builder 模式的需求。 |
| **多行字符串** | `"""..."""` (Java 15+)     | `"""..."""` / `@""`  | C# 11+ 也支持 `"""`，且早就有 `@` 原样字符串 (Verbatim String) 处理路径转义。     |
| **类型字面量** | `MyClass.class`            | `typeof(MyClass)`    | C# 使用 `typeof` 运算符获取类型元数据 (`Type`)。                                  |

### 4.2 关键特性深度

#### 1. 属性 (Properties) vs Getter/Setter
告别冗长的样板代码：
```csharp
public string Name { get; set; } // 自动实现
```

#### 2. 记录 (Records) vs Lombok
C# 原生支持不可变数据结构，无需 Lombok 插件：
```csharp
public record UserDto(string Name, int Age); // 自带构造函数、Equals、ToString、解构
```

#### 3. 扩展方法 (Extension Methods)
C# 允许“向现有类型添加方法”，LINQ 的基础：
```csharp
// 定义
public static bool IsValidEmail(this string str) => str.Contains("@");
// 使用
if (email.IsValidEmail()) { ... }
```

#### 4. LINQ vs Java Streams
LINQ 是编译器级别的支持，比 Streams 更简洁、统一。

**Java Streams**:
```java
users.stream().filter(u -> u.getAge() > 18).map(User::getName).collect(Collectors.toList());
```

**C# LINQ**:
```csharp
users.Where(u => u.Age > 18).Select(u => u.Name).ToList();
```

#### 5. Async/Await vs CompletableFuture
C# 的异步是基于状态机的编译器重写，代码读起来像同步代码。相比之下，Java 8+ 通常使用 `CompletableFuture` 链式调用。

**C# (Async/Await):**
```csharp
public async Task<User> GetUserAsync(int id)
{
    // 像写同步代码一样写异步，编译器自动处理状态机
    var user = await _context.Users.FindAsync(id); 
    return user;
}
```

**Java (CompletableFuture):**
```java
public CompletableFuture<User> getUserAsync(int id) {
    // 需使用回调链
    return userRepository.findByIdAsync(id)
        .thenApply(user -> {
            // 额外的处理逻辑...
            return user;
        });
}
```

#### 6. 模式匹配 (Pattern Matching)
C# 的 `switch` 表达式比 Java 17+ 更强大，支持解构、类型匹配和逻辑判断。

```csharp
// 这里的 user 是 Object 类型
string message = user switch
{
    null => "User is missing",
    User u when u.Age < 18 => $"Minor: {u.Name}",
    User { Role: "Admin", IsActive: true } => "Active Admin",
    User { Address.City: "New York" } => "New Yorker", // 嵌套属性
    _ => "Unknown user"
};
```

#### 7. 常用集合对比 (Collections)
C# 的泛型集合位于 `System.Collections.Generic` 命名空间。

| Java (Interface -> Impl)       | C# (Interface -> Impl)                    | 关键差异                                                    |
| :----------------------------- | :---------------------------------------- | :---------------------------------------------------------- |
| `List<T>` -> `ArrayList<T>`    | `IList<T>` -> `List<T>`                   | C# 的 `List<T>` 就是动态数组，没有 `ArrayList` 这个泛型类。 |
| `Map<K, V>` -> `HashMap<K, V>` | `IDictionary<K, V>` -> `Dictionary<K, V>` | C# 的字典性能极高，且 key 不允许为 null。                   |
| `Set<T>` -> `HashSet<T>`       | `ISet<T>` -> `HashSet<T>`                 | 基本一致。                                                  |
| `Deque<T>` -> `ArrayDeque<T>`  | - -> `Queue<T>` / `Stack<T>`              | C# 区分队列和栈，通常直接使用具体类。                       |

#### 8. 函数式类型 (Functional Types)
Java 使用 `@FunctionalInterface` (如 `Function`, `Consumer`, `Runnable`)。
C# 使用内置委托 `Func` (有返回值), `Action` (无返回值)。

**Java**:
```java
Function<String, Integer> parser = Integer::parseInt;
```

**C#**:
```csharp
Func<string, int> parser = int.Parse; // 方法组
```

#### 9. 元组 (Tuples)
Java 通常使用 `Pair`, `Triple` 第三方库或 `Record`。C# 拥有语言级内置元组。

**Java**:
```java
// 需要定义 Record 或使用第三方库
record Result(int code, String msg) {}
Result res = new Result(200, "OK");
```

**C#**:
```csharp
// 极其轻量，支持解构
(int Code, string Msg) result = (200, "OK");
Console.WriteLine(result.Msg);

// 方法返回多个值
(bool Success, string Error) Process() => (false, "Failed");
var (success, error) = Process(); // 解构
```

---

## 5. ASP.NET Core 核心架构 (Core Architecture)

本章节涵盖构建应用骨架的核心机制：启动流程、依赖注入、配置与日志。

### 5.1 项目入口 (Startup)

**Spring Boot (`Application.java`)**:
```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

**.NET 10 (`Program.cs`)**:
.NET 使用顶级语句，极其简洁。这里包含了依赖注入配置、中间件管道和路由。
```csharp
var builder = WebApplication.CreateBuilder(args);

// 1. 注册服务 (DI) - 类似 Spring @Bean / @Service
builder.Services.AddControllers();
builder.Services.AddDbContext<AppDbContext>();

var app = builder.Build();

// 2. 配置中间件管道 (Middleware) - 执行顺序极其重要
if (app.Environment.IsDevelopment()) {
    app.MapOpenApi(); // 生成文档
}
app.UseHttpsRedirection();
app.UseAuthorization();

// 3. 定义路由
app.MapControllers();
app.MapGet("/health", () => "OK"); // Minimal API

app.Run();
```

### 5.2 依赖注入哲学 (Dependency Injection)

Spring 开发者可能习惯于 Field Injection (`@Autowired`)，但在 .NET 中，**构造函数注入**是绝对的官方标准。

**Java (Field Injection - 常见但非推荐):**
```java
@Service
public class UserService {
    @Autowired // 简单，但不利于单元测试
    private UserRepository repo;
}
```

**Java (Lombok Constructor Injection - 推荐):**
```java
@Service
@RequiredArgsConstructor // Lombok 自动生成构造函数
public class UserService {
    private final UserRepository repo; // 必须声明为 final
}
```

**C# (Constructor Injection - 官方标准):**
```csharp
public class UserService
{
    private readonly IUserRepository _repo;

    // 显式构造函数注入，依赖关系一目了然
    public UserService(IUserRepository repo)
    {
        _repo = repo;
    }
}
```

#### 依赖注入最佳实践 (AutoCtor)
推荐使用 **AutoCtor** 库自动生成构造函数注入代码，避免手写冗长的构造函数。
```csharp
[AutoConstruct] // 自动生成包含 _repo, _logger 的构造函数
public partial class UserService : IUserService
{
    private readonly IUserRepository _repo;
    private readonly ILogger<UserService> _logger;
    // ...
}
```

#### 生命周期管理 (Lifecycles)
.NET 严格区分三种生命周期，这与 Spring 默认全单例不同：

| 生命周期      | 描述                           | Java 对应概念 | 适用场景                           |
| :------------ | :----------------------------- | :------------ | :--------------------------------- |
| **Transient** | 每次注入都创建新实例           | Prototype     | 轻量级无状态服务                   |
| **Scoped**    | **每个 HTTP 请求创建一个实例** | Request Scope | DbContext, 业务 Service (默认推荐) |
| **Singleton** | 全局单例                       | Singleton     | 缓存, 配置                         |

#### 自动扫描注册 (ServiceScan)
为了找回 `@Service` 自动扫描的感觉，且保持对 **Native AOT** 的支持，推荐使用 Source Generator：

```csharp
// 使用 ServiceScan.SourceGenerator 库

// 方式 1: 按名称约定 (Convention) - 推荐
[GenerateServiceRegistrations(TypeNameFilter = "*Service", Lifetime = ServiceLifetime.Scoped)]
public static partial IServiceCollection AddBusinessServices(this IServiceCollection services);

// 方式 2: 按特性 (Attribute) - 最接近 Java @Service
// 需自定义 [AppService] 特性，并标记在服务类上
[GenerateServiceRegistrations(AttributeFilter = typeof(AppServiceAttribute), Lifetime = ServiceLifetime.Scoped)]
public static partial IServiceCollection AddAttributeServices(this IServiceCollection services);
```

### 5.3 配置管理 (Options Pattern)

.NET 使用强类型配置，支持热重载。
```csharp
// 定义
public class AppSettings { public int MaxItems { get; set; } }

// 注册
builder.Services.Configure<AppSettings>(builder.Configuration.GetSection("AppSettings"));

// 注入
public class MyService(IOptions<AppSettings> options) {
    private readonly AppSettings _settings = options.Value;
}
```

### 5.4 日志生态 (Logging)

在 .NET Core 之前，.NET 日志混乱。但现在 **Microsoft.Extensions.Logging** 统一了江湖，地位等同于 Java 的 **SLF4J**。

| 概念                | Java (Spring Boot)   | .NET 10 (ASP.NET Core)                     | 说明                                                                       |
| :------------------ | :------------------- | :----------------------------------------- | :------------------------------------------------------------------------- |
| **抽象层 (Facade)** | **SLF4J**            | **Microsoft.Extensions.Logging (ILogger)** | 开发者只依赖此抽象接口编程，不依赖具体库。                                 |
| **增强实现**        | **Log4j2 / Logback** | **Serilog** / NLog                         | 生产环境通常替换为功能更强大的库（如 Serilog）以支持文件滚动、结构化存储。 |

#### 结构化日志 (Structured Logging)
.NET 的 `ILogger` (尤其是配合 Serilog) 默认支持**消息模板 (Message Templates)**。

Java 的 `log.info("User {}", id)` 通常只是**格式化字符串**。最终日志文件里存的是 `"User 123"` 这一行文本。

.NET 的 `ILogger` (尤其是配合 Serilog) 默认支持**消息模板 (Message Templates)**。
`_logger.LogInformation("User {UserId}", id)` 不仅仅是替换字符串，它会把 `{UserId}` 作为一个**字段**保留下来。

当发送到日志中心（如 Elasticsearch, Seq, Datadog）时：
*   **Java (默认)**: `message: "User 123"` (难以按 ID 检索)
*   **.NET (Serilog)**: `message_template: "User {UserId}"`, `UserId: 123` (可以直接筛选 `UserId == 123`)

**Java (SLF4J):**
```java
// 通常只得到文本，除非配置了 JSON Appender 且手动构建 Map
log.info("Processing user " + id); 
log.info("Processing user {}", id); 
```

**C# (ILogger + Serilog):**
```csharp
// {UserId} 是属性名，id 是值。
// 日志系统不仅记录文本 "Processing user 1001"，还索引了字段 UserId=1001
_logger.LogInformation("Processing user {UserId}", id); 

// 复杂对象结构化 (使用 @ 操作符解构对象)
var user = new User { Id = 1, Name = "Admin" };
_logger.LogInformation("Created user {@User}", user); 
// 结果: Created user {"Id":1, "Name":"Admin"} (作为 JSON 对象存储)
```

---

## 6. 现代 Web 开发实战 (Modern Web Development)

### 6.1 定义 API 与文档 (Controller & OpenAPI)

**.NET 10** 推荐使用 XML 注释直接生成 OpenAPI 文档，配合强类型返回值，彻底告别注解堆砌。

**Java (SpringDoc)**:
```java
@Operation(summary = "获取用户", description = "根据ID查询详细信息")
@GetMapping("/{id}")
public UserDto getUser(@Parameter(description = "用户ID") @PathVariable int id) {
    return userService.findById(id);
}

@Operation(summary = "创建用户")
@PostMapping("/create")
public int createUser(@RequestBody @Parameter(description = "用户信息") CreateUserDto dto) {
    return userService.create(dto);
}
// CreateUserDto 需要使用 @Schema 注解来描述字段
 public class CreateUserDto {
     /**
      * 用户姓名
      */
     @Schema(description = "用户姓名")
     private String name;

     /**
      * 用户年龄
      */
     @Schema(description = "用户年龄")
     private int age;
 }
```

**.NET 10 (XML Comments - 推荐):**
```csharp
/// <summary>
/// 获取用户
/// </summary>
/// <remarks>根据ID查询详细信息</remarks>
[HttpGet("{id}")]
public async Task<UserDto> GetUser(int id)
{
    // Happy Path Only: 找不到直接抛异常，由全局异常处理器捕获返回 404
    return await _service.FindByIdAsync(id);
}

/// <summary>
/// 创建用户
/// </summary>
/// <param name="dto">用户信息</param>
[HttpPost("/create")]
public async Task<int> CreateUser([FromBody] CreateUserDto dto)
{
    return await _service.CreateAsync(dto);
}
//CreateUserDto 就是一个普通的类, 没有任何特殊的注解或配置
public class CreateUserDto
{
    /// <summary>
    /// 用户姓名
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// 用户年龄
    /// </summary>
    public int Age { get; set; }
}
```

### 6.2 请求参数与模型绑定 (Model Binding)

Spring MVC 通常需要显式注解 (`@RequestParam`, `@PathVariable`)，而 ASP.NET Core 的**约定优于配置**特性在模型绑定上体现得淋漓尽致。

#### 1. 常用注解对照表

| 来源         | Java (Spring MVC)       | .NET (ASP.NET Core) | 差异说明                                                    |
| :----------- | :---------------------- | :------------------ | :---------------------------------------------------------- |
| **URL 路径** | `@PathVariable("id")`   | `[FromRoute]`       | .NET 中若参数名与路由模板 `{id}` 一致，通常可省略注解。     |
| **查询参数** | `@RequestParam("name")` | `[FromQuery]`       | .NET 默认尝试从 Query String 绑定简单类型，通常可省略。     |
| **请求体**   | `@RequestBody`          | `[FromBody]`        | .NET 中复杂类型参数默认推断为 Body (在 API Controller 下)。 |
| **表单**     | `@ModelAttribute`       | `[FromForm]`        | 用于 `multipart/form-data` 上传文件或表单提交。             |
| **Header**   | `@RequestHeader`        | `[FromHeader]`      | 用法基本一致。                                              |

#### 2. 智能推断 (Inference)

在 ASP.NET Core (`[ApiController]`) 中，你经常看不到注解，因为框架会根据**参数类型**和**位置**自动推断：

*   **简单类型** (`int`, `string`, `bool`等) -> 默认从 **Route** 或 **Query** 找。
*   **复杂类型** (`UserDto`) -> 默认从 **Body** (JSON) 找。
*   **IFormFile** -> 默认从 **Form** 找。

**Java (Spring Boot):**
```java
@GetMapping("/users/{id}")
public User getUser(
    @PathVariable String id, 
    @RequestParam(required = false) String type
) { ... }
```

**.NET 10:**
```csharp
[HttpGet("users/{id}")]
public User GetUser(string id, string? type) 
{ 
    // id 自动匹配 {id} (Route)
    // type 自动匹配 ?type=xxx (Query)
}
```

#### 3. 蛇形 vs 驼峰 (Snake Case vs Camel Case)

*   **Java**: 经常需要 `@JsonProperty("user_name")` 来处理 JSON 的蛇形命名。
*   **.NET**: 默认使用 `CamelCase` (小驼峰)。如果 API 入参是蛇形 (`user_name`)，.NET 也可以自动绑定到 PascalCase 属性 (`UserName`)，或者配置全局 JSON 策略。

### 6.3 全局异常处理 (Global Exception Handling)

使用 `IExceptionHandler` 统一处理异常，输出 RFC 7807 格式错误。
```csharp
public class GlobalExceptionHandler : IExceptionHandler {
    public async ValueTask<bool> TryHandleAsync(...) {
        if (exception is UserNotFoundException) {
            httpContext.Response.StatusCode = 404;
            // ...
            return true;
        }
        return false;
    }
}
```

### 6.4 数据访问 (Data Access)

#### ORM: EF Core vs JPA
EF Core 不需要学习 JPQL，直接写 C# LINQ。
```csharp
var dtos = await _context.Users
    .Where(u => u.IsActive && u.Age > 18)
    .Select(u => new UserDto(u.Name, u.Age)) // 直接投影，无需 AutoMapper
    .ToListAsync();
```

#### SQL Mapper: Dapper vs MyBatis / JdbcTemplate
对于复杂 SQL，**Dapper** 是微 ORM 之王，性能接近原生 ADO.NET。它类似于 Java 的 `JdbcTemplate` 但用法更像 `MyBatis` 的注解模式，非常轻量。

**C# (Dapper):**
```csharp
using var conn = new SqlConnection(connString);
// 自动映射，无需 RowMapper
var users = await conn.QueryAsync<User>("SELECT * FROM Users WHERE Age > @Age", new { Age = 18 });
```

**Java (JdbcTemplate):**
```java
// 需要手动 RowMapper 或 BeanPropertyRowMapper
List<User> users = jdbcTemplate.query(
    "SELECT * FROM Users WHERE Age > ?", 
    new BeanPropertyRowMapper<>(User.class), 
    18
);
```

**Java (MyBatis):**
```java
@Select("SELECT * FROM Users WHERE Age > #{age}")
List<User> findByAge(int age);
```

### 6.5 对象映射 (Mapperly vs MapStruct)

Java 开发者熟悉 MapStruct (编译时生成)。在 .NET 中，曾经流行 AutoMapper (运行时反射)，但现在 **Mapperly** 是首选，它基于 Source Generator，零运行时开销，且完美支持 Native AOT。

| 特性           | AutoMapper (.NET 旧王) | Mapperly (.NET 新标) | MapStruct (Java) |
| :------------- | :--------------------- | :------------------- | :--------------- |
| **原理**       | 运行时反射/表达式树    | **编译时源码生成**   | 编译时注解处理   |
| **性能**       | 较慢 (启动预热)        | **极快 (原生代码)**  | 极快             |
| **调试**       | 困难                   | **易 (可断点调试)**  | 易               |
| **Native AOT** | 不支持                 | **完美支持**         | N/A              |

```csharp
[Mapper]
public static partial class UserMapper
{
    // 自动实现部分类方法，支持深拷贝、集合映射
    public static partial UserDto ToDto(this User user); 
}
```

### 6.6 外部 API 调用 (Refit)

推荐 **Refit** (类似 Feign) + **Polly** (弹性策略)。
```csharp
// 定义接口
public interface IGitHubApi {
    [Get("/users/{user}")]
    Task<User> GetUser(string user);
}

// 注册 (自带重试、熔断)
builder.Services.AddRefitClient<IGitHubApi>()
    .ConfigureHttpClient(c => c.BaseAddress = new Uri("..."))
    .AddStandardResilienceHandler();
```

### 6.7 数据校验 (Validation)

校验方式主要分为**注解式**（简单、耦合）和**逻辑分离式**（灵活、解耦）。

#### 1. 基于注解 (Annotation-based)
适合简单字段校验，逻辑直接写在 DTO 上。

**Java (JSR-303/Bean Validation)**:
```java
public class UserDto {
    @NotBlank(message = "Name cannot be empty")
    private String name;

    @Min(value = 18, message = "Must be adult")
    private int age;
}
```

**C# (Data Annotations)**:
.NET 原生支持，命名空间 `System.ComponentModel.DataAnnotations`。
```csharp
using System.ComponentModel.DataAnnotations;

public class UserDto
{
    [Required(ErrorMessage = "Name cannot be empty")]
    public string Name { get; set; }

    [Range(18, 120, ErrorMessage = "Must be adult")]
    public int Age { get; set; }
}
```

#### 2. 逻辑分离 (Separation of Concerns) - **推荐**
将校验规则从 DTO 中剥离，DTO 保持纯净 (POCO/Record)。

**Java (Spring Validator)**:
Java 也有分离方案（如实现 `org.springframework.validation.Validator` 接口），但代码量较大，且不如注解流行。
```java
// 需手动实现 supports 和 validate 方法，较为繁琐，通常配合 Controller 的 @InitBinder 使用
public class UserValidator implements Validator {
    @Override
    public void validate(Object target, Errors errors) {
        ValidationUtils.rejectIfEmpty(errors, "name", "name.empty");
    }
}
```

**C# (FluentValidation)**:
.NET 社区的事实标准，链式调用体验极佳，支持依赖注入。
```csharp
// DTO 保持纯净
public record UserDto(string Name, int Age);

// 定义独立的校验器
using FluentValidation;

public class UserDtoValidator : AbstractValidator<UserDto>
{
    public UserDtoValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name cannot be empty");
        RuleFor(x => x.Age).GreaterThanOrEqualTo(18).WithMessage("Must be adult");
    }
}
```

注册并自动挂钩到 ASP.NET Core 管道：
```csharp
// Program.cs
builder.Services.AddValidatorsFromAssemblyContaining<Program>();
builder.Services.AddFluentValidationAutoValidation(); // 自动拦截请求并返回 400
```

---

## 7. 云原生与工程化 (Cloud Native & Engineering)

### 7.1 Native AOT
.NET 10 的杀手锏。将应用编译为无依赖的单一可执行文件。
*   **启动**: < 50ms
*   **内存**: 极低
*   **场景**: K8s, Serverless, CLI

### 7.2 .NET Aspire
云原生应用编排工具。用 C# 代码定义 Redis, Postgres, RabbitMQ 等依赖关系，一键 F5 启动整个分布式环境，自带 Dashboard。

---

## 8. 附录：生态速查表 (Ecosystem Cheat Sheet)

| 领域            | Java 生态           | .NET 生态 (推荐)     | 备注 |
| :-------------- | :------------------ | :------------------- | :--- |
| **Web 框架**    | Spring Boot         | ASP.NET Core         |      |
| **ORM**         | JPA / Hibernate     | **EF Core**          |      |
| **微ORM**       | MyBatis             | **Dapper**           |      |
| **JSON**        | Jackson             | **System.Text.Json** |      |
| **单元测试**    | JUnit 5             | **xUnit**            |      |
| **Mock**        | Mockito             | **NSubstitute**      |      |
| **断言**        | AssertJ             | **FluentAssertions** |      |
| **对象映射**    | MapStruct           | **Mapperly**         |      |
| **HTTP 客户端** | Feign               | **Refit**            |      |
| **日志**        | SLF4J               | **Serilog**          |      |
| **验证**        | Hibernate Validator | **FluentValidation** |      |
| **定时任务**    | Quartz              | **Hangfire**         |      |
| **文档**        | SpringDoc           | **Scalar / OpenAPI** |      |
| **MQ**          | Spring AMQP         | **MassTransit**      |      |

---

## 9. 总结

从 Java 转到 .NET 10 并不是“切换阵营”，而是**工具箱的升级**。Spring Boot 依然强大，但 .NET 10 在云原生时代提供了更轻量、更高效、更现代的开发体验。

**记住一句话**：在 .NET 中，通常只有一种“标准”的做法（官方推崇），这减少了选择困难症，让团队协作更加顺畅。欢迎来到 .NET 的世界！
