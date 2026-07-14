---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Rust TDD 测试驱动开发规范

> 全局 TDD 流程见 [TDD 开发流程](./tdd-development-flow.md)，通用测试规范见 [测试规范](./testing-standards.md)。
> 本文只描述 Rust 特有的 TDD 实践；Rust 基础约定见 [Rust 编码规范](./rust-conventions.md)、[Rust 错误处理](./rust-error-handling.md)、[Rust 工作流](./rust-workflow-standards.md)。

---

## 1. 核心理念：类型系统是第一层测试

Rust 的类型系统和编译器是天然的「第一层测试」：

- **大量问题提前到编译期暴露**——AI 生成代码时，编译错误通常比逻辑错误更早暴露
- **compile error 是 AI 的重要反馈信号**——禁止用 `.clone()` / `.unwrap()` / `Box` / `Arc` 绕过编译器，而是理解并修正底层问题
- **类型驱动设计**——优先用 enum 而不是 String 表示有限集合，让非法状态在编译期不可表达

> 不要把编译器当敌人。能编译通过且无 warning 的代码，已经过了第一层质量过滤。

---

## 2. Rust TDD 自动化流程：`todo!()` 占位法

Rust 的 `todo!()` 宏让 Red 阶段的「失败测试」**确定性失败**（不依赖业务逻辑偶然失败），是 AI Agent 友好的 TDD 变体。

### 2.1 Red — 写测试 + `todo!()` 占位

1. 让 AI 定义错误类型（库代码用 `thiserror`）
2. 写测试，被测函数用 `todo!()` 占位

```rust
pub fn add(a: i32, b: i32) -> i32 {
    todo!()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn add_two_positive_numbers_returns_sum() {
        assert_eq!(add(1, 2), 3);
    }
}
```

### 2.2 确认 Red 状态

让 AI 自动跑测试，预期全部 panic：

```bash
cargo nextest run
```

**验证标准**：所有新测试因 `not yet implemented` panic，而不是其他原因。

### 2.3 Green — 替换 `todo!()`

将 `todo!()` 替换为真实实现：

```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

### 2.4 确认 Green 状态

再跑一次测试，全部通过。

### 2.5 Refactor

在测试持续通过的前提下重构。

---

## 3. Rust 五层测试分层

通用测试分层（Unit / Integration / E2E）见 [测试规范](./testing-standards.md)，性能基准测试见 [性能基准规范](./performance-benchmark.md)。Rust 在此基础上增加三层特色测试：

| 层级 | 目的 | 工具 |
|------|------|------|
| Unit Test | 验证 trait 行为、状态转换、边界条件 | `#[cfg(test)] mod tests` + `assert!` |
| **Property Test** | 验证不变量（对任意输入成立） | `proptest` 或 `quickcheck` |
| **Compile Test** | 验证类型约束、生命周期规则在编译期被拒绝 | `trybuild` 或 `static_assertions` |
| **Performance Test** | 测量执行时间、检测性能回归 | `criterion` 或 `iai-callgrind`（详见性能基准规范） |
| Integration Test | 验证 crate 间交互、文件系统、网络行为 | `tests/` 目录 |

### 3.1 Property Test（必写场景）

> 完整的 PBT 分级强制规则、框架选型与防漂移硬规则见 [Property-Based Testing 规范](./property-based-testing.md)。本节只列 Rust 特有要点。

涉及数据变换的模块必须有 proptest roundtrip 测试：

```rust
proptest! {
    #[test]
    fn parse_format_roundtrip(s in "[a-z]{1,10}") {
        let parsed = parse(&s).unwrap();
        prop_assert_eq!(format(&parsed), s);
    }
}
```

Rust 特有补充：

- **shrinking 自动化**：proptest 默认对失败输入做 shrinking，报告最小反例。用 `prop_assert_eq!` / `prop_assert!` 而非 `assert_eq!`，前者失败时触发 shrinking 并返回测试失败而非 panic。
- **失败可复现**：proptest 把失败用例持久化到 `proptest.regressions` 文件，后续持续重跑；提交该文件保证 CI 与本地一致。手动复现用环境变量 `PROPTEST_SEED`。
- **何时不用 PBT**：固定输入-固定输出的业务结果断言、IO / 副作用、UI 渲染——继续用普通 `#[test]`，禁止硬塞 proptest。

### 3.2 Compile Test

对于「某个类型约束应该编译失败」的场景，用 `trybuild` 验证编译期错误：

```rust
#[test]
fn invalid_lifetime_should_fail_to_compile() {
    let t = trybuild::TestCases::new();
    t.compile_fail("tests/ui/invalid_lifetime.rs");
    t.pass("tests/ui/valid_lifetime.rs");
}
```

