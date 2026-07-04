# 日期与时间处理规范 (Date & Time Handling Rules)

## 目的

防止因月份边界、闰年、时区、夏令时（DST）以及 SQL 日期过滤导致的常见 Bug。凡是涉及日期、时间、时间戳、定时调度、API 传输或 SQL 编写/审查的代码，必须严格执行本规范。

---

## 核心规则 (ALWAYS)

### 1. 必须使用标准日期/时间库

严禁手动计算日历或编写时间加减逻辑：

- **Java**: `java.time` (JSR-310)
- **Rust**: `chrono` 或 `time`
- **Go**: `time`
- **Python**: `datetime`, `dateutil`
- **JavaScript**: `date-fns`, `dayjs`

### 2. 使用正确的日期类型

**严禁使用 String 存储或传输日期**（API 序列化除外）：

- **生日/不含时区的日期**: `LocalDate`
- **系统绝对时间戳**: `Instant`
- **含时区的完整时间**: `ZonedDateTime` 或 `OffsetDateTime`
- **纯时间（如营业时间）**: `LocalTime`
- 除非故意忽略时区逻辑，否则禁止滥用 `LocalDateTime`

### 3. 系统时间戳一律使用 UTC

审计时间（`created_at`、`updated_at`、日志时间等）必须以 **UTC** 或 **Timestamp** 类型存储。若业务逻辑强依赖本地时间语义，应单独字段显式存储时区信息。

### 4. API 交互统一使用 ISO-8601 格式

禁止自定义日期字符串格式（如 `yyyy/MM/dd`）：

- `2026-06-03T15:30:00Z` (UTC)
- `2026-06-03T15:30:00+08:00` (带时区)
- Unix 时间戳需在 Schema 中明确单位（秒/毫秒）

### 5. 必须使用月份算术 API

- ✅ `date.plusMonths(1)` / `date + relativedelta(months=1)`
- ❌ `date.plusDays(30)` / `date + timedelta(days=30)`

### 6. 时间范围查询必须左闭右开区间

禁止 `BETWEEN ... AND ...`：

- ✅ `created_at >= :start AND created_at < :end`
- ❌ `created_at BETWEEN :start AND :end`

---

## SQL 编写规范

### 1. 月度数据查询

构造下一个月的第一天作为开区间边界：

- ✅ `created_at >= '2026-01-01' AND created_at < '2026-02-01'`
- ❌ 假设当前月有 30 天或 31 天

### 2. 保护索引可用性 (Sargable)

禁止对索引列使用时间函数（导致索引失效）：

- ✅ `created_at >= ? AND created_at < ?`
- ❌ `DATE(created_at) = ?`、`YEAR(created_at) = ?`、`MONTH(created_at) = ?`

### 3. 日期分组统计

必须使用数据库原生时间截断函数：

- **PostgreSQL**: `DATE_TRUNC`
- **MySQL**: `DATE_FORMAT`
- **SQL Server**: `DATEPART`
- ❌ `GROUP BY SUBSTRING(created_at, 1, 7)`

---

## 快速参考表

| 场景 | ❌ 错误 | ✅ 正确 |
|------|--------|--------|
| 月度查询 | `+ INTERVAL 30 DAY` | `+ INTERVAL 1 MONTH` |
| 时间范围 | `BETWEEN start AND end` | `>= start AND < end` |
| 月份计算 | `plusDays(30)` | `plusMonths(1)` |
| 日期分组 | `SUBSTRING(date, 1, 7)` | `DATE_TRUNC('month', date)` |
| 时区指定 | `ZoneId.systemDefault()` | `ZoneId.of("Asia/Shanghai")` |
| 索引列过滤 | `DATE(created_at) = ?` | `created_at >= ? AND created_at < ?` |
| API 格式 | `"yyyy/MM/dd"` | `"2026-06-03T15:30:00+08:00"` |

---

## 时区规范

- **显式指定**：禁止依赖 `ZoneId.systemDefault()`，必须明确 UTC / 业务时区 / 用户本地时区
- **转换时机**：时区转换仅在 **API 层** 或 **前端展示层**；禁止在 SQL 索引条件中做复杂时区函数转换

---

## 可测试性（Clock 依赖注入）

为了在单元测试中 Mock 时间（月末、闰年、夏令时切换日）：

- ❌ `Instant.now()`, `LocalDate.now()`（无参）
- ✅ 注入 `Clock`，使用 `Instant.now(clock)` / `LocalDate.now(clock)`

---

## 绝对禁止 (NEVER)

1. 假设一个月有 30 天或平年二月有 28 天
2. 已有标准库时手动计算闰年
3. 硬编码时区偏移量（如 `+08:00`），应用时区 ID（如 `Asia/Shanghai`）
4. 字符串拼接构造日期对象

---

## 代码审查清单

1. 时区是否正确且显式指定？
2. 是否选用了最匹配业务语义的时间类型？
3. **闰年（2024-02-29）**和**月末（01-31 + 1 月）**能否正常运行？
4. 跨年、跨月计算边界是否安全？
5. SQL 条件是否破坏了 `created_at` 等字段的索引？
6. 时间范围是否全部采用左闭右开区间？
7. 是否编写了特殊时间节点（月末、年尾、夏令时）的单元测试？

---

## 术语表 (Glossary)

| 中文 | 英文 | 说明 |
|------|------|------|
| 左闭右开 | Half-Open Interval | `[start, end)`，包含起点不包含终点 |
| 索引可优化 | Sargable | WHERE 条件能使用索引 |
| 月份算术 | Month Arithmetic | 基于月份的日期计算，自动处理月末/闰年 |
| 夏令时 | DST | 部分地区调整时钟导致时间跳跃 |

---

## 文档元数据

- 规范名称：日期与时间处理规范
- 当前版本：v1.2.0
- 最新更新：2026-06-23
- 维护负责人：Xu Chengzi

| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v1.2.0 | 2026-06-23 | Xu Chengzi | 精简 FAQ 章节，正文压缩至 < 200 行。 |
| v1.1.0 | 2026-06-03 | Xu Chengzi | 转换为中文版，强化 SQL 索引保护说明。 |
| v1.0.0 | 2026-04-15 | Xu Chengzi | 首次发布。 |
