# Java Coding Standards (AI Rule v2)

> 面向 AI 代码生成与团队开发统一规范
> 优先级：HARD > DESIGN > STYLE > TOOLING

---

# 0. 规范优先级

当规则冲突时，按以下优先级执行：

1. **HARD RULE（必须遵守）**
2. **DESIGN RULE（架构约束）**
3. **STYLE RULE（代码风格）**
4. **TOOLING RULE（工具推荐）**

---

# 1. HARD RULE（强制规则）

## 1.1 代码结构

- 一个 `.java` 文件只能有一个 `public` 顶级类
- 禁止无意义工具类实例化
- 禁止 `public field`（`static final` 常量和 Record components 除外）
- DTO / Entity 不允许包含业务逻辑

## 1.2 安全规则

- ❌ 禁止 SQL 拼接（必须参数化查询）
- ❌ 禁止捕获 `Throwable`
- ❌ 禁止吞异常（catch 后不处理）
- ❌ 禁止 `new Thread()`
- ❌ 禁止 `Executors.*` 快速方法（必须使用线程池 `ThreadPoolExecutor` / `Spring TaskExecutor`）
- ❌ 禁止 magic number / string（必须常量化）

## 1.3 并发规则

- 必须使用线程池（自定义 `ThreadPoolExecutor`）
- `volatile` 只用于可见性，不用于原子性控制

## 1.4 异常规则

- 必须使用具体异常类型
- 必须保留 root cause（异常链）
- 禁止返回错误码代替异常

## 1.5 数据库规则

- 必须使用参数化查询
- 必须使用事务注解（`@Transactional(rollbackFor = Exception.class)`）

---

# 2. DESIGN RULE（架构约束）

## 2.1 分层规范

- **Controller**：只负责 HTTP 交互
- **Service**：业务逻辑编排
- **Repository**：数据访问
- **DTO**：数据传输，不含业务逻辑

## 2.2 代码组织

- 一个类只负责一个核心职责（SRP）
- 方法不超过 50 行
- 重载方法必须连续排列

## 2.3 命名原则

必须语义化，禁止模糊命名：

❌ `flag`, `data`, `temp`, `obj`, `list`
✅ `isActive`, `userList`, `orderResult`

## 2.4 集合设计

- 优先使用不可变集合（`List.of()`, `Map.of()`）
- 方法返回集合必须避免 `null`（返回 `Collections.emptyList()`）
- 初始化集合时指定容量（`new ArrayList<>(1000)`）

## 2.5 空值处理

### 基本原则

- 不允许返回 `null`（集合返回 `emptyList()`，对象返回空对象或抛出异常）
- 不允许使用 `Optional` 作为字段或 API response

### Optional 使用边界

- Repository 层：允许返回 `Optional`
- Service 层：必须立即拆箱 `Optional`，转换为明确类型或抛出异常
- Controller / DTO / API response：禁止使用 `Optional`

### 使用方式规范

- 优先使用 `orElse()` / `orElseThrow()`，避免 `get()`
- 禁止使用 `Optional.get()`（除非已检查 `isPresent()`）

### 示例

```java
// Repository - 可以返回 Optional
public Optional<User> findById(Long id) {
    return Optional.ofNullable(userRepository.findById(id));
}

// Service - 必须拆箱
public User getUser(Long id) {
    return repository.findById(id)
        .orElseThrow(() -> new UserNotFoundException(id));
}

// Service - 返回空对象而非 null
public User getOrDefault(Long id) {
    return repository.findById(id)
        .orElse(User.UNKNOWN);
}

// 错误示例
public Optional<User> getUser(Long id) {  // ❌ Service 不应返回 Optional
    return repository.findById(id);
}
```

---

# 3. STYLE RULE（代码风格）

## 3.1 基本格式

- 缩进：4 spaces
- 行宽：120
- UTF-8 编码
- K&R 大括号风格

## 3.2 Import 规则

