# 日期与时间处理规范 (Date & Time Handling Rules)

## 目的

防止因月份边界、闰年、时区、夏令时（DST）以及 SQL 日期过滤导致的常见 Bug。
凡是涉及日期、时间、时间戳、定时调度、API 传输或 SQL 编写/审查的代码，必须严格执行本规范。

---

## 核心规则 (ALWAYS)

### 1. 必须使用标准日期/时间库

严禁手动计算日历或编写时间加减逻辑，必须使用语言原生或主流的标准库：

- **Java**: `java.time` (JSR-310)
- **Rust**: `chrono` 或 `time`
- **Go**: `time`
- **Python**: `datetime`, `dateutil`
- **JavaScript**: `date-fns`, `dayjs`

### 2. 使用正确的日期类型 (Proper Date Types)

根据业务场景选择最精准的类型，**严禁使用 String 存储或传输日期**（API 序列化除外）：

- **生日/不含时区的日期**: `LocalDate`
- **系统绝对时间戳**: `Instant`
- **含时区的完整时间**: `ZonedDateTime` 或 `OffsetDateTime`
- **纯时间（如营业时间）**: `LocalTime`
- **注意**: 除非故意忽略时区逻辑，否则禁止滥用 `LocalDateTime`。

### 3. 系统时间戳一律使用 UTC

所有系统自动生成的审计时间（如创建时间 `created_at`、更新时间 `updated_at`、日志时间等）在数据库中必须以 **UTC** 或 **Timestamp** 类型存储。如果业务逻辑强依赖本地时间语义，应单独字段显式存储时区信息。

### 4. API 交互统一使用 ISO-8601 标准格式

前后端交互、三方对接时，禁止使用自定义的日期字符串格式（如 `yyyy/MM/dd`）。统一使用标准格式：

- `2026-06-03T15:30:00Z` (UTC 格式)
- `2026-06-03T15:30:00+08:00` (带时区偏移格式)
- _注：若国内团队约定使用 Unix 时间戳，必须在注释或 Schema 中明确单位是秒 (Seconds) 还是毫秒 (Milliseconds)。_

### 5. 必须使用时间库的“月份算术 API”

- **正确**: `date.plusMonths(1)` 或 `date + relativedelta(months=1)`
- **错误**: `date.plusDays(30)` 或 `date + timedelta(days=30)`（严禁假设一个月永远是 30 天）

### 6. 时间范围查询必须使用“左闭右开区间” (Half-Open Intervals)

处理时间范围时，禁止使用 `BETWEEN ... AND ...`，防止漏掉边界处的毫秒级数据。

- **正确**: `created_at >= :start AND created_at < :end`
- **错误**: `created_at BETWEEN :start AND :end`

---

## SQL 编写规范 (SQL Rules)

### 1. 月度数据查询

查询单月数据时，必须构造下一个月的第一天作为开区间边界：

- **正确**: `created_at >= '2026-01-01' AND created_at < '2026-02-01'`
- **错误**: 假设当前月有 30 天或 31 天。

### 2. 保护索引可用性 (Preserve Indexes)

严禁在外部传入的过滤条件中对数据库索引列使用时间函数，这会导致索引失效（无法进行 Sargable 优化）：

- **正确**: `created_at >= ? AND created_at < ?`
- **错误**: `DATE(created_at) = ?`、`YEAR(created_at) = ?` 或 `MONTH(created_at) = ?`

### 3. 日期分组统计 (Date Grouping)

按天/按月分组时，必须使用数据库原生的时间截断函数，禁止使用字符串截取：

- **PostgreSQL**: `DATE_TRUNC`
- **MySQL**: `DATE_FORMAT`
- **SQL Server**: `DATEPART`
- **错误示例**: `GROUP BY SUBSTRING(created_at, 1, 7)`

---

## 快速参考 (Quick Reference)

常见场景的错误 vs 正确做法对照表：

