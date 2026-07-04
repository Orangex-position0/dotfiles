# 领域 Skill 编写规范 (Domain Skill Authoring Guide)

> 元规则：本规范定义如何为业务模块编写"领域 Skill"，让 Code Agent 在大型项目中能够精准定位模块、理解业务、执行变更。
> 适用范围：所有需要引入"面向 Skills 编程"范式的项目。
> 模板文件：`~/.claude/templates/domain-skill.template.md`

## 1. 定位与边界

### 1.1 何时该建领域 Skill

满足以下**任一**条件：

- 代码量 ≥ 10 万行，且日常热代码集中在 20% 区域
- 存在 3 条以上独立业务线共用同一套架构链路
- Code Agent 频繁出现"找错模块"、"误改废弃逻辑"、"漏掉跨模块影响"等问题
- 团队成员 ≥ 3 人并行迭代，业务知识分散在个人头脑中

### 1.2 何时**不**该建

- 中小项目（< 5 万行）—— 直接在 `CLAUDE.md` 写业务背景即可
- 个人项目或单人维护
- 业务逻辑高度稳定、长期不迭代

### 1.3 与 rules / CLAUDE.md 的职责区分

| 承载物 | 位置 | 职责 |
|--------|------|------|
| `rules/*.md` | `~/.claude/rules/` | 跨项目通用编码规范 |
| `CLAUDE.md` / `AGENTS.md` | 项目根目录 | 项目导航、术语表、硬约束 |
| **Domain Skill** | 项目 `.claude/skills/*.md` | 单个业务模块的领域知识 |
| `docs/` | 项目 `docs/` | API 定义、流程图、设计文档 |

**严禁**把项目特定的业务知识写进 `~/.claude/rules/`。

---

## 2. Skill 文件骨架

每个业务模块对应一个 Skill 文件，文件名使用 kebab-case。完整模板见 `~/.claude/templates/domain-skill.template.md`。

### 2.1 Frontmatter（路由判定）

```yaml
---
name: user-auth
description: 用户认证与授权模块。当需求涉及登录、注册、Token 刷新、权限校验、SSO 集成时读取本 Skill。
---
```

`description` 是 **Code Agent 决定是否加载此 Skill 的唯一依据**。必须：

- 列出该模块的 3-5 个核心业务场景
- 用"当需求涉及 X、Y、Z 时"的句式
- 避免模糊描述（如"用户相关功能"）

### 2.2 四个必填章节

| 章节 | 内容 |
|------|------|
| 路由判定 | 本 Skill 覆盖/不覆盖的需求类型，边界模糊场景处理 |
| 业务领域知识 | 背景、核心概念（Entity/VO/Aggregate）、业务规则与不变量、统一语言映射表 |
| 核心代码流程 | 主流程文本流程图 + 节点表（节点/职责/代码位置/输入/输出） |
| 变更指南 | 修改时机、影响检查清单、常见变更模式 |

---

## 3. 代码锚点规范

### 3.1 强制格式

| 类型 | 格式 |
|------|------|
| 类/文件 | `path/to/File.ext:line` |
| 函数 | `File.ext:line#methodName` |
| 接口字段 | `DTOName.fieldName` |
| SQL 锚点 | `table_name.column_name` |

### 3.2 反例

- ❌ 抽象描述："在用户服务里有个校验方法"
- ❌ 无行号："见 OrderService"
- ✅ 正确：`domain/order/service/OrderService.java:87#createOrder`

### 3.3 锚点新鲜度

所有锚点必须标注**最后验证日期**（YYYY-MM-DD）。超过 90 天未验证的锚点视为"可疑锚点"。

---

## 4. 四层防腐体系

知识体系最大的风险是**腐化**。以下四层防腐必须同时建立。

### 4.1 反向校验（Skill 内置自检清单）

每个 Skill 文件**末尾**必须包含自检清单（详见模板）。Code Agent 读取 Skill 时必须：

1. 对照清单逐项校验
2. 发现不一致时生成"修正建议报告"
3. **禁止**在不一致未解决前基于 Skill 直接生成代码

### 4.2 沟通补充（人机协作 SOP）

```text
发现知识缺失 → 人机讨论业务背景 → Agent 总结新增知识 → 人 Review 后更新 Skill → 在变更日志中记录
```

### 4.3 Commit 校验（由 Hook 承载）

| 项 | 约定 |
|----|------|
| 触发时机 | `git commit` 的 `pre-commit` 阶段 |
| 触发条件 | diff 修改了 Skill 中引用的文件路径、函数签名、DTO 字段、表结构 |
| 产出格式 | 结构化报告：命中的 Skill、差异描述、更新建议 |
| 失败处理 | 输出到 stdout，不阻塞 commit |
| 实现载体 | Claude Code Hooks（`PreToolUse` on `Bash` 匹配 `git commit`） |

### 4.4 基线巡检（由 slash command 承载）

| 项 | 约定 |
|----|------|
| 触发时机 | 合并到 `main` 后手动执行 |
| 校验内容 | 锚点有效性、接口/表结构一致性、知识覆盖度 |
| 实现载体 | 项目级 slash command（如 `/baseline-audit`） |

---

## 5. 编写流程

```text
Step 1: 沟通业务背景 → 业务背景笔记
Step 2: 梳理代码流程 → 代码流程草图 + 锚点清单
Step 3: 撰写初版 Skill（套用模板）→ Skill 初版
Step 4: 反向校验 → 校验报告 + 修正版
Step 5: 人工 Review 入库 → 入库到 .claude/skills/ + 变更日志
```

不得跳步。

---

## 6. 反模式清单

| 反模式 | 后果 | 正确做法 |
|--------|------|---------|
| 太抽象（无锚点） | AI 仍需检索代码，Skill 失效 | 锚点强制到 file:line |
| 太细（复述实现） | 维护成本爆炸 | 只描述流程节点和入口 |
| description 模糊 | AI 无法判断是否加载 | 列出 3-5 个具体场景 |
| 跨项目规则污染 | rules 和 Skill 职责混乱 | 跨项目内容进 `~/.claude/rules/` |
| 无变更日志 | 半年后不知是否过时 | 每次更新追加变更日志 |
| 无反向校验 | 锚点失效后 AI 产生幻觉 | 强制每次读取时执行 §4.1 |

---

## 7. 关键术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 领域 Skill | Domain Skill | 描述单个业务模块知识的 Skill 文件 |
| 代码锚点 | Code Anchor | Skill 中引用代码位置的可验证标记 |
| 反向校验 | Reverse Verification | 读取 Skill 时对照实际代码检查一致性 |
| 知识腐化 | Knowledge Decay | Skill 描述与实际代码逐渐偏离 |
| 锚点新鲜度 | Anchor Freshness | 锚点最后验证日期距今的天数 |
| 基线巡检 | Baseline Audit | 合并基线后对全部 Skill 的健康度扫描 |

---

## 8. 文档元数据

- 规范名称：领域 Skill 编写规范
- 当前版本：v1.1.0
- 最新更新：2026-06-23
- 维护负责人：Xu Chengzi

| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v1.1.0 | 2026-06-23 | Xu Chengzi | 抽出 Skill 模板到 `~/.claude/templates/`，正文压缩至 < 200 行。 |
| v1.0.0 | 2026-06-23 | Xu Chengzi | 首次制定。 |
