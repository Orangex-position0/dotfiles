# 产品需求文档（PRD）编写规范

> 凡是涉及 PRD 编写、维护、范围管理的代码会话，必须遵守本规范。
> 基于 Atlassian Agile PRD 指南 + Aakash Gupta 现代版模板。

## 定位

- PRD 是**团队对齐和协作的载体，不是签字合同**
- PRD 是 **living document**，每次范围变更同步更新
- 只写到"做什么"层面，实现细节留给工程

## 核心字段（必填）

### 1. Meta（元信息）

- Participants：谁参与（PM、设计师、技术负责人、利益相关方）
- Status：`Drafting` | `In Review` | `Approved` | `In Progress` | `Shipped` | `Deprecated`
- Target release：预期发布版本

### 2. Objectives（业务目标）

- Business Objectives：1-3 条，可量化
- Strategic Fit：关联公司/部门的什么大目标
- Success Metrics：发布后怎么判断做对了

### 3. Background（背景）

- 为什么要做？用户痛点或业务诉求
- 之前的尝试，为什么没成

### 4. Assumptions（假设）

- 技术假设（系统已经能做什么）
- 业务假设（用户行为、市场环境）
- **待验证的假设明确标出**

### 5. User Stories（用户故事）

- 格式：`As a <角色>, I want <功能>, so that <价值>`
- 关联用户访谈、原型、截图

### 6. Design（设计与交互）

- 设计稿、原型链接
- 关键交互流程

### 7. Open Questions（待解决问题）

- 还没决定的事项、需要进一步研究的事项

### 8. What We're Not Doing（不做什么）

**此字段是现代 PRD 与传统 PRD 的核心差异，必须非空。**

- 明确写出本次范围外的事项
- 每条标注原因和处置方式：
  - "计划 X 季度评估"（推迟）
  - "产品决策未完成"（悬而未决）
  - "合规风险未评估"（绝对不做）

## 硬性约束

- **What We're Not Doing 字段必须非空**
- **PRD 是 living document，每次范围变更同步更新**
- **只写"做什么"，不写"怎么做"**（实现细节留给工程）
- **PM + 工程师 + 设计师共同起草**，不得 PM 独写
- **单 PRD 控制在 1-3 页**。超过时拆分为子 PRD，主 PRD 做索引

## 文件存放

- 命名：`feature-name.md`
- 存放：`docs/prd/` 目录

## 反模式

| 反模式 | 后果 | 修正 |
|--------|------|------|
| 写成详细技术设计 | 工程师失去实现自由度 | 只写"做什么" |
| 无 What We're Not Doing | 范围持续蔓延 | 强制此字段非空 |
| PRD 写完不更新 | 与实现脱节，失去可信度 | 每次范围变更同步更新 |
| PM 独写 | 脱离工程实际 | 至少一名工程师参与起草 |
| 所有用户故事塞进一个 PRD | 单文档过长，AI 难消费 | 拆分为子 PRD |
| 签字后不允许改 | 丧失 living document 价值 | 标注 last updated，持续更新 |

## 最小模板

```markdown
# <功能名称> PRD

## Meta

- Participants: <PM>、<后端>、<设计>、<前端>
- Status: Drafting | In Review | Approved | In Progress | Shipped
- Target release: vX.Y.Z (YYYY-MM-DD)

## Objectives

- Business: <可量化目标>
- Strategic Fit: <关联的大目标>
- Success Metrics:
    - <指标 1>
    - <指标 2>

## Background

- <为什么要做>
- <之前的尝试>

## Assumptions

- <技术假设>（待验证：<标注>）
- <业务假设>

## User Stories

- As a <角色>, I want <功能>, so that <价值>

## Design

- 原型：<link>
- 关键流程：<步骤描述>

## Open Questions

- <待决定事项>

## What We're Not Doing

- ❌ <范围外事项>（<原因>）
- ❌ <范围外事项>（<原因>）
```

---

## 文档元数据

- 规范名称：产品需求文档编写规范
- 当前版本：v1.0.0
- 最新更新：2026-07-04
- 维护负责人：Xu Chengzi
- 延伸阅读：ADR/PRD/BDD 完整指南见 `test1-domain-guide.md`
