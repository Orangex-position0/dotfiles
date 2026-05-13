# Conventional Commit 规范

## 1. 概述

所有 commit message 必须遵循 [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) 规范。该规范提供了一套标准化的提交消息格式，使提交历史具备机器可读性，便于自动生成 CHANGELOG、自动语义化版本控制以及快速定位变更类型。

---

## 2. 提交消息格式

每条 commit message 由以下三部分组成：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 2.1 格式规则

- **首行（header）**：`<type>: <description>`，不超过 72 个字符
- **主体（body）**：与首行空一行，用于详细描述"做了什么"和"为什么这样做"
- **页脚（footer）**：与主体空一行，用于关联 Issue、PR 或标注 BREAKING CHANGE

---

## 3. 类型（type）

| 类型 | 说明 |
|------|------|
| `feat` | 新功能（feature） |
| `fix` | 修复缺陷（bug fix） |
| `docs` | 仅文档变更 |
| `style` | 不影响代码含义的格式调整（空格、缩进、缺少分号等） |
| `refactor` | 既不新增功能也不修复缺陷的代码重构 |
| `perf` | 性能优化 |
| `test` | 新增或修正测试用例 |
| `build` | 影响构建系统或外部依赖的变更（如 webpack、npm、Cargo.toml） |
| `ci` | CI/CD 配置文件和脚本的变更（如 GitHub Actions、Jenkinsfile） |
| `chore` | 其他不修改 src 或 test 的杂项变更（如 .gitignore） |
| `revert` | 回退之前的提交 |

---

## 4. 作用域（scope）

scope 用于说明 commit 影响的范围，为可选字段。格式：

```
<type>(<scope>): <description>
```

### 4.1 使用规则

- scope 应使用模块名、组件名或功能领域名
- scope 不区分大小写，但建议使用 kebab-case（如 `user-auth`）
- 当变更涉及多个 scope 时，优先选择最主要的影响范围，或省略 scope

### 4.2 示例

```
feat(auth): add JWT token refresh mechanism
fix(api): handle null response from payment gateway
docs(readme): update installation instructions
```

---

## 5. 破坏性变更（BREAKING CHANGE）

破坏性变更必须在 type 后追加 `!` 或在页脚中标注 `BREAKING CHANGE:`。

### 5.1 标记方式

**方式一：type 后追加 `!`**

```
feat(api)!: change user response structure
```

**方式二：页脚标注**

```
feat(api): change user response structure

BREAKING CHANGE: user endpoint now returns nested address object instead of flat fields
```

两种方式可同时使用，`!` 用于快速标识，页脚用于详细说明迁移方案。

---

## 6. 页脚（footer）

页脚用于关联外部资源或标注元信息，每条页脚占一行。

### 6.1 关联 Issue / PR

```
Closes #123
Fixes #456, #789
Refs #101
```

### 6.2 标注破坏性变更

```
BREAKING CHANGE: description of the breaking change and migration guide
```

### 6.3 其他元信息

```
Co-Authored-By: Name <email>
Reviewed-By: Name <email>
```

---

## 7. 示例

```
feat(user): add email verification endpoint

Add POST /api/users/verify-email endpoint that accepts a token
and marks the user's email as verified. Tokens expire after 24 hours.

Closes #342
```

```
feat(auth)!: migrate from session-based to JWT authentication

BREAKING CHANGE: Session cookies are no longer valid. Clients must
implement JWT token management. See migration guide in docs/migration.md.

Closes #201
```

---

## 8. 最佳实践

### 8.1 提交粒度

- 每个 commit 应只包含一个逻辑变更
- 避免将不相关的修改混合在同一个 commit 中

### 8.2 描述撰写

- description 使用**祈使句、现在时态**（如用 `add` 而非 `added` 或 `adds`）
- description 首字母**小写**，结尾不加句号
- body 应说明"做了什么"和"为什么"，而非"怎么做的"（代码本身展示了"怎么做"）

### 8.3 语言选择

- commit message 统一使用**英文**撰写
- 这是为了与代码库中的标识符保持一致，并便于开源协作

### 8.4 禁止事项

- 不要在 commit message 中包含敏感信息（密钥、密码、token）
- 不要使用模糊的描述（如 `fix bug`、`update code`、`minor changes`）
- 不要在 commit message 中引用仅在本地有意义的临时文件路径
