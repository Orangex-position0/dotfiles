---
paths:
  - "**/src/test/**"
  - "**/tests/**"
  - "**/__tests__/**"
  - "**/*{Test,IT,Spec}.{java,kt}"
  - "**/*_test.go"
  - "**/*.{test,spec}.{ts,tsx,js,jsx}"
  - "**/*.rs"
---

# Property-Based Testing 规范

> 语言无关的顶层 PBT 约束，适用于 Java / Rust / Go / TypeScript / JavaScript 项目。
> 通用测试规范见 [测试规范](./testing-standards.md)；TDD 流程见 [TDD 开发流程](./tdd-development-flow.md)。
> 本文只定义「何时必须用 PBT、用哪个框架、如何防止 AI 漂移」。

---

## 1. 核心定位

Property-Based Testing（PBT）是 example-based 测试的**补充**，不是替代：

- **example-based**：验证「具体业务结果」（下单返回订单号 123、登录返回特定 token）。
- **PBT**：验证「不变量」（任意输入排序后长度不变、编解码可往返、reducer 状态守恒）。

PBT 的价值在「输入空间巨大、靠人举例子必然漏边界」的场景。强行套用到不适合的场景，会逼迫 AI **伪造 generator**（只生成正常值），违反「禁止伪造实现」原则。

---

## 2. 分级强制决策清单（核心）

**判断顺序**：先判定被测对象属于哪一档，再决定是否使用 PBT。

### 2.1 强制档（必须使用，review 时缺失算缺陷）

被测对象满足以下**任一**条件时，必须至少写一条 PBT 性质，禁止只用参数化测试 / 表驱动测试替代：

| 类别 | 典型场景 | 推荐性质套路 |
|------|---------|------------|
| 数据变换 | 序列化/反序列化、JSON/Base64/URL 编解码、压缩、格式化 | 往返可逆 |
| 解析器 | URL / CSV / Markdown / 配置 / 协议解析 | 往返可逆 |
| 算法 | 排序、搜索、加密、哈希、数值计算 | 幂等性 / 守恒 |
| 状态机 | reducer、有限状态转换、协议状态机 | 状态守恒 / 后置条件 |
| 集合变换 | map / filter / reduce 组合、树形操作、深拷贝 | 长度守恒 / 元素集合不变 |

### 2.2 引导档（推荐使用，不强制）

- 复杂校验逻辑（金额、日期、手机号、表单规则）
- 工具函数（分页、去重、范围裁剪）
- 有「弱但正确」的参考实现可做对照时

### 2.3 禁止档（不得硬塞 PBT）

- 具体业务结果断言（固定输入 → 固定输出）
- UI 组件渲染、视觉、可访问性断言
- 副作用、IO、复杂异步时序
- 简单委托、getter/setter

> **判断不明确时**：默认走 example-based，并在 review 中讨论是否升级为 PBT。不要在拿不准时硬塞。

---

## 3. 框架选型（写死，禁止漂移）

| 语言 | 首选框架 | 坐标 / 安装 | 备选 | 禁用 |
|------|---------|------------|------|------|
| Java | **jqwik** | `net.jqwik:jqwik`（需 JUnit Platform / JUnit 5） | junit-quickcheck（仅 JUnit 4 项目） | — |
| Go | **rapid** | `go get pgregory.net/rapid` | gopter | `testing/quick`（**无 shrinking，禁止用于强制档**） |
| TypeScript / JS | **fast-check** | `npm i -D fast-check` | — | jsverify（已过时） |
| Rust | **proptest** | `proptest = "1"`（`[dev-dependencies]`） | quickcheck（仅简单场景且类型已实现 `Arbitrary`） | — |

> 坐标一旦在本项目采用，不得在同项目内混用备选框架。

---

## 4. 性质发现三套路

按投入产出比从高到低，优先尝试前者：

1. **往返可逆（Round-trip）**：`decode(encode(x)) == x`。适用于序列化、编解码、解析。几乎无脑可写，是 PBT 首选切入点。
2. **幂等性 / 守恒**：`sort(sort(x)) == sort(x)`；排序后长度 == 原长度；reducer 任意 action 序列后状态字段守恒。
3. **弱实现对照**：有显然正确但慢的参考实现 `naive(x)`，验证 `fast(x) == naive(x)`。适用于算法优化、重构。

---

## 5. 防漂移硬规则（最重要）

Code Review 与 AI 生成代码审查时，以下任一命中即视为缺陷：

