---
description: "Rust error handling best practices - copy to project .claude/rules/ when working on a Rust project"
alwaysApply: false
---

# Rust 错误处理最佳实践

## 核心原则

1. **优先用 `?` 传播错误** — 让错误冒泡到调用链上层，在边界处统一处理
2. **提供默认值** — 当 `None` / `Err` 有合理的降级行为时，使用安全的默认值方法
3. **`expect()` 仅用于"理论上不可能失败"的场景** — 如启动阶段加载硬编码配置、测试断言
4. **禁止裸 `unwrap()`** — 生产代码中必须使用安全替代方案

## Option 安全解包方法

| 方法 | 适用场景 | 备注 |
|------|----------|------|
| `unwrap_or(default)` | 有明确的默认值 | 最常用 |
| `unwrap_or_else(\|\| expr)` | 默认值需要计算 | 惰性求值，`None` 时才执行闭包 |
| `unwrap_or_default()` | 类型 `T` 实现了 `Default` | 适用于 `String`、`Vec`、`u32` 等常见类型 |
| `or_else(\|\| Some(val))` | 链式调用中提供备选值 | 常配合 `and_then` 使用 |

```rust
// unwrap_or — 直接给默认值
let port = config.port.unwrap_or(8080);

// unwrap_or_else — 惰性计算
let data = cache.get(key).unwrap_or_else(|| expensive_fetch(key));

// unwrap_or_default — 类型有 Default 实现
let name: String = user_input.unwrap_or_default();
```

## Result 安全处理方法

| 方法 | 适用场景 | 备注 |
|------|----------|------|
| `?` 操作符 | 错误应向上传播 | 最惯用方式 |
| `unwrap_or(default)` | `Err` 时使用默认值继续 | 不关心具体错误 |
| `unwrap_or_else(\|err\| fallback)` | 需要根据错误类型决定降级策略 | 可访问错误信息 |
| `.ok()` | 丢弃错误，只关心成功值 | 将 `Result<T, E>` 转为 `Option<T>` |
| `or_else(\|err\| Ok(recovered))` | 错误恢复 | 用另一个有效值替代错误结果 |

```rust
// ? 传播错误
fn read_config(path: &str) -> Result<Config, io::Error> {
    let content = fs::read_to_string(path)?;
    Ok(parse(&content))
}

// unwrap_or_else — 根据错误做降级
let conn = connect(db_url).unwrap_or_else(|err| {
    log::warn!("DB连接失败({err})，使用内存存储");
    InMemoryStore::new()
});

// .ok() — 不在乎错误
let maybe_count: Option<usize> = str::parse::<usize>(input).ok();
```

## 决策流程

```
遇到 Option / Result
  │
  ├─ 调用者能处理这个错误吗？
  │   ├─ 是 → 用 ? 传播，在边界处理
  │   └─ 否 → 有合理的默认值吗？
  │       ├─ 是 → unwrap_or / unwrap_or_else
  │       └─ 否 → 这真的是不可能失败吗？
  │           ├─ 是 → expect("说明为什么不可能失败")
  │           └─ 否 → 重新设计错误处理策略
  │
  └─ unwrap() → 永远不应该出现在生产代码中
```
