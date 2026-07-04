---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Rust Tokio 异步编程规范

> 避免 tokio 协作式调度下常见的任务饿死、消息丢失、死锁与取消残留。

## 1. Why（为什么）

tokio 采用**协作式调度**：worker 线程靠任务主动 `.await` 才能让出控制权。一旦 `spawn` 的任务里跑阻塞代码或长 CPU 循环不让出，整个 worker 被独占，其他任务全部饿死。

第二重心智负担是**取消语义**：`select!` 未选中的分支会被 drop，被丢弃的 Future 如果不是取消安全的，会留下半完成的 IO 状态，导致数据丢失。

## 2. 核心规则（HARD）

| # | 规则 | 违反后果 |
|---|------|----------|
| 1 | `spawn` 内禁止阻塞代码 → 用 `spawn_blocking` | worker 饿死 |
| 2 | `.await` 期间不持有锁 → 缩小作用域或换 `tokio::sync::Mutex` | 死锁 |
| 3 | `select!` 的 Future 必须取消安全 → 查文档确认 | 消息/数据丢失 |
| 4 | 多步操作考虑取消 → 用 `scopeguard` 或 `Drop` 守护 | 资源残留 |
| 5 | CPU 密集任务跑在 async 里 → `spawn_blocking` 或独立线程池 | 调度器阻塞 |

## 3. select! 踩坑指南

### 3.1 取消安全性（Cancellation Safety）

`select!` 未被选中的分支会被 drop，等同于取消 Future。**不是所有 Future 都能安全取消**。

| 操作 | 取消安全性 |
|------|------------|
| `mpsc::Receiver::recv()` | ✅ 安全 |
| `oneshot::Receiver` | ✅ 安全 |
| `tokio::time::sleep` / `timeout` | ✅ 安全 |
| `Notify::notified()` | ✅ 安全 |
| `AsyncReadExt::read` / `read_to_end` / `read_exact` | ❌ 不安全 |
| `AsyncWriteExt::write` | ❌ 不安全 |
| `SinkExt::send` | ❌ 不安全 |

❌ 反例（被取消时已读字节丢失）：

```rust
tokio::select! {
    _ = socket.read(&mut buf) => {
        handle_buf(&buf);
    }
    _ = tokio::time::sleep(Duration::from_secs(1)) => {
    }
}
```

✅ 正例（`recv()` 是取消安全的，可直接在 select! 中使用）：

```rust
tokio::select! {
    Some(msg) = rx.recv() => {
        handle(msg);
    }
    _ = tokio::time::sleep(Duration::from_secs(1)) => {
    }
}
```

完整列表见 [tokio cancellation safety 文档](https://docs.rs/tokio/latest/tokio/macro.select.html#cancellation-safety)。

### 3.2 分支公平性

`select!` 默认**随机**选择就绪分支，不保证声明顺序。

需要严格优先级时用 `biased;`：

```rust
loop {
    tokio::select! {
        biased;
        _ = high_priority() => {
        }
        _ = low_priority() => {
        }
    }
}
```

### 3.3 在 loop 中使用 select!

常见模式是循环处理多 channel：

```rust
loop {
    tokio::select! {
        Some(msg) = rx1.recv() => {
            handle(msg);
        }
        Some(msg) = rx2.recv() => {
            handle(msg);
        }
        else => {
            break;
        }
    }
}
```

`else` 分支**只在所有分支都返回 `None`**（即 channel 全部关闭）时触发。任意 channel 还活着，循环继续。

## 4. 调度工具速查

### 4.1 spawn_blocking（阻塞 / CPU 密集）

`spawn` 内出现阻塞 IO 或 CPU 密集循环时使用：

```rust
let result = tokio::task::spawn_blocking(move || {
    heavy_compute()
}).await.unwrap();
```

### 4.2 JoinSet（按完成顺序处理）

经验法则：需要 spawn 多个任务并**按完成顺序处理**，用 `JoinSet`，而不是手写 `Vec<JoinHandle>` 后顺序 await。

```rust
let mut set = tokio::task::JoinSet::new();
for item in items {
    set.spawn(handle_item(item));
}
while let Some(res) = set.join_next().await {
    let _ = res.unwrap();
}
```

### 4.3 yield_now（让出调度权）

`yield_now` 把当前任务**重新放回调度队列**，允许其他任务运行。

适用场景：

- 长循环没有 `.await`（纯 CPU 计算）
- 公平性要求高，避免单任务独占 worker
- 测试竞态条件（yield 时才会暴露的 race）

❌ 反例（纯 CPU 循环不让出）：

```rust
async fn cpu_heavy() {
    for i in 0..1_000_000 {
        compute(i);
    }
}
```

✅ 正例（定期让出）：

```rust
async fn cpu_heavy_fair() {
    for i in 0..1_000_000 {
        compute(i);
        if i % 10000 == 0 {
            tokio::task::yield_now().await;
        }
    }
}
```

✅ 更好的写法（直接交给阻塞线程池）：

```rust
async fn cpu_heavy_best() {
    tokio::task::spawn_blocking(move || {
        for i in 0..1_000_000 {
            compute(i);
        }
    }).await.unwrap();
}
```

## 5. 反模式清单

| 反模式 | 后果 | 正确做法 |
|--------|------|----------|
| `spawn` 内 `std::thread::sleep` 或同步 IO | worker 饿死 | `spawn_blocking` 或异步等价物 |
| `.await` 时持有 `std::sync::MutexGuard` | 死锁 | 缩小作用域或换 `tokio::sync::Mutex` |
| `select!` 内用 `AsyncReadExt::read` | 已读数据丢失 | 改用取消安全的封装或分离 IO |
| 多任务用 `Vec<JoinHandle>` + 顺序 await | 失败一个阻塞全部 | `JoinSet::join_next` |
| 长循环不 `.await` | 调度器阻塞 | `yield_now` 或 `spawn_blocking` |

## 6. 相关文档

- [rust-conventions.md](./rust-conventions.md)、[rust-error-handling.md](./rust-error-handling.md)、[rust-workflow-standards.md](./rust-workflow-standards.md)、[tdd-rust.md](./tdd-rust.md)
- 官方参考：[tokio select! cancellation safety](https://docs.rs/tokio/latest/tokio/macro.select.html#cancellation-safety)

---

- 维护人：Xu Chengzi　·　版本：v1.0.0　·　更新：2026-06-26　·　首次发布
