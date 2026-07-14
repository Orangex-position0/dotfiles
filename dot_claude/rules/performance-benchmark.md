---
paths:
  - "**/benches/**"
  - "**/*Bench*.{java,kt}"
  - "**/*_bench_test.go"
  - "**/*.{bench,bench}.{ts,tsx,js,jsx}"
  - "**/benchmark/**"
---

# 性能基准测试规范 (Performance Benchmark Standards)

> 语言无关的性能基准测试约束，适用于 Java / Rust / Go / TypeScript / JavaScript 项目。
> 通用测试规范见 [测试规范](./testing-standards.md)；TDD 流程见 [TDD 开发流程](./tdd-development-flow.md)。
> 本文只定义「何时必须写 benchmark、用哪个框架、如何判定性能回归、如何防止 AI 作弊」。

---

## 1. 核心定位

性能基准测试（Benchmark）测量代码的**性能**，与验证**正确性**的单元测试是两类东西：

- **Unit / Property Test**：验证行为是否正确（Correctness）
- **Benchmark**：测量执行时间 / 吞吐 / 内存 / 指令数（Performance）

三条不可逾越的定位红线：

1. **先正确，再追求快**——被测代码必须先有 correctness 测试覆盖，再写 benchmark。在「还没跑对」的代码上测性能是浪费时间，也违反 [TDD 开发流程](./tdd-development-flow.md)。
2. **Benchmark 是统计判断，不是单次计时**——单次 `Instant::now()` 测量被噪声淹没，必须用统计框架多次采样。
3. **微基准 ≠ 压测 / 负载测试**——本文只约束微基准（micro-benchmark，测单个函数 / 算法）。系统级吞吐、P99 延迟、并发压力测试不在本文范围。

---

## 2. 分级强制决策清单（核心）

**判断顺序**：先判定被测对象属于哪一档，再决定是否写 benchmark。

### 2.1 强制档（必须写，review 时缺失算缺陷）

被测对象满足以下**任一**条件时，必须配备 benchmark：

| 类别 | 典型场景 | 判定依据 |
|------|---------|---------|
| 性能敏感库的公开 API | 解析器、序列化、编解码、缓存、哈希、排序算法 | 这些 API 的性能就是其契约的一部分 |
| 有 SLA / SLO 承诺的路径 | 接口 P99 延迟、批处理吞吐 | 承诺必须有持续验证 |
| 声称「更快」的重构 / 优化 | 用新算法替换旧实现、声称减少分配 | **必须用 benchmark 证明，禁止拍脑袋或凭直觉** |

### 2.2 引导档（推荐，不强制）

- 怀疑有瓶颈但尚未定性，需要数据支撑决策
- 选型对比（`Vec` vs `LinkedList`、两种数据结构、两种算法）
- 评估优化方向的投入产出比

### 2.3 禁止档（不得硬塞 benchmark）

- **IO / 网络 / 数据库主导的逻辑**——外部延迟噪声远大于代码本身，微基准无意义，改用集成压测
- **一次性脚本、CLI 工具、启动流程**——单次执行的耗时与微基准无关
- **还没确定正确性的代码**——先写 correctness 测试，性能测量排在其后
- **没有明确优化目标的「感觉能更快」**——无目标、无 baseline 的 benchmark 只产出噪音

> **判断不明确时**：默认不写，并在 review 中讨论是否升级为引导档。不要在拿不准时硬塞。

---

## 3. 框架选型（写死，禁止漂移）

| 语言 | 首选框架 | 坐标 / 安装 | 备选 | 禁用 |
|------|---------|------------|------|------|
| Rust | **Criterion** | `criterion = "0.8"`（`[dev-dependencies]`） | iai-callgrind（CI 无噪声场景，`iai-callgrind = "0.14"`） | libtest `#[bench]`（**Nightly only，已基本废弃**） |
| Java / Kotlin | **JMH** | `org.openjdk.jmh:jmh-core` + `jmh-generator-annprocess` | — | 手写 `System.nanoTime()` 循环 |
| Go | **`testing.B`** | 标准库，零依赖 | — | 第三方框架（标准库已足够） |
| TypeScript / JS | **Vitest `bench`** | `vitest`（`devDependencies`，Vite 项目内置） | tinybench（轻量）、benchmark.js（**维护停滞，新项目不推荐**） | 手写 `performance.now()` 循环 |

> 坐标一旦在本项目采用，**不得在同项目内混用备选框架**。版本号以最新稳定版为准（本文标注的是撰写时的大版本）。

---

## 4. 性能回归判定套路

判定「是否发生性能回归」必须基于**统计显著性**，禁止凭「中位数看着变低了」下结论：

1. **必须有 baseline**——benchmark 的意义在于「与基线对比」。无 baseline 的单次结果无法判断回归，等价于没有 benchmark。
2. **看统计显著性指标，不看单点**：
   - Criterion 输出的 `change`（与上次基线的变化幅度）+ `p`（P-value，统计学显著性）
   - **`p > 0.05` 时，即使中位数有差异，结论也是 `No change`**——差异在噪声范围内，不得报为回归
   - JMH 的置信区间（Confidence Interval）重叠即视为无显著差异
3. **控制噪声源**——关闭其他占用 CPU 的进程、禁用 CPU 频率缩放、固定机器。噪声越大，P-value 越不可信。
4. **回归门禁必须跑在稳定环境**——见 §5 第 4 条。

| 框架 | 回归判定信号 |
|------|-------------|
| Criterion | `change` + `p`（P-value），`p > 0.05` = No change |
| JMH | 置信区间与基线是否重叠 |
| Go `testing.B` | `benchstat` 工具做差异显著性比对 |
| Vitest bench | 本地相对比较；CI 回归门禁建议接 Codspeed 等托管基线服务 |

