---
description: "Rust coding conventions - copy to project .claude/rules/ when working on a Rust project"
alwaysApply: false
---

# Rust 编码规范

## 模块组织

使用 Rust 2024 Edition 推荐的模块组织方式：

- 每个模块使用**同名目录**作为入口，入口文件为目录下的 `mod.rs`（旧式）或与目录**同名的 `.rs` 文件**（Rust 2024 Edition 推荐）
- 子模块放置在同名目录中

### 目录结构示例

```
src/
├── main.rs
├── network/
│   ├── mod.rs          # 模块入口，也可命名为 network.rs（放在 src/ 下）
│   ├── client.rs
│   └── server.rs
└── storage/
    ├── mod.rs
    ├── cache.rs
    └── persist.rs
```

对应的模块声明：

```rust
// src/main.rs
mod network;
mod storage;
```

### 2024 Edition 变更说明

Rust 2024 Edition 将 `foo/mod.rs` 形式标记为旧式，推荐将模块入口文件命名为 `foo.rs` 并放在父目录中：

```
src/
├── main.rs
├── network.rs          # 模块入口（替代 network/mod.rs）
├── network/
│   ├── client.rs
│   └── server.rs
└── storage.rs          # 模块入口（替代 storage/mod.rs）
    └── storage/
        ├── cache.rs
        └── persist.rs
```

> **注意**：对于已有项目，应遵循项目既有的模块组织方式，保持一致性。仅在新建模块时采用 2024 Edition 推荐方式。
