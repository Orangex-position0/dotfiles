# 架构决策记录（ADR）编写规范

> 凡是涉及 ADR 编写、维护、状态管理的代码会话，必须遵守本规范。
> 基于 Michael Nygard 2011 提案。Nygard 5 字段模板为最低标准。

## 核心字段（必填）

### 1. 标题（Title）

- 格式：短名词短语
- ✅ "PostgreSQL JSONB for Event Storage"
- ❌ "How we chose database"、"关于数据库的决策"

### 2. Status（状态机）

取值与流转：

```
proposed → accepted → deprecated
              ↓
         superseded (by ADR MMM)
rejected（仅用于记录"我们考虑过但没用"）
```

### 3. Context（上下文）

- 价值中立，只陈述事实和约束
- ✅ "团队只有 2 名后端工程师"
- ❌ "所以我们不该选 Java"（这是论证，应出现在 Decision）

### 4. Decision（决策）

- 用主动语态完整句子
- ✅ "We will use Redis as the session store"
- ❌ "Use Redis"

### 5. Consequences（后果）

- 正面、负面、中性全部列出
- **至少包含 1 条负面后果**
- 一个没有负面后果的决策，往往不值得写 ADR

### 6. 补充字段（推荐）

| 字段 | 说明 |
|------|------|
| 日期 | ADR 创建日期（YYYY-MM-DD） |
| 作者 | 决策负责人或团队 |
| 替代方案 | 评估过的其他方案 + 放弃原因 |
| 撤销条件 | 触发重新评估的条件/指标 |

## 硬性约束

- **一个 ADR 一个决策**，长度控制在 1-2 页
- **编号单调递增，不复用**（adr-001, adr-002...）
- **superseded 的 ADR 永远保留，只改 Status 字段**
- **Context 字段必须非空**
- **Consequences 必须包含负面**
- **团队统一一种模板**，不得混合 Nygard / MADR / Y-Statement
- **架构决策变更必须先写（或更新）ADR，再改代码**
- 新 ADR 的 Consequences 写得好不好，直接影响下一个 ADR 的 Context 质量

## 文件命名与存放

- 命名：`adr-NNN-short-title.md`（编号三位，左补零）
- 存放：`docs/adr/` 目录，随代码版本化

## 反模式

| 反模式 | 后果 | 修正 |
|--------|------|------|
| 一个 ADR 写多个决策 | AI 读完污染 context | 拆分为多个 ADR |
| 跳过 Context 直接写 Decision | 后人无法理解决策动机 | 强制 Context 非空 |
| Consequences 只写正面 | 隐藏决策成本 | 至少 1 条负面 |
| 删除 superseded 的 ADR | 历史决策动机丢失 | 永远保留，只改 Status |
| 混合多种模板格式 | AI 无法学会"在哪找什么" | 团队统一一种 |
| 写成几千字的设计文档 | 冗余叙述稀释注意力 | 控制在 1-2 页 |

## 最小模板

```markdown
# ADR NNN: <短名词短语>

- **状态**：proposed | accepted | rejected | deprecated | superseded by ADR MMM
- **日期**：YYYY-MM-DD
- **作者**：姓名/团队

## 上下文

<技术问题、业务约束、背景环境。价值中立，只陈述事实。>

## 决策

We will <具体方案>。具体来说：

- <选用的组件/版本/方式>
- <不做的范围界定>

## 后果

- 正面：<收益>
- 正面：<收益>
- 负面：<代价>
- 中性：<未来可能的影响>

## 替代方案

- 方案 A：<描述>。不选原因：<原因>
- 方案 B：<描述>。不选原因：<原因>

## 撤销条件

当以下条件出现时，应重新评估此决策：

- <条件 1>
- <条件 2>
```

---

## 文档元数据

- 规范名称：架构决策记录编写规范
- 当前版本：v1.0.0
- 最新更新：2026-07-04
- 维护负责人：Xu Chengzi
- 延伸阅读：ADR/PRD/BDD 完整指南见 `test1-domain-guide.md`
