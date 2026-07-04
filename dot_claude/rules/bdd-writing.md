# 行为驱动开发（BDD）编写规范

> 凡是涉及 BDD 场景编写、测试命名、行为规约的代码会话，必须遵守本规范。
> 基于 Dan North 2006 提案。BDD 是 TDD 的前置思维框架，不是替代品。

## 核心定位

- BDD 关注**系统行为**，不是测试用例
- 测试名是描述行为的句子
- BDD 场景是**可执行契约**，连接：业务描述 → 测试代码 → 实现代码

## 测试命名：Should Style

测试方法名以 `should` 开头，或使用描述行为的完整句子：

- ✅ `shouldRejectDuplicateOrders()`
- ✅ `rejectsDuplicateOrders()`
- ❌ `testOrderLogic()`、`test1()`

### 命名压力驱动设计拆分

如果测试方法名过长（如 `shouldCalculateAgeFromBirthdayWhenAgeNotProvided`），说明行为职责放错了类——应拆分到独立类（如 `AgeCalculator`）。

## 两层句式模板

### Story（故事层）

```
As a <角色>
I want <功能>
so that <价值>
```

每个特性必须先写 Story，再写 Scenario。"so that" 能立刻识别伪需求。

### Scenario（场景层）

```
Given <初始上下文>
When <事件发生>
Then <期望结果>
```

- `And` 用于串联多个 Given 或多个 Then
- 优先使用 **Gherkin 语法**（Cucumber / Behave / SpecFlow 可直接执行）
- 一个 Scenario 只测**一个行为**

## 硬性约束

- **Then 描述业务结果，不描述方法调用**
  - ✅ "the account should be debited"
  - ❌ "accountService.debit() should be called"
- **一个 Scenario 一个行为**
- **只为业务行为写场景**，不为 setter/getter 写
- **每个特性先写 Story，再写 Scenario**，不跳过故事层
- **Gherkin 步骤必须重用**，抽取共用步骤到 steps 文件

## BDD 与 TDD 的关系

BDD 是 TDD 的**前置思维框架**，不是替代品。实际流程：

BDD 场景（Given/When/Then）→ 翻译为代码层测试 → TDD 循环写实现

## BDD 与 DDD 的接合

- 场景使用业务领域的 **ubiquitous language**（统一语言）
- 测试代码中的名词与领域模型实体名一致
- "业务描述 → 测试代码 → 实现代码"形成无翻译损失的语言链

## 文件存放

- 命名：`feature-name.feature`（Gherkin）
- 存放：`docs/features/` 或 `tests/features/` 目录

## 反模式

| 反模式 | 后果 | 修正 |
|--------|------|------|
| Then 调用某方法 | 业务不可读，失去 ubiquitous language | Then 描述业务结果 |
| 一个 Scenario 测多个行为 | 失败时无法定位 | 一个行为一个 Scenario |
| 为每个 setter/getter 写场景 | 噪音淹没关键行为 | 只为业务行为写 |
| 跳过故事层直接写场景 | 失去"价值"上下文 | 先 Story 后 Scenario |
| Gherkin 步骤不重用 | 步骤爆炸，维护成本高 | 抽取共用步骤到 steps 文件 |

## 最小模板

### Gherkin 示例

```gherkin
Feature: <功能名称>

  Scenario: <具体行为描述>

    Given <初始上下文>
    And <补充上下文>
    When <事件发生>
    Then <业务结果>
    And <补充结果>
```

### 代码层示例（Java）

```java
class CustomerWithdrawalTest {

    @Test
    void shouldDebitAccountWhenWithdrawalIsRequested() {
        // Given
        Account account = new Account(100);

        // When
        account.withdraw(30);

        // Then
        assertThat(account.getBalance()).isEqualTo(70);
    }

    @Test
    void shouldRejectWithdrawalWhenAccountIsOverdrawn() {
        // Given
        Account account = new Account(-50);

        // When
        WithdrawalResult result = account.withdraw(20);

        // Then
        assertThat(result.isRejected()).isTrue();
    }
}
```

---

## 文档元数据

- 规范名称：行为驱动开发编写规范
- 当前版本：v1.0.0
- 最新更新：2026-07-04
- 维护负责人：Xu Chengzi
- 延伸阅读：ADR/PRD/BDD 完整指南见 `test1-domain-guide.md`