1. **禁止用参数化测试堆砌替代强制档 PBT**——强制档场景下，`@ParameterizedTest` / `test.each` / 表驱动只能覆盖少数枚举值，不得作为不变量验证的替代品。
2. **禁止伪造 generator**——生成器只产出「正常值」（只正数、只非空集合、只 ASCII）视为伪造。必须使用框架的边界感知生成器，或显式声明前置条件。
3. **失败必须可复现**——PBT 用随机输入，失败时框架会打印 seed。CI 与本地必须能把 seed 写回配置重现同一反例；不得丢弃 seed 让失败不可复现。
4. **禁止把性质写成 example 的伪装**——`property(x => expect(f(x)).toBe(预先算好的固定值))` 不是性质，说明没找到不变量，应改写或退回 example-based。
5. **禁止缩生成空间或降运行次数让测试变绿**——这是 AI 作弊，等价于删除失败测试。发现失败先定位根因。
6. **复杂场景仍需手写边界**——PBT 覆盖随机采样，但并发竞争、时区切换、特殊编码、极值等场景仍需开发者手写针对性测试。

---

## 6. 各语言最小示例

> 统一以「排序后长度不变」作为最简性质。

### 6.1 Java —— jqwik

```java
import java.util.*;
import net.jqwik.api.*;

class ListProperties {

    // @Property 标记性质测试，jqwik 自动重复运行多次
    // @ForAll 让 jqwik 自动为 List<Integer> 生成随机值
    @Property
    boolean sortingKeepsLength(@ForAll List<Integer> xs) {
        List<Integer> sorted = new ArrayList<>(xs);
        Collections.sort(sorted);
        // 排序只是重排，长度必然不变
        return sorted.size() == xs.size();
    }
}
```

### 6.2 Go —— rapid

```go
package list_test

import (
	"sort"
	"testing"

	"pgregory.net/rapid"
)

func TestSortingKeepsLength(t *testing.T) {
	// rapid.Check 是入口，回调接收 *rapid.T
	rapid.Check(t, func(t *rapid.T) {
		// 生成任意 int 切片，标签 "xs" 用于失败时定位
		xs := rapid.SliceOf(rapid.Int()).Draw(t, "xs")
		originalLen := len(xs)
		sort.Ints(xs)
		// 性质：排序不改变长度
		if len(xs) != originalLen {
			t.Fatalf("length changed after sort")
		}
	})
}
```

### 6.3 TypeScript / JavaScript —— fast-check

```typescript
import fc from 'fast-check';

test('排序后长度不变', () => {
  fc.assert(
    // fc.array(fc.integer()) 是生成器，回调内写性质
    fc.property(fc.array(fc.integer()), (xs) => {
      const sorted = [...xs].sort((a, b) => a - b);
      // 性质：排序前后长度相等
      return sorted.length === xs.length;
    })
  );
});
```

### 6.4 Rust —— proptest

> Rust 的 PBT 详细实践（含 shrinking、compile test）见 [Rust TDD 规范 §3](./tdd-rust.md)。

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn sorting_keeps_length(
        // 显式 Strategy：任意 i32 组成的、长度 0..=100 的 Vec
        ref xs in prop::collection::vec(prop::num::i32::ANY, 0..=100)
    ) {
        let mut sorted = xs.clone();
        sorted.sort();
        // prop_assert_eq! 失败时返回测试失败而非 panic，
        // 并自动触发 shrinking 报告最小反例
        prop_assert_eq!(sorted.len(), xs.len());
    }
}
```

---

## 7. 反模式清单

| 反模式 | 后果 | 正确做法 |
|--------|------|---------|
| 强制档只用参数化测试 | 漏边界，与不写无异 | 必须补 PBT 性质 |
| 生成器只产出正常值 | 测不到边界，伪造实现 | 用边界感知生成器 + 前置条件 |
| 丢弃 seed | CI 偶发失败无法复现 | 记录 seed 写回配置 |
| 性质写成 `result == 固定值` | 不是性质，是 example 伪装 | 重写为真正的不变量 |
| 缩生成空间让测试通过 | AI 作弊，掩盖缺陷 | 定位根因 |
| 对 UI 渲染硬塞 PBT | 维护痛、回报低 | 退回 example-based + 视觉回归 |
| 同项目混用多个 PBT 框架 | 认知负担、风格不一 | 项目内统一一个框架 |

---

## 8. 相关文档

- **通用测试规范**：[testing-standards.md](./testing-standards.md) —— 测试分层、命名、AAA、Mock、参数化
- **TDD 开发流程**：[tdd-development-flow.md](./tdd-development-flow.md) —— Red-Green-Refactor 节奏与场景策略
- **Rust TDD**：[tdd-rust.md](./tdd-rust.md) —— Rust 特有的 PBT 与 Compile Test 实践
- **Spring Boot 测试**：[spring-boot-testing-standards.md](./spring-boot-testing-standards.md) —— Spring 切片测试策略