---

## 4. AI Coding 陷阱清单（Rust 特定）

⚠️ Code Review 时重点检查以下 AI 生成 Rust 代码的常见陷阱：

| 陷阱 | 后果 | 正确做法 |
|------|------|---------|
| 滥用 `.clone()` 绕过所有权 | 性能损失、掩盖设计缺陷 | 先想清楚所有权，必要时重构数据流 |
| 滥用 `.unwrap()` / `.expect()` | 生产代码 panic | 见 [Rust 错误处理](./rust-error-handling.md)，用 `?` 或 `unwrap_or*` |
| 「能编译但设计不合理」的生命周期 | 难维护、难扩展 | 重新审视数据归属，避免过长的生命周期参数 |
| 用 `Box` / `Arc` 强行规避借用检查 | 引入不必要的堆分配、隐藏所有权问题 | 重构为清晰的所有权关系 |

---

## 5. 防 AI 作弊（Rust 补充）

> 全局防作弊原则见 [TDD 开发流程 §5](./tdd-development-flow.md)。Rust 特定补充：

- **禁止通过修改期望值让测试通过**——AI 若在 Green 阶段发现期望值「不合理」，必须先与开发者确认是测试错还是实现错，禁止单方面修改期望值
- **复杂场景必须手写**——Property Test 覆盖不变量，但极端边界条件（并发竞争、时区切换、特殊编码输入）仍需手写针对性测试
- **禁止删除失败的测试**——发现测试失败时，先定位根因，禁止通过删除测试让套件变绿

---

## 6. 相关文档

- **全局 TDD 流程**：[tdd-development-flow.md](./tdd-development-flow.md)
- **通用测试规范**：[testing-standards.md](./testing-standards.md)
- **Rust 编码规范**：[rust-conventions.md](./rust-conventions.md)
- **Rust 错误处理**：[rust-error-handling.md](./rust-error-handling.md)
- **Rust 工作流**：[rust-workflow-standards.md](./rust-workflow-standards.md)

---

## 附录 A：Rust 项目 TDD 起手 CLAUDE.md 模板

新建 Rust 项目时，可将以下内容作为项目根 `CLAUDE.md` 的起手模板，强制 AI Agent 遵循 TDD 与质量规范。**去重说明**：与全局 `rules/` 重复的条目（如 unwrap 禁令）已链接引用，不在此重复展开。

````md
# 项目名称

## 开发流程

本项目严格遵循 TDD 流程，详见 [TDD 开发流程](~/.claude/rules/tdd-development-flow.md) 和 [Rust TDD](~/.claude/rules/tdd-rust.md)。

1. **先写测试，再写实现**——禁止 `todo!()` 占位的实现进入主干
2. **测试必须先跑失败**——确认测试在检验真实行为
3. **最小实现让测试通过**——不要过度设计
4. **重构时测试必须全绿**——改完代码第一件事跑 `cargo nextest run`

## 代码规范

- **错误处理**：遵循 [Rust 错误处理](~/.claude/rules/rust-error-handling.md)
  - 库代码用 `thiserror` 定义错误类型
  - 应用代码用 `anyhow` 传播错误
  - 每个 `?` 都要考虑调用者需要什么上下文
- **数据模型**：优先用 enum 而不是 String 表示有限集合
- **命名**：测试函数用英文 snake_case，注释用中文说明「为什么测这个」
- **并发**：共享状态用 `Arc<Mutex<T>>` 或 `Arc<RwLock<T>>`，禁止 `Rc`

## 测试规范

- 单元测试放在 `#[cfg(test)] mod tests` 里
- 集成测试放在 `tests/` 目录下
- 测试命名格式：`test_<场景>_<期望行为>`
- 每个公开函数至少覆盖：正常路径、错误路径、边界条件
- 涉及数据变换的模块必须有 proptest roundtrip 测试

## 依赖选择

- 解析：`nom`（不用正则）
- 错误：`thiserror`（库）/ `anyhow`（应用）
- 序列化：`serde` + `serde_json`
- 测试：`proptest`、`tempfile`
- 日志：`tracing`（不用 `println!`）

## 项目结构

```
src/
├── lib.rs          # 库入口
├── error.rs        # 错误类型定义
├── types.rs        # 核心数据模型
tests/              # 集成测试
fixtures/           # 测试数据
```

## 禁止的写法

- `.unwrap()` 在非测试代码中（详见 rust-error-handling.md）
- `String` 当错误类型
- `println!` 做日志（用 `tracing`）
- `clone()` 绕过借用检查（先想清楚所有权）
- `unsafe` 除非有注释说明为什么安全
````