---

## 5. 防漂移硬规则（最重要）

Code Review 与 AI 生成代码审查时，以下任一命中即视为**作弊或缺陷**（与 [TDD 开发流程 §5 防 AI 作弊](./tdd-development-flow.md) 同源）：

1. **禁止手写单次计时**——`Instant::now()` / `System.nanoTime()` / `performance.now()` 包一对 timestamp 直接相减，是噪声驱动的伪 benchmark。必须用统计框架（Criterion / JMH / `testing.B` / Vitest bench）的采样机制。
2. **禁止缩小输入规模让 benchmark「变绿」**——优化失败后把测试数据量从 10^6 降到 10^3 让差异消失，等价于删除失败测试。发现回归先定位根因，禁止调参掩盖。
3. **禁止在 debug 模式下得出性能结论**——`cargo bench` 默认 release，但 CI 命令必须**显式**确保 release（`--release` / 对应 profile）。debug 构建的结论毫无意义。
4. **禁止在共享 / 嘈杂的 CI runner 上做回归门禁**——共享 runner 的 CPU 抖动会让 P-value 完全不可信。要么用专用固定机器，要么改用**指令计数**方案（Rust 用 iai-callgrind，基于 Valgrind Callgrind，不受机器噪声影响）。
5. **必须提交 / 持久化 baseline**——Criterion 的基线产物、JMH 的历史 JSON、`benchstat` 的对照样本，必须提交或在 CI 中留存。丢弃 baseline 后谈「change」是凭空捏造。
6. **禁止在未确定正确性的代码上 benchmark**——先让 correctness / property 测试全绿，再测性能。顺序不可颠倒。

---

## 6. 各语言最小示例

> 统一以「向集合追加一个元素」作为最简基准。

### 6.1 Rust —— Criterion

```rust
use criterion::{criterion_group, criterion_main, Criterion};

fn bench_vec_push(c: &mut Criterion) {
    // bench_function 定义一个基准测试
    // 闭包内的 b.iter 由 Criterion 自动决定迭代次数并做统计采样
    c.bench_function("Vec::push", |b| {
        b.iter(|| {
            let mut v = Vec::new();
            v.push(1);
        });
    });
}

criterion_group!(benches, bench_vec_push);
criterion_main!(benches);
```

运行：`cargo bench`（默认 release）。回归判定看输出的 `change` 与 `p`。

### 6.2 Java / Kotlin —— JMH

```java
import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;
import java.util.ArrayList;

@State(Scope.Thread)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
public class ArrayListAddBench {

    private ArrayList<Integer> list;

    @Setup
    public void setup() {
        list = new ArrayList<>();
    }

    // @Benchmark 标记被测方法，JMH 负责预热、迭代、统计
    @Benchmark
    public void add() {
        list.add(1);
    }
}
```

运行：`mvn package && java -jar target/benchmarks.jar`。JMH 自动处理 JVM 预热与死码消除（Dead Code Elimination）。

### 6.3 Go —— `testing.B`

```go
package list_test

import "testing"

func BenchmarkSliceAppend(b *testing.B) {
    // b.ResetTimer 排除初始化耗时，只测量循环体
    list := make([]int, 0)
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        list = append(list, 1)
    }
}
```

运行：`go test -bench=. -benchmem`。回归比对用 `benchstat old.txt new.txt`。

### 6.4 TypeScript / JavaScript —— Vitest bench

```typescript
import { bench, describe } from 'vitest';

describe('Array.push', () => {
    // bench 由 Vitest 自动多次运行并统计，无需手写计时
    bench('push single element', () => {
        const arr: number[] = [];
        arr.push(1);
    });
});
```

运行：`vitest bench`。Vite 项目原生支持，无需额外配置。

---

## 7. 反模式清单

| 反模式 | 后果 | 正确做法 |
|--------|------|---------|
| 手写 `nanoTime()` / `now()` 单次计时 | 噪声淹没信号，结论不可信 | 用统计框架的采样机制 |
| 缩小输入规模掩盖回归 | 等同删除失败测试，掩盖性能缺陷 | 定位根因，禁止调参作弊 |
| debug 模式跑结论 | 结论毫无意义 | 显式 release 构建 |
| 共享 CI runner 上做回归门禁 | P-value 失真，随机红绿 | 专用机器或 iai-callgrind 指令计数 |
| 不提交 baseline | 「change」无参照，凭空判断 | 持久化基线产物 |
| 对 IO / 网络逻辑写微基准 | 测的是外部延迟不是代码 | 改用集成压测 |
| 未过 correctness 测试就 benchmark | 测了「跑得快的错误」 | 先正确再性能 |
| 用 `#[bench]`（libtest） | 强制 Nightly，已废弃 | 用 Criterion |
| 同项目混用多个 bench 框架 | 风格不一、认知负担 | 项目内统一一个框架 |

---

## 8. 相关文档

- **通用测试规范**：[testing-standards.md](./testing-standards.md) —— 测试分层、命名、AAA、Mock、参数化
- **TDD 开发流程**：[tdd-development-flow.md](./tdd-development-flow.md) —— Red-Green-Refactor 与防 AI 作弊原则（本文 §5 与之同源）
- **Property-Based Testing**：[property-based-testing.md](./property-based-testing.md) —— 并列的测试专题，验证不变量
- **Rust TDD**：[tdd-rust.md](./tdd-rust.md) —— Rust 测试分层（含本文对应的 Performance 层）

---

## 文档元数据

- 规范名称：性能基准测试规范
- 当前版本：v1.0.0
- 最新更新：2026-07-14
- 维护负责人：Xu Chengzi

| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v1.0.0 | 2026-07-14 | Xu Chengzi | 首次发布。基于 Criterion 实践提炼跨语言基准测试约束。 |
