+++
date = '2026-08-19T17:47:45+08:00'
draft = false
title = 'API路由命名规范'
categories = ['后端开发']
tags = ['API', 'RESTful', 'Java', 'Spring Boot', '开发规范']
+++

## API路由命名规范

### 核心原则

1.  **使用名词（复数），而非动词**：API 路由应该标识资源，而不是对资源执行的操作。操作由 HTTP 方法 (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`) 来定义。
    *   **好**: `GET /users` (获取用户列表)
    *   **不好**: `GET /getUsers`

2.  **保持一致性**：在整个 API 中使用统一的命名约定（如短横线命名 `kebab-case`）、大小写和复数形式。

3.  **使用 HTTP 方法表达操作**：
    *   `GET`： 检索资源。
    *   `POST`： 创建新资源。
    *   `PUT`： 完整更新资源。
    *   `PATCH`： 部分更新资源。
    *   `DELETE`： 删除资源。

4.  **版本化你的 API**：将 API 版本号直接嵌入到 URL 路径中（如 `/v1/`），这是最明确和最常见的方式。

5.  **API 响应格式**：虽然路由本身不强制，但通常响应格式（如 JSON）通过 `Content-Type` 头指定，而不是包含在 URL 中（例如，避免 `/api/users.json`）。

---

### 具体规则与示例说明

假设我们有一个博客平台的应用，管理用户 (`users`)、文章 (`articles`) 和评论 (`comments`)。

#### 1. 基础资源操作 (CRUD)

| HTTP 方法 | 路由端点         | 描述说明                                  | 示例说明                                                                          |
| :-------- | :--------------- | :---------------------------------------- | :-------------------------------------------------------------------------------- |
| `GET`     | `/v1/users`      | **获取**所有用户的**列表**                | 返回一个用户对象数组                                                              |
| `POST`    | `/v1/users`      | **创建**一个**新**用户                    | 请求体 (Body) 中包含新用户的 JSON 数据                                            |
| `GET`     | `/v1/users/{id}` | **获取**某个**特定**用户的信息（通过 ID） | `GET /v1/users/123` 返回 ID 为 123 的用户详情                                     |
| `PUT`     | `/v1/users/{id}` | **完整更新**某个特定用户的信息            | `PUT /v1/users/123` 的请求体应包含该用户所有必填字段的新值                        |
| `PATCH`   | `/v1/users/{id}` | **部分更新**某个特定用户的信息            | `PATCH /v1/users/123` 的请求体只需包含要更新的字段（如 `{ "name": "New Name" }`） |
| `DELETE`  | `/v1/users/{id}` | **删除**某个特定用户                      | `DELETE /v1/users/123` 会删除 ID 为 123 的用户                                    |

#### 2. 资源之间的层级关系 (嵌套路由)

当某个资源从属于另一个资源时，在路由中体现这种层级关系。

*   **示例**：获取某篇特定文章下的所有评论；为某篇特定文章创建一条新评论。

| HTTP 方法 | 路由端点                                        | 描述说明                                    |
| :-------- | :---------------------------------------------- | :------------------------------------------ |
| `GET`     | `/v1/articles/{articleId}/comments`             | 获取**某篇文章**下的所有评论列表            |
| `POST`    | `/v1/articles/{articleId}/comments`             | 在**某篇文章**下**创建**一条新评论          |
| `GET`     | `/v1/articles/{articleId}/comments/{commentId}` | 获取**某篇文章**下的**某条特定**评论        |
| `PUT`     | `/v1/articles/{articleId}/comments/{commentId}` | 更新**某篇文章**下的某条特定评论 (完整更新) |
| `DELETE`  | `/v1/articles/{articleId}/comments/{commentId}` | 删除**某篇文章**下的某条特定评论            |

**注意**：嵌套不宜过深，否则路由会变得很长且难以维护（如 `/v1/users/123/posts/456/comments/789/replies/1`）。通常超过两级嵌套就应该考虑拆分或优化。

#### 3. 非 CRUD 操作 (自定义动作)

有时你需要一个不符合“创建、读取、更新、删除”模型的操作。这时有两种推荐做法：

**a) 将其转化为资源的属性（首选）**
使用 `PATCH` 来更新一个代表状态的字段。
*   **示例**：`激活`用户 -> `PATCH /v1/users/123` 请求体为 `{ "status": "active" }`

**b) 使用动词作为端点（不得已而为之）**
如果无法转化为属性（例如，操作的计算成本很高或是一个“动作”），可以将动词附加在标准资源端点之后。

| HTTP 方法 | 路由端点                        | 描述说明                   |
| :-------- | :------------------------------ | :------------------------- |
| `POST`    | `/v1/users/{id}/activate`       | 激活一个用户账户           |
| `POST`    | `/v1/articles/{id}/publish`     | 发布一篇草稿状态的文章     |
| `POST`    | `/v1/computations/{id}/cancel`  | 取消一个正在进行的计算任务 |
| `POST`    | `/v1/users/{id}/password-reset` | 为用户触发密码重置流程     |

**关键点**：对这些“动作”端点**始终使用 `POST`**，因为它不是标准 CRUD 操作。

#### 4. 过滤、排序、搜索和分页 (Query Parameters)

这些功能**不应该**作为路由路径的一部分，而应该使用**查询字符串（Query String Parameters）** 来实现。

| 功能     | 示例路由                             | 描述说明                                           |
| :------- | :----------------------------------- | :------------------------------------------------- |
| **过滤** | `GET /v1/articles?state=published`   | 只获取已**发布**的文章                             |
| **排序** | `GET /v1/users?sort=-createdAt`      | 获取用户列表，按创建时间**降序**排列 (`-`表示降序) |
| **搜索** | `GET /v1/articles?q=restful`         | **搜索**标题或内容中包含 “restful” 的文章          |
| **分页** | `GET /v1/articles?page=2&limit=10`   | 获取**第二页**的文章，每页**10**条                 |
| **组合** | `GET /v1/users?role=admin&sort=name` | 获取所有管理员角色并按姓名排序                     |

---

### 完整示例：博客 API v1

| 功能描述                     | HTTP 方法 | 路由端点                                    |
| :--------------------------- | :-------- | :------------------------------------------ |
| 获取所有已发布的文章         | `GET`     | `/v1/articles?state=published`              |
| 创建一篇新文章（草稿）       | `POST`    | `/v1/articles`                              |
| 更新某篇文章的标题和内容     | `PATCH`   | `/v1/articles/456`                          |
| 删除一篇文章                 | `DELETE`  | `/v1/articles/456`                          |
| 获取某篇文章的所有评论       | `GET`     | `/v1/articles/456/comments`                 |
| 为某篇文章点赞（自定义动作） | `POST`    | `/v1/articles/456/like`                     |
| 取消点赞                     | `DELETE`  | `/v1/articles/456/like`                     |
| 搜索用户                     | `GET`     | `/v1/users?q=alice`                         |
| 重置用户密码（自定义动作）   | `POST`    | `/v1/users/123/password-reset`              |
| 获取当前登录用户的个人信息   | `GET`     | `/v1/users/me` ( `me` 是 `{id}` 的常用别名) |

### 简化版规范 (RPC 风格 - 只用 GET & POST)

在某些特定场景（如浏览器兼容性限制、内部极简服务、老旧系统迁移）下，可能需要采用仅使用 `GET` 和 `POST` 的简化规范。这种风格更接近 RPC（远程过程调用），通过 URL 中的动词来表达操作意图。

#### 1. 核心原则

*   **GET**: 仅用于**无副作用**的数据查询（Read）。
*   **POST**: 用于所有**有副作用**的操作（Create, Update, Delete）以及复杂查询（参数过长或涉及敏感信息）。
*   **URL 命名**: 使用 **`动词 + 名词`** 的形式，明确表达意图。

#### 2. 路由示例对比

| 操作类型 | RESTful 风格 (推荐)        | 简化版 RPC 风格 (替代方案)                   | 说明                              |
| :------- | :------------------------- | :------------------------------------------- | :-------------------------------- |
| **查询** | `GET /users/123`           | `GET /user/getDetail?id=123`                 | 简化版直接在 URL 中体现动作       |
| **查询** | `GET /users?role=admin`    | `GET /user/list?role=admin`                  | 列表查询通常用 `list` 或 `search` |
| **创建** | `POST /users`              | `POST /user/create` <br> `POST /user/add`    | Body 中包含数据                   |
| **更新** | `PUT /users/123`           | `POST /user/update`                          | Body 中包含 ID 和更新字段         |
| **删除** | `DELETE /users/123`        | `POST /user/delete` <br> `POST /user/remove` | Body 中包含 ID，或作为 Query 参数 |
| **动作** | `POST /users/123/activate` | `POST /user/activate`                        | 动作即路由                        |

#### 3. 注意事项

*   **参数传递**：
    *   GET 请求参数放在 Query String 中。
    *   POST 请求参数通常放在 Body (JSON) 中。
*   **一致性**：一旦选择简化版规范，应在整个项目中保持一致，避免与 RESTful 风格混用导致混乱。
*   **状态码**：在简化版规范中，HTTP 状态码通常只使用 `200 OK` 表示请求成功到达服务器，具体的业务成功或失败通过响应体中的 `code` 字段判断（参考下文“统一响应体结构”）。

---

### 总结与最佳实践

*   **命名风格**：推荐使用 **`kebab-case`（短横线命名）** 作为 URL 路径，例如 `/v1/user-profiles`。它比 `snake_case` 和 `camelCase` 更具可读性，并且是域名标准的一部分。
*   **SSL/HTTPS**：**必须**使用 HTTPS 来保护你的 API。
*   **文档化**：使用 OpenAPI (Swagger) 等工具为你的 API 生成详细的、交互式的文档。清晰的文档和一致的规则同样重要。
*   **返回适当的 HTTP 状态码**：`200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found`, `500 Internal Server Error` 等。

遵循这套规则，你的 API 将变得清晰、直观、易于理解和维护，极大地方便了前端和其他服务消费者。

## 统一的返回结构和自定义业务异常

### 1. 统一响应体结构 (Standard Response Body)

所有成功的请求都遵循此格式，方便前端统一处理。

**成功响应示例:**
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "id": 123,
    "name": "John Doe"
  }
}
```

**分页数据响应示例:**
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "list": [
      {"id": 1, "name": "User1"},
      {"id": 2, "name": "User2"}
    ],
    "total": 2,
    "page": 1,
    "size": 10
  }
}
```

**业务异常响应示例:**
```json
{
  "code": 10001,
  "msg": "用户名已存在",
  "data": null
}
```

**HTTP 错误响应示例 (如 404):**
```json
{
  "code": 404,
  "msg": "请求的资源不存在",
  "data": null
}
```

**对应 Java 实体类:**
```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    private Integer code;
    private String msg;
    private T data;

    // 快速创建成功响应的静态方法
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(200, "success", data);
    }

    public static <T> ApiResponse<T> success() {
        return success(null);
    }

    // 快速创建失败响应的静态方法
    public static <T> ApiResponse<T> error(Integer code, String msg) {
        return new ApiResponse<>(code, msg, null);
    }
}
```

---

### 2. 自定义业务异常 (Custom Business Exception)

我们创建一个自定义异常类，用于抛出明确的业务错误。

```java
/**
 * 自定义业务异常
 */
