---
paths:
  - "**/src/test/**"
  - "**/tests/**"
  - "**/*{Test,Spec}.*"
---

# 通用测试规范 (Language-Agnostic Testing Standards)

> 语言无关的顶层测试规范，适用于 Java / Rust / Go / Python / JavaScript 等所有项目。
> 框架/语言特定的测试实践见对应的细化文档（如 [Spring Boot 测试规范](./spring-boot-testing-standards.md)）。

---

## 1. 测试分层

建立清晰的测试分层意识，每层有明确的职责边界和性能要求：

| 层级 | 职责 | 执行时间 | 说明 |
|------|------|----------|------|
| 单元测试 (Unit) | 聚焦单个类/函数的独立行为逻辑 | <= 10ms | 不依赖外部资源（数据库、网络、文件系统） |
| 集成测试 (Integration) | 验证多个组件的协作 | <= 100ms | 涉及真实的外部依赖（数据库、消息队列等） |
| 端到端测试 (E2E) | 验证完整业务链路 | 无硬性限制 | 从用户视角模拟完整操作路径 |

---

## 2. 测试命名规范

### 2.1 单元测试

- **测试函数**: `[方法名]_[场景]_[预期结果]`
- **测试类**: 以 `Test` 结尾

### 2.2 集成测试

- **测试函数**: `[功能]_[组件交互]_[验证点]`
- **测试类**: 以 `IT` 结尾（Integration Test）

### 2.3 端到端测试

- **测试函数**: `[用户故事]_[操作路径]_[验证结果]`
- **测试类**: 以 `E2ETest` 结尾

---

## 3. 测试代码结构

### 3.1 AAA 模式

单元测试函数遵循 **Arrange-Act-Assert** 结构：

- **Arrange**：准备测试数据和前置条件
- **Act**：执行被测逻辑
- **Assert**：验证结果是否符合预期

各阶段之间用空行分隔，保持视觉清晰。

---

## 4. 单元测试规范

### 4.1 隔离性

- 测试用例之间完全独立，无执行顺序依赖
- 每个测试负责创建和清理自己的数据
- 禁止测试之间共享可变状态

### 4.2 单一职责

- 每个测试函数只验证一个行为点
- 一个测试失败不应导致对其他行为的误判

### 4.3 边界与异常测试

- 专注业务主链路的测试覆盖
- 辅助模块（工具类、通用组件）覆盖率可适当放宽
- 合理分配边界测试与异常测试的权重，优先保障核心业务路径的正确性

---

## 5. 数据驱动测试

利用参数化测试机制，高效覆盖边界值和等价类：

| 语言/框架 | 参数化测试机制 |
|-----------|---------------|
| Java (JUnit 5) | `@ParameterizedTest` + `@ValueSource` / `@CsvSource` |
| Python (pytest) | `@pytest.mark.parametrize` |
| Rust | `rstest` 或手写循环 + 子测试 |
| Go | `t.Run` 子测试 + 表驱动 |
| JavaScript (Jest) | `test.each` / `describe.each` |

### 5.1 适用场景

- 边界值测试（空值、零值、最大值、最小值）
- 等价类划分（合法输入集合的不同代表值）
- 同一逻辑的多组输入-输出对

### 5.2 原则

- 参数化测试的每个用例应该是独立的、可单独理解的
- 测试数据应自解释（命名参数或注释说明每组数据的含义）

### 5.3 参数化测试 ≠ Property-Based Testing

参数化测试仍属 example-based：每个用例是固定的「输入 → 期望输出」，覆盖率受限于人工枚举。当被测对象是数据变换、解析器、算法、状态机等「输入空间巨大」的场景时，必须改用 Property-Based Testing 验证不变量。详见 [Property-Based Testing 规范](./property-based-testing.md)。

---

## 6. Mock 使用规范

### 6.1 基本原则

- **只 Mock 当前测试对象的外部依赖**
- 不 Mock 被测对象（SUT）本身
- 不 Mock 标准库的基础类型（集合、字符串、Optional 等）
- 不 Mock 简单的 DTO / POJO / Value Object
- 优先使用真实对象，必要时再使用 Mock

### 6.2 适合 Mock 的对象

- 数据访问层（Repository / DAO / Mapper）
- RPC Client / HTTP Client
- 消息队列 Producer
- 第三方服务 SDK
- 时间、随机数等外部环境依赖

### 6.3 不适合 Mock 的对象

- Domain Model（领域模型）
- DTO / Value Object
- 集合类型
- 配置对象
- 简单工具类（纯函数，无副作用）

### 6.4 分层 Mock 边界

| 测试层级 | Mock 策略 |
|---------|----------|
| 单元测试 | 允许使用 Mock |
| 集成测试 | 禁止 Mock 核心业务组件 |
| 端到端测试 | 禁止 Mock |

---

## 7. 覆盖率策略

- **核心业务路径**：必须充分覆盖，确保主链路正确性
- **辅助模块**：覆盖率可适当放宽（如 50%），不必追求形式上的 100%
- **不写无意义的测试**：不要为了数字而测试 getter/setter 或简单委托
- 覆盖率是手段而非目的，测试的价值在于发现缺陷和保障重构安全

---

## 8. 相关文档

- **TDD 开发流程**：详见 [tdd-development-flow.md](./tdd-development-flow.md)，定义了 Red-Green-Refactor 的开发节奏
- **Property-Based Testing 规范**：详见 [property-based-testing.md](./property-based-testing.md)，分级强制的 PBT 适用场景、框架选型与防漂移硬规则
- **性能基准测试规范**：详见 [performance-benchmark.md](./performance-benchmark.md)，分级强制的 benchmark 适用场景、框架选型、回归判定与防漂移硬规则
- **Rust TDD 详细规范**：详见 [tdd-rust.md](./tdd-rust.md)，Rust 特有的 `todo!()` 占位法、Property/Compile Test、AI 陷阱清单
- **Spring Boot 测试规范**：详见 [spring-boot-testing-standards.md](./spring-boot-testing-standards.md)，Spring Boot 项目的测试注解、切片策略和 Testcontainers 实践
