# Rules 编写规范 (Rules Authoring Spec)

> 元规范：本文件定义 `~/.claude/rules/` 下所有 `.md` 文档的编写规范。
> 本文件**不**放在 `rules/` 目录下，避免被 Claude Code 自动加载占用 context。

## 1. 核心原则

| 原则 | 说明 |
|------|------|
| **单一职责** | 一个文件承载一个主题（一种语言 / 一个领域 / 一类规范） |
| **行数 < 200** | Anthropic 官方推荐上限。超长会"消耗更多 context + 降低遵循度"。来源：[How Claude remembers your project](https://code.claude.com/docs/en/memory) |
| **只写非默认约定** | 默认行为、官方风格指南不用复述 |
| **不重复 linter** | 格式化、import 排序等交给 ESLint/Prettier/rustfmt/google-java-format |
| **可验证** | 规则必须具体到能判断"是否遵循" |

## 2. 文件命名

- 使用 kebab-case（如 `java-coding-standards.md`）
- 语言/技术栈前缀：`java-*`、`rust-*`、`spring-boot-*`、`python-*`
- 后缀约定：
  - `*-standards.md`：硬性规范（必须遵守）
  - `*-conventions.md`：约定（推荐遵守）
  - `*-guide.md`：指南（方法论）
  - `*-specification.md`：完整规范（含术语、FAQ）

## 3. Frontmatter

### 3.1 字段规则（核心：防止字段污染）

**Rules 系统仅支持 `paths` 一个字段**，用于按文件路径 glob 触发自动加载。

**禁止引入以下字段**（属于其他系统，rules 加载器会忽略，等价于死字）：

| 禁用字段 | 实际归属 |
|---------|---------|
| `description` / `name` / `when_to_use` / `disable-model-invocation` | Skills 系统 |
| `alwaysApply` / `globs`（部分版本） | Cursor / 其他 IDE |

如需"按语义触发加载"，应改用 Skill（见 `templates/domain-skill.template.md`），不要塞进 rules。

### 3.2 无 Frontmatter（全局加载）

适用于**跨语言/跨场景**的规则，每次启动都加载：

```markdown
# Conventional Commit 规范
...
```

示例：`conventional-commit.md`、`date-handling-specification.md`、`ddd-architecture.md`、`api-documentation.md`。

### 3.3 有 Frontmatter（按需加载）

适用于**特定语言/场景**的规则，仅在 Claude 读取匹配文件时加载：

```markdown
---
paths:
  - "**/*.java"
---

# Java Coding Standards
...
```

**常用 paths 模式**：

| 场景 | paths |
|------|-------|
| Java 源码 | `**/*.java` |
| Java 测试 | `**/src/test/**/*.java`, `**/*{Test,IT}.java` |
| Rust 源码 | `**/*.rs`, `**/Cargo.toml` |
| Go 源码 | `**/*.go` |
| Python 源码 | `**/*.py` |
| JavaScript / TypeScript | `**/*.{js,ts,jsx,tsx}` |
| 测试代码（通用） | `**/{src/test,tests}/**`, `**/*{Test,Spec}.*` |
| Spring Boot | `**/*.java`, `**/application*.{yml,yaml,properties}` |

## 4. 章节结构

按 WHY → WHAT → HOW 组织：

```markdown
# <文档名>

> 一句话定位：本规范解决什么问题。

## 1. Why（为什么）
该规范的动机、过去踩过的坑。

## 2. What（规则）
按优先级分组（HARD > DESIGN > STYLE）。

## 3. Examples（示例）
正例 / 反例对比。

## 4. Anti-patterns（反模式）
常见错误及修正方式。
```

**最小结构**（短文档可省略部分章节）：标题 + 规则 + 示例。

新建 rules 时建议从模板起步：`templates/rule.template.md`。

## 5. 格式规范

### 5.1 语言

- **正文中文为主**
- **代码实体保英文**：类名、函数名、变量名、库名、框架名
- **标题可中英混用**

### 5.2 反例与正例

统一使用 `❌` / `✅` + 代码块对比，或用表格（适用于多条规则）。

### 5.3 代码锚点

引用项目内代码时，使用 `path/to/File.ext:line` 格式。

### 5.4 禁止格式

- ❌ 行尾注释（严格遵守 CLAUDE.md 第二部分）
- ❌ 表格列超过 5 列
- ❌ 嵌套列表超过 4 级

## 6. 元数据与变更日志

长文档（> 100 行）建议在文末添加：

```markdown
## 文档元数据

- 规范名称：XXX 规范
- 当前版本：v1.0.0
- 最新更新：YYYY-MM-DD
- 维护负责人：<name>

### 变更日志
| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v1.0.0 | YYYY-MM-DD | <name> | 首次发布 |
```

短文档（< 100 行）可省略。

**版本号升级触发**：major=破坏性变更 / minor=新增规则 / patch=文字修正。

## 7. 交叉引用与相关文档

- 引用其他 rules：使用相对路径 `rules/xxx.md`（**不**用 `@import`，会被展开加载）
- 引用 CLAUDE.md：直接写 `CLAUDE.md` 第几部分
- 引用外部标准：用 markdown 链接

**相关文档体系**：

| 文档 | 位置 | 职责 |
|------|------|------|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | 全局索引，顶层思想 |
| `rules/*.md` | `~/.claude/rules/*.md` | 具体规范，单一主题，按需加载 |
| `templates/*.md` | `~/.claude/templates/*.md` | 文档模板（rules / domain-skill） |
| `RULES_SPEC.md` | `~/.claude/RULES_SPEC.md` | 元规范（本文件） |
| `rules/domain-skill-authoring.md` | rules 目录 | 领域 Skill 编写规范 |

## 8. 检查清单

提交新 rules 文档前，逐项核对：

- [ ] 文件名 kebab-case，语言前缀正确
- [ ] 行数 < 200（超长则拆分或精简）
- [ ] frontmatter 字段是 `paths` 或无（禁用 `description` / `alwaysApply` 等）
- [ ] 章节结构清晰（WHY/WHAT/HOW）
- [ ] 反例正例格式统一（❌/✅ 或表格）
- [ ] 无行尾注释
- [ ] 无重复 linter 能做的规则
- [ ] 长文档有元数据和变更日志
- [ ] 已 `chezmoi add` 纳入版本控制

## 文档元数据

- 规范名称：Rules 编写规范 (Rules Authoring Spec)
- 当前版本：v1.1.0
- 最新更新：2026-07-02
- 维护负责人：Xu Chengzi

### 变更日志

| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v1.1.0 | 2026-07-02 | Xu Chengzi | 加入字段污染防护（禁用 Skills/Cursor 专属字段）；引用 rule 模板；补全 paths 模式表；明确版本号升级规则。 |
| v1.0.0 | 2026-06-23 | Xu Chengzi | 首次制定。明确命名、Frontmatter、章节结构、格式、元数据规范。 |
