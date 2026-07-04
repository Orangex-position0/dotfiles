---
paths:
  - "**/*.java"
---

# Java Optional 使用规范

> 本规范详细定义了 `java.util.Optional` 的正确使用方式、分层边界和常见反模式。
> 适用于所有使用 JDK 8+ 的 Java 项目。

---

## 1. 核心定位

Optional 擅长两件事：

1. **方法内部的链式处理** — 替代多层嵌套的 null 判断
2. **作为方法返回值** — 通过类型系统表达"可能不存在"的语义（类型即文档）

常见使用场景：数据库查询、集合取出元素、RPC 调用。

---

## 2. 正确用法

### 2.1 链式取值

避免写多层空判断，使用 `map` 链式调用：

```java
// 传统写法
String city = "未知城市";
if (user != null
        && user.getAddress() != null
        && user.getAddress().getCity() != null) {
    city = user.getAddress().getCity();
}

// Optional 链式写法
String city = Optional.ofNullable(user)
        .map(User::getAddress)
        .map(Address::getCity)
        .orElse("未知城市");
```

### 2.2 方法返回可能为空的值

```java
public Optional<User> findActiveUserByEmail(String email) {
    return Optional.ofNullable(userRepo.findByEmail(email))
            .filter(User::isActive);
}
```

### 2.3 null 的默认值处理

```java
// 传统写法
String name = user.getName();
if (name == null) {
    name = "匿名用户";
}

// Optional 写法
String name = Optional.ofNullable(user.getName()).orElse("匿名用户");
```

### 2.4 Stream 场景下的 Optional 处理

`Stream.findFirst()` / `Stream.findAny()` 返回 Optional，需正确处理：

```java
User admin = users.stream()
        .filter(User::isAdmin)
        .findFirst()
        .orElseThrow(() -> new AdminNotFoundException());
```

---

## 3. API 选择指南

### 3.1 `orElse()` vs `orElseGet()`

| 方法 | 求值时机 | 适用场景 |
|------|---------|---------|
| `orElse(default)` | 立即计算（Eager） | 默认值是常量或简单对象 |
| `orElseGet(() -> expr)` | 仅在值不存在时计算（Lazy） | 默认值有计算开销（DB 查询、RPC、Redis） |

```java
// 默认值是常量 — 用 orElse
String name = optName.orElse("未知");

// 默认值有开销 — 用 orElseGet
User user = optUser.orElseGet(() -> userCache.createDefault());
```

### 3.2 `map()` vs `flatMap()`

- `map()` — 转换值，适用于返回普通对象的方法
- `flatMap()` — 展平嵌套，适用于返回 Optional 的方法

```java
// map — 不会产生 Optional 嵌套
Optional<String> name = optUser.map(User::getName);

// flatMap — 避免 Optional<Optional<T>>
Optional<String> email = optUser.flatMap(User::getEmailOpt);
```

### 3.3 `filter()`

在链式调用中进行条件过滤：

```java
Optional<User> activeUser = Optional.ofNullable(userRepo.findById(id))
        .filter(User::isActive);
```

---

## 4. 禁止用法

### 4.1 禁止 `isPresent()` + `get()` 组合

这本质是把 Optional 当作 null 判断使用，丧失了链式表达的能力。

```java
// 错误 — 退化为 null 检查
Optional<User> optional = findUser();
if (optional.isPresent()) {
    User user = optional.get();
    process(user);
}

// 正确 — 使用函数式 API
findUser().ifPresent(this::process);

// 正确 — 需要值时用 orElseThrow
User user = findUser().orElseThrow(UserNotFoundException::new);
```

### 4.2 禁止用作方法参数类型

```java
// 错误
public void saveUser(Optional<User> user) { ... }

// 正确 — 使用方法重载或 @Nullable 注解
public void saveUser(User user) { ... }
public void saveUser(@Nullable User user) { ... }
```

原因：调用方被迫额外包装 `Optional.ofNullable(...)`，增加 API 使用复杂度。

### 4.3 禁止在实体类中使用 Optional 字段

不要在成员变量、DTO、API Response 中使用 `Optional`：

```java
public class User {
    private Optional<String> email; // 错误
}
```

原因：

- JPA / MyBatis 不支持 Optional 字段映射
- Jackson 序列化 Optional 会产生 `{"present": true}` 等异常结构
- 实体字段本身允许 null，Optional 是多余的

### 4.4 禁止在集合元素中使用 Optional

```java
List<Optional<String>> names = ...; // 错误
```

集合本身已经可以包含 null 元素，再套一层 Optional 是多此一举。应在取出元素时处理空值。

---

## 5. 分层使用边界

| 层级 | 返回 Optional | 说明 |
|------|:------------:|------|
| Repository | 允许 | 表达"查询结果可能不存在" |
| Service 私有方法 | 允许 | 内部辅助方法表达"可能找不到" |
| Service 公开方法 | 禁止 | 调用方不应被迫处理 Optional |
| Controller | 禁止 | 统一返回明确的对象或抛异常 |
| DTO / Entity / VO | 禁止 | 字段类型不允许 Optional |