public class BusinessException extends RuntimeException {
    private final Integer code;

    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    public BusinessException(String message) {
        // 如果不指定code，默认使用系统错误码，比如 500
        super(message);
        this.code = 500;
    }

    public Integer getCode() {
        return code;
    }
}

/**
 * 错误码枚举（推荐使用枚举统一管理所有错误码和消息）
 */
public enum ErrorCode {
    SUCCESS(200, "成功"),
    FORBIDDEN(403, "无权限执行此操作"),
    UNAUTHORIZED(401, "未认证"),
    INTERNAL_SERVER_ERROR(500, "服务器内部错误"),
    PARAMS_ERROR(10000, "请求参数错误"),
    USER_NOT_FOUND(10001, "用户不存在"),
    USER_EXISTS(10002, "用户名已存在"),
    ARTICLE_NOT_FOUND(20001, "文章不存在");

    private final int code;
    private final String msg;

    ErrorCode(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public int getCode() {
        return code;
    }

    public String getMsg() {
        return msg;
    }
}

// 使用枚举优化后的自定义异常
public class BusinessException extends RuntimeException {
    private final Integer code;

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMsg());
        this.code = errorCode.getCode();
    }

    public BusinessException(ErrorCode errorCode, String customMessage) {
        // 允许在枚举消息的基础上进行微调
        super(customMessage);
        this.code = errorCode.getCode();
    }

    public Integer getCode() {
        return code;
    }
}
```

---

### 3. 全局异常处理器 (Global Exception Handler)

这是核心部分，它拦截所有控制器抛出的异常，并将其转换为统一的 JSON 格式返回。

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    /**
     * 处理自定义业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public ApiResponse<?> handleBusinessException(BusinessException e) {
        log.warn("业务异常: code={}, msg={}", e.getCode(), e.getMessage());
        return ApiResponse.error(e.getCode(), e.getMessage());
    }

    /**
     * 处理参数校验异常（例如@Validated触发的异常）
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<?> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getAllErrors()
                .stream()
                .map(DefaultMessageSourceResolvable::getDefaultMessage)
                .collect(Collectors.joining("; "));
        log.warn("参数校验失败: {}", message);
        return ApiResponse.error(ErrorCode.PARAMS_ERROR.getCode(), message);
    }

    /**
     * 处理404（NoHandlerFoundException通常需要配置spring.mvc.throw-exception-if-no-handler-found=true）
     */
    @ExceptionHandler(NoHandlerFoundException.class)
    public ApiResponse<?> handleNoHandlerFoundException(NoHandlerFoundException e) {
        log.warn("接口不存在: {} {}", e.getHttpMethod(), e.getRequestURL());
        return ApiResponse.error(404, "接口不存在");
    }

    /**
     * 处理其他所有未捕获异常
     */
    @ExceptionHandler(Exception.class)
    public ApiResponse<?> handleException(Exception e) {
        log.error("系统异常: ", e);
        // 生产环境可以返回一个更友好的消息，而不是详细的错误堆栈
        return ApiResponse.error(ErrorCode.INTERNAL_SERVER_ERROR.getCode(), "系统繁忙，请稍后再试");
    }
}
```