- 禁止 `*` import
- import 必须排序
- static import 在前

## 3.3 命名规范

| 类型     | 规范             |
| -------- | ---------------- |
| Class    | UpperCamelCase   |
| Method   | lowerCamelCase   |
| Variable | lowerCamelCase   |
| Constant | UPPER_SNAKE_CASE |
| Package  | lowercase        |

## 3.5 日志规范

- 必须使用 SLF4J
- 必须使用 `{}` 占位符
- 禁止字符串拼接日志
- 禁止输出敏感信息（密码、token）

## 3.6 注释规则

- 代码优先自解释
- 注释解释"为什么"，不是"做什么"
- `public` API 必须有 Javadoc
- 禁止行尾注释

---

# 4. TOOLING RULE（工具规范）

## 4.1 推荐工具

- **格式化**：google-java-format + Spotless
- **质量检查**：Checkstyle + SonarLint
- **日志**：SLF4J + Logback
- **连接池**：HikariCP

## 4.2 Maven 插件

推荐使用 `spotless-maven-plugin` 和 `maven-checkstyle-plugin`

---

# 5. AI CODE GENERATION RULE（核心）

## 5.1 输出原则

AI 生成代码必须遵循：

- 优先可读性 > 简洁性
- 避免过度抽象设计
- 不引入未使用依赖
- 默认使用现代 Java 语法（JDK 17+）

## 5.2 禁止行为

- ❌ 不生成不完整代码片段（除非请求）
- ❌ 不省略异常处理
- ❌ 不使用伪代码替代实现
- ❌ 不引入未说明的库

## 5.3 默认工程假设

- Spring Boot 项目
- Maven 构建
- JDK 17+
- RESTful API 风格

---

# 6. 代码示例

## ❌ 错误示例

```java
// Magic number
int status = 1;

// SQL 拼接
String sql = "SELECT * FROM users WHERE id = " + userId;

// 裸线程
new Thread(() -> doWork()).start();

// 吞异常
try {
    doSomething();
} catch (Exception e) {
    // ignore
}

// 返回 null
public List<User> getUsers() {
    return users == null ? null : users;
}
```

## ✅ 正确示例

```java
// 常量化
private static final int STATUS_ACTIVE = 1;

// 参数化查询
String sql = "SELECT * FROM users WHERE id = ?";

// 线程池
executorService.submit(() -> doWork());

// 异常处理
try {
    doSomething();
} catch (Exception e) {
    log.error("操作失败", e);
    throw new ServiceException("处理失败", e);
}

// 避免 null
public List<User> getUsers() {
    return users != null ? users : Collections.emptyList();
}

// 使用 Optional
public Optional<User> findById(Long id) {
    return Optional.ofNullable(userRepository.findById(id));
}

// var 使用
var user = new User();  // 类型显而易见
Function<String, User> mapper = str -> parse(str);  // 复杂类型显式声明
```

---

# 7. 特殊场景规则

## 7.1 日期时间处理

- 必须使用 `java.time` API（禁止 `Date`, `Calendar`）
- 数据库存储使用 `Instant` 或 `timestamp`
- 前端交互使用 ISO-8601 格式（`2026-06-03T15:30:00+08:00`）
- 时间范围查询使用半开区间 `[start, end)`

## 7.2 工具类设计

```java
public final class StringUtils {

    private StringUtils() {
        throw new UnsupportedOperationException("工具类禁止实例化");
    }

    public static boolean isEmpty(String str) {
        return str == null || str.isEmpty();
    }
}
```

## 7.3 不可变对象

优先使用不可变集合和不可变类：

```java
// 不可变集合
List<String> immutable = List.of("a", "b", "c");

// 不可变类
public final class ImmutableUser {
    private final String name;
    private final int age;

    public ImmutableUser(String name, int age) {
        this.name = name;
        this.age = age;
    }

    // 只提供 getter，不提供 setter
}
```