| 场景 | ❌ 错误做法 | ✅ 正确做法 | 说明 |
|------|------------|------------|------|
| 月度查询 | `+ INTERVAL 30 DAY` | `+ INTERVAL 1 MONTH` | 不同月份天数不同 |
| 时间范围 | `BETWEEN start AND end` | `>= start AND < end` | 避免边界重复计算 |
| 月份计算 | `plusDays(30)` / `timedelta(days=30)` | `plusMonths(1)` / `relativedelta(months=1)` | 使用月份算术 API |
| 日期分组 | `GROUP BY SUBSTRING(date, 1, 7)` | `GROUP BY DATE_TRUNC('month', date)` | 使用数据库原生函数 |
| 时区指定 | `ZoneId.systemDefault()` | `ZoneId.of("Asia/Shanghai")` | 显式指定时区 |
| 索引列过滤 | `DATE(created_at) = ?` | `created_at >= ? AND created_at < ?` | 保护索引可用性 |
| API 日期格式 | `"yyyy/MM/dd"` | `"2026-06-03T15:30:00+08:00"` | ISO-8601 标准 |

---

## 时区规范 (Timezone Rules)

- **显式指定**: 生成的代码必须清晰表明使用的是 UTC、业务特定时区还是用户本地时区，禁止依赖服务器默认时区 (`ZoneId.systemDefault()`)。
- **时区转换时机**: 时区转换应仅发生在 **API 接收/输出层** 或 **前端展示层**。禁止在数据库 SQL 索引条件中进行复杂的时区函数转换。

---

## 可测试性与依赖注入 (Dependency Injection)

为了确保单元测试中可以 Mock 时间（模拟月末、闰年、特殊时间点），**严禁在业务逻辑内部直接调用无参的当前时间函数**：

- **错误**: `Instant.now()`, `LocalDate.now()`
- **正确**: 注入 `Clock` 对象，使用 `Instant.now(clock)` 或 `LocalDate.now(clock)`。

---

## 绝对禁止 (NEVER)

1. 严禁假设一个月有 30 天或平年二月有 28 天。
2. 严禁在已有标准库支持的情况下，手动编写代码计算闰年。
3. 严禁在代码中直接硬编码时区偏移量（如固定写死 `+08:00`），应使用时区 ID（如 `Asia/Shanghai`）。
4. 严禁通过纯字符串拼接（String Concatenation）的方式去构造日期对象。

---

## 代码审查清单 (Code Review Checklist)

请在涉及时间修改的代码 Review 中逐一核对：

1. 时区是否正确且显式指定？
2. 是否选用了最匹配业务语义的时间类型？
3. 该段逻辑在**闰年（如 2024-02-29）**和**月末（如 01-31 加一个月）**能否正常运行？
4. 跨年、跨月计算边界是否安全？
5. SQL 条件是否破坏了 `created_at` 等字段的索引？
6. 时间范围是否全部采用了 `左闭右开` 区间？
7. 是否编写了针对特殊时间节点（月末、年尾、夏令时切换日）的单元测试？




## 关键术语 (Glossary)

| 中文术语 | 英文术语 | 说明 |
|---------|---------|------|
| 左闭右开区间 | Half-Open Interval | 时间范围的标准表示法：`[start, end)`，包含起点不包含终点 |
| 索引可优化 | Sargable | Search ARGument ABLE，指 WHERE 条件能够使用索引 |
| 月份算术 | Month Arithmetic | 基于月份而非天数的日期计算，自动处理月末/闰年 |
| UTC | Coordinated Universal Time | 协调世界时，无时区偏移的绝对时间标准 |
| ISO-8601 | ISO-8601 | 国际标准日期时间格式，如 `2026-06-03T15:30:00+08:00` |
| DST | Daylight Saving Time | 夏令时，部分地区每年调整时钟导致时间跳跃 |
| Epoch Time | Unix Timestamp | 从 1970-01-01 00:00:00 UTC 起算的秒数/毫秒数 |
| Clock 依赖注入 | Clock Dependency Injection | 注入时间提供者而非直接调用系统时间，便于测试 |

---

## 常见问题 (FAQ)

### Q1: 为什么不能用 `BETWEEN` 查询时间范围？

**A**: `BETWEEN` 是**闭区间** `[start, end]`，包含两端的边界值。