---

### 4. 结合路由规则的完整 Controller 示例

现在，我们将以上所有部分结合到具体的 API 控制器中。

```java
@RestController
@RequestMapping("/v1/users")
@Validated
public class UserController {

    @Autowired
    private UserService userService;

    // GET /v1/users?page=1&size=10
    @GetMapping
    public ApiResponse<PageInfo<UserVO>> getUsers(@RequestParam(defaultValue = "1") Integer page,
                                                  @RequestParam(defaultValue = "10") Integer size) {
        PageInfo<UserVO> userPage = userService.getUserPage(page, size);
        return ApiResponse.success(userPage);
    }

    // GET /v1/users/123
    @GetMapping("/{id}")
    public ApiResponse<UserVO> getUserById(@PathVariable Long id) {
        UserVO user = userService.getUserById(id);
        if (user == null) {
            // 抛出业务异常，会被全局处理器捕获并转换为统一格式
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return ApiResponse.success(user);
    }

    // POST /v1/users
    @PostMapping
    public ApiResponse<UserVO> createUser(@Valid @RequestBody CreateUserRequest request) {
        // 检查用户名是否已存在
        if (userService.checkUserExists(request.getUsername())) {
            throw new BusinessException(ErrorCode.USER_EXISTS);
        }
        UserVO newUser = userService.createUser(request);
        return ApiResponse.success(newUser);
    }

    // PUT /v1/users/123
    @PutMapping("/{id}")
    public ApiResponse<UserVO> updateUser(@PathVariable Long id, @Valid @RequestBody UpdateUserRequest request) {
        UserVO updatedUser = userService.updateUser(id, request);
        return ApiResponse.success(updatedUser);
    }

    // DELETE /v1/users/123
    @DeleteMapping("/{id}")
    public ApiResponse<?> deleteUser(@PathVariable Long id) {
        boolean success = userService.deleteUser(id);
        if (!success) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return ApiResponse.success(); // data为null
    }

    // POST /v1/users/123/disable (一个自定义动作)
    @PostMapping("/{id}/disable")
    public ApiResponse<?> disableUser(@PathVariable Long id) {
        userService.disableUser(id);
        return ApiResponse.success();
    }
}
```

### 总结与工作流

1.  **客户端请求**: `GET /v1/users/999` (用户999不存在)
2.  **Controller**: `getUserById` 方法查询后发现用户不存在，抛出 `new BusinessException(ErrorCode.USER_NOT_FOUND)`
3.  **全局异常处理器**: `@ExceptionHandler(BusinessException.class)` 方法捕获该异常。
4.  **构建统一响应**: 处理器从异常中取出 `code=10001` 和 `msg="用户不存在"`，构建出 `ApiResponse.error(10001, "用户不存在")`。
5.  **返回给客户端**:
    ```json
    {
      "code": 10001,
      "msg": "用户不存在",
      "data": null
    }
    ```
6.  **前端处理**: 前端接收到响应后，检查 `code` 不是 `200`，则在界面提示 `msg` 中的错误信息 `“用户不存在”`。

这套方案确保了你的 API 在**成功、失败、异常**等各种情况下，都能保持结构清晰、格式统一，极大提升了前后端的协作效率和系统的可维护性。