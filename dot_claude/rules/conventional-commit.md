# Conventional Commit 规范

> 项目约定：所有 commit message 遵循 [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) 规范。
> 该规范的核心内容（type 列表、格式、BREAKING CHANGE 标注）AI 已熟知，本文件只记录**项目特定选择**。

## 项目特定约定

### 1. scope 命名规则

- scope 使用 kebab-case（如 `user-auth`、`order-flow`），不使用 snake_case 或 camelCase
- scope 应使用模块名、组件名或功能领域名
- 变更涉及多个 scope 时，优先选择最主要的影响范围，或省略 scope

示例：

```
feat(auth): add JWT token refresh mechanism
fix(api): handle null response from payment gateway
docs(readme): update installation instructions
```

### 2. 描述撰写语言

- description 使用**祈使句、现在时态**（如 `add` 而非 `added`）
- description 首字母**小写**，结尾不加句号
- commit message 统一使用**英文**撰写（与代码库标识符一致）

### 3. 关联 Issue / PR

页脚统一使用以下格式：

```
Closes #123
Fixes #456, #789
Refs #101
```

### 4. 破坏性变更

项目约定同时使用两种标记：

- type 后追加 `!`：快速标识（如 `feat(api)!: ...`）
- 页脚 `BREAKING CHANGE:`：详细说明迁移方案

### 5. 提交粒度

- 每个 commit 只包含一个逻辑变更
- 避免混合不相关修改

## 禁止事项

- ❌ 在 commit message 中包含敏感信息（密钥、密码、token）
- ❌ 使用模糊描述（`fix bug`、`update code`、`minor changes`）
- ❌ 引用仅在本地有意义的临时文件路径