对于时间戳类型（精确到毫秒/微秒），这会导致：
- 边界数据被**重复计算**（如 `2026-01-31 23:59:59.999` 同时属于两个范围）
- 或被**遗漏**（边界条件不一致时）

**正确做法**：使用**左闭右开区间** `[start, end)`
```sql
-- ✅ 正确
WHERE created_at >= '2026-01-01' AND created_at < '2026-02-01'
```

---

### Q2: 什么时候可以用 `LocalDateTime`？什么时候必须用 `ZonedDateTime`？

**A**:

| 类型 | 适用场景 | 示例 |
|------|---------|------|
| `LocalDateTime` | **不含时区语义**的业务时间 | 营业时间 9:00-18:00、定时任务时间 |
| `ZonedDateTime` / `OffsetDateTime` | **跨时区**或需要**时区转换**的场景 | 航班起飞时间、国际会议时间 |
| `Instant` | 系统绝对时间戳 | 审计时间、日志时间、数据库存储 |

**注意**：除非你明确知道自己在做什么，否则优先使用 `Instant`（存储）和 `ZonedDateTime`（展示）。

---

### Q3: SQL 中 `DATE(created_at) = ?` 为什么会破坏索引？

**A**: 在索引列 `created_at` 上使用函数 `DATE()` 会导致数据库**无法直接使用索引**，必须进行全表扫描。

**原因**：数据库索引存储的是原始 `created_at` 值，函数转换后的值不在索引中。

**正确做法**：使用范围查询
```sql
-- ❌ 索引失效
WHERE DATE(created_at) = '2026-06-03'

-- ✅ 索引有效
WHERE created_at >= '2026-06-03' AND created_at < '2026-06-04'
```

---

### Q4: 如何在单元测试中 Mock 当前时间？

**A**: 使用 **Clock 依赖注入**，而非直接调用 `Instant.now()`。

**Java 示例**：
```java
// 业务逻辑
public class OrderService {
    private final Clock clock;

    public OrderService(Clock clock) {
        this.clock = clock;
    }

    public Order createOrder() {
        Order order = new Order();
        order.setCreatedAt(Instant.now(clock));  // 使用注入的 Clock
        return order;
    }
}

// 单元测试
@Test
public void testMonthEndBoundary() {
    Clock fixedClock = Clock.fixed(
        Instant.parse("2024-01-31T23:59:59Z"),
        ZoneId.of("UTC")
    );
    OrderService service = new OrderService(fixedClock);
    // 测试月末边界...
}
```

---

### Q5: 闰年 2 月 29 日如何正确处理？

**A**: 使用标准日期库的**月份算术 API**，自动处理闰年。

```java
// ✅ 正确：自动处理闰年
LocalDate date = LocalDate.of(2024, 2, 29);  // 闰年
LocalDate nextYear = date.plusYears(1);     // 2025-02-28（平年）

// ✅ 正确：跨月计算
LocalDate jan31 = LocalDate.of(2024, 1, 31);
LocalDate feb29 = jan31.plusMonths(1);      // 2024-02-29（闰年）
```

**测试要点**：必须覆盖以下边界：
- 2024-02-29（闰年）
- 2023-02-28 → 2023-03-01（平年月末）
- 2024-01-31 → 2024-02-29（月末跨闰年）

---

## 文档元数据 (Metadata)

- **规范名称**: 日期与时间处理规范 (Date & Time Handling Rules)
- **适用范围**:
    - 后端开发 (Java / Rust / Go / Python)
    - 数据库设计与 SQL 编写
    - 前端/API 接口定义
- **当前版本**: `v1.1.0`
- **最新更新**: 2026-06-03
- **维护负责人**: Xu Chengzi

### 变更日志 (Version History)

| 版本号   | 修订日期   | 修订人     | 变更摘要                                                    |
| :------- | :--------- | :--------- | :---------------------------------------------------------- |
| `v1.1.0` | 2026-06-03 | Xu Chengzi | 转换为中文版，优化国内开发环境话术，强化 SQL 索引保护说明。 |
| `v1.0.0` | 2026-04-15 | Xu Chengzi | 首次制定并发布基础规则（核心 API、半开区间、时区规范）。    |
