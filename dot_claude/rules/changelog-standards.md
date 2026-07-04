---
paths:
  - "**/CHANGELOG.md"
  - "**/CHANGELOG.zh-CN.md"
  - "**/CHANGELOG"
---

# CHANGELOG 规范

> 项目约定：所有 CHANGELOG 遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/) 格式。
> CHANGELOG 记录项目所有值得关注的变更，面向用户而非开发者。

---

## 1. 核心原则

- **面向用户**：记录对用户有影响的变更，不是开发者日记
- **每个版本一个条目**：按版本号分组，新版在上，旧版在下
- **日期必须标注**：每个版本条目附带发布日期（`YYYY-MM-DD`）
- **分类清晰**：变更按类型归类，同类型按重要性排序

---

## 2. 格式

```markdown
# Changelog

本项目的所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [x.y.z] - YYYY-MM-DD

### Added
- 新增功能

### Changed
- 对现有功能的变更

### Deprecated
- 即将在未来版本移除的功能

### Removed
- 本版本移除的功能

### Fixed
- Bug 修复

### Security
- 安全漏洞修复
```

---

## 3. 版本号格式

遵循 [Semantic Versioning](https://semver.org/)：

- 版本号使用 **MAJOR.MINOR.PATCH** 格式（如 `1.2.3`）
- `[Unreleased]` 段落永远位于最顶部，未发布的变更写在这里
- 已发布版本使用链接锚点（Markdown 格式）：

```markdown
## [1.2.0] - 2026-07-02
...
## [1.1.0] - 2026-06-15
...

[Unreleased]: https://github.com/owner/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/owner/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
```

---

## 4. 分类规则

| 分类 | 何时使用 | 示例 |
|------|---------|------|
| **Added** | 新增功能、新增 API、新增配置项 | `新增用户登录接口` |
| **Changed** | 对现有功能的修改，向后兼容 | `优化查询性能，响应时间减少 50%` |
| **Deprecated** | 即将移除但本版仍可用 | `弃用 v1 API，将在 2.0 移除` |
| **Removed** | 本版移除的功能（破坏性变更） | `移除旧的缓存实现` |
| **Fixed** | Bug 修复 | `修复并发场景下计数器溢出问题` |
| **Security** | 安全漏洞修复 | `修复 SQL 注入漏洞` |

### 4.1 分类使用要点

- 变更只能归属到一个分类
- 不确定时优先归入 **Changed**
- **Security** 仅用于安全相关修复，普通 Bug 修复用 **Fixed**

---

## 5. 条目撰写规则

### 5.1 语言选择

根据项目受众决定语言：

| 项目类型 | CHANGELOG 语言 | 判定依据 |
|----------|---------------|---------|
| 个人 / 内部项目 | 简体中文 | 用户群体为中文使用者 |
| 开源项目（国际） | 英文 | 面向全球开发者 |
| 开源项目（双语） | 中文 + 英文（见 §5.2） | 需同时服务中英文受众 |

### 5.2 双语 CHANGELOG（开源项目）

当开源项目需要同时服务中英文受众时，采用**单文件双语**方式：

```markdown
## [1.2.0] - 2026-07-02

### Added
- 支持熔断器三状态自动切换 / Add circuit breaker with three-state auto-transition (#45)
- 新增基于滑动窗口的失败率统计 / Add sliding-window-based failure rate tracking (#47)

### Fixed
- 修复 HALF_OPEN 状态下计数器未重置的问题 / Fix counter not resetting in HALF_OPEN state (#50)
```

**双语撰写规则：**

- 每条先写中文，斜杠 `/` 分隔后写英文
- 两种语言的信息量必须**等价**，禁止一侧详细一侧简略
- 技术术语保持英文原文，不作翻译（如 `HALF_OPEN`、`sliding window`）
- 破坏性变更标注两边都加 `**BREAKING**`：

```markdown
### Changed
- **BREAKING**: 用户认证接口请求体结构调整 / **BREAKING**: Restructure auth API request body (#56)
```

**何时拆分为独立文件：**

当 CHANGELOG 超过 200 行或翻译维护成本过高时，可拆分为两个文件：

```
CHANGELOG.md      ← 英文（默认，GitHub 默认展示）
CHANGELOG.zh-CN.md ← 中文
```

项目 README 中注明双语说明：

```markdown
> Changelog: [English](CHANGELOG.md) | [中文](CHANGELOG.zh-CN.md)
```

拆分后**禁止单文件双语**，避免维护两套格式。

### 5.3 风格规则

- 使用**祈使句、现在时态**（中文：`新增` 而非 `新增了`；英文：`Add` 而非 `Added`）
- 每条以短横线 `-` 开头
- 条目末尾不加句号
- 一行一条，简洁明了

### 5.2 关联信息

- 破坏性变更标注 `**BREAKING**` 前缀
- 关联 issue / PR 时在条目后附 `(#123)` 或 `(#456)`
- 关联 commit 时使用短 SHA（前 7 位）

```markdown
### Changed
- **BREAKING**: 用户认证接口请求体结构调整 (#456)
- 优化熔断器冷却期计算逻辑 (a1b2c3d)
```

### 5.3 合并与拆分

- **合并**：同一功能的多次小改动合并为一条
- **拆分**：不同功能的变更即使同一次提交也要分条列出

```markdown
### Added
- 新增熔断器组件，支持三状态自动切换 (abc1234, def5678)

### Fixed
- 修复熔断器 HALF_OPEN 状态下计数器未重置的问题
- 修复并发场景下状态转换的竞态条件
```

---

## 6. 维护节奏

| 时机 | 操作 |
|------|------|
| 功能开发中 | 变更写进 `[Unreleased]` 段落 |
| 版本发布时 | 将 `[Unreleased]` 改为 `[x.y.z] - YYYY-MM-DD`，新建空的 `[Unreleased]` |
| 每次合并 PR | 检查 `[Unreleased]` 是否需要更新 |

---

## 7. 禁止事项

- ❌ 在 CHANGELOG 中记录不面向用户的变更（如重构、代码清理、测试补充）
- ❌ 在条目中包含敏感信息（密钥、密码、内部 IP）
- ❌ 使用模糊描述（`修复 bug`、`优化性能`、`更新代码`）
- ❌ 跳过版本号或版本号不连续
- ❌ 在发布后才补写 CHANGELOG（变更应在开发阶段同步记录）

---

## 8. 相关文档

- **Conventional Commit**：[conventional-commit.md](./conventional-commit.md) — commit message 规范
- **Semantic Versioning**：https://semver.org/lang/zh-CN/
- **Keep a Changelog**：https://keepachangelog.com/zh-CN/

---

## 文档元数据

- 规范名称：CHANGELOG 规范
- 当前版本：v1.1.0
- 最新更新：2026-07-02
- 维护负责人：Xu Chengzi

### 变更日志

| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v1.1.0 | 2026-07-02 | Xu Chengzi | 新增双语 CHANGELOG 规范（单文件双语 + 拆分方案）。 |
| v1.0.0 | 2026-07-02 | Xu Chengzi | 首次发布。 |
