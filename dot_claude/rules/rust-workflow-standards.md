---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Rust 项目工作流规则

> 编码风格与错误处理分别见 [Rust 编码规范](./rust-conventions.md) 和 [Rust 错误处理最佳实践](./rust-error-handling.md)。

---

## 1. 代码质量

### 格式化

代码修改完成后，必须运行格式化检查：

```bash
cargo fmt --all -- --check
```

若检查不通过，执行 `cargo fmt --all` 自动格式化。

### Lint

必须通过 clippy 检查，warnings 视为错误：

```bash
cargo clippy --locked --all-targets --all-features -- -D warnings
```

### 自动修复

Rust 版本升级导致新 warning 时，使用自动修复：

```bash
cargo fix --allow-dirty
cargo clippy --fix --allow-dirty
```

---

## 2. 测试

运行测试时使用 `cargo nextest`（如果已安装），否则回退到 `cargo test`：

```bash
cargo nextest run --locked
```

---

## 3. 项目配置

### 工具链

新建 Rust 项目时，创建 `rust-toolchain.toml` 固定工具链版本：

```toml
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy"]
```

### Release Profile

默认 release 配置偏向编译速度。仅当用户明确要求优化二进制体积时，才将 `lto` 改为 `"thin"` 或 `"fat"`：

```toml
[profile.release]
incremental = true
lto = "off"
debug = 1
codegen-units = 16
```

### Cargo.lock 策略

| 项目类型 | Cargo.lock | 原因 |
|---------|:----------:|------|
| Application（二进制） | 必须提交 | 保证构建可复现 |
| Library（库） | 不提交 | 让下游自行解析依赖版本 |

---

## 4. Workspace 与依赖

### Workspace Dependencies

修改或创建 Workspace 子 crate 时，依赖必须通过 `workspace = true` 引用，保持版本统一：

```toml
# 根 Cargo.toml
[workspace.dependencies]
tokio = "1"
serde = "1"

# 子 crate Cargo.toml
[dependencies]
tokio = { workspace = true }
```

### MSRV

在 `Cargo.toml` 中声明最低支持的 Rust 版本：

```toml
[package]
rust-version = "1.75.0"
```

### 构建可复现

CI 和发布构建必须使用 `--locked` 标志：

```bash
cargo build --locked
cargo test --locked
```

---

## 5. 相关文档

- **Rust 编码规范**：[rust-conventions.md](./rust-conventions.md)
- **Rust 错误处理**：[rust-error-handling.md](./rust-error-handling.md)
