---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.ts"
  - "**/package.json"
  - "**/tsconfig.json"
---

# React + TypeScript 项目目录结构（Vite SPA）

> 适用：Vite 纯 SPA，TypeScript 严格模式
> 不适用：Next.js App Router、Remix（文件路由语义不同，需独立规范）
> 优先级：HARD > DESIGN。冲突时 HARD 优先。
> 参考来源：Bulletproof React（28.8k⭐）、Robin Wieruch [2026]、Feature-Sliced Design

## 1. 场景判断

启用本规范的项目需同时满足：

- 使用 Vite 构建的纯 SPA（客户端渲染）
- TypeScript 严格模式（`tsconfig.json` 中 `strict: true`）
- 使用 React Router 等客户端路由库
- 不使用 Next.js / Remix / TanStack Start 等服务端框架

部分满足（如 Vite + SSR）时，路由层与入口层规则需调整，结构骨架仍可复用。

## 2. HARD RULE（架构铁律）

### 2.1 目录骨架必须存在

新建 React + TS SPA 项目时，`src/` 下必须包含以下目录（即使初始为空也建出来）：

```text
src/
├── app/             # 入口与全局组装
├── assets/          # 静态资源
├── components/      # 共享 UI 组件
├── config/          # 环境变量、应用常量
├── features/        # feature 模块（核心）
├── hooks/           # 共享自定义 Hook
├── lib/             # 第三方库封装
├── pages/           # 路由入口
├── providers/       # Context Provider 组装
├── routes/          # 顶层路由配置
├── types/           # 共享 TypeScript 类型
└── utils/           # 通用工具函数
```

### 2.2 feature 必须有公共 API

- 每个 `features/<name>/` **必须**包含 `index.ts` 作为公共 API
- ❌ 禁止外部代码绕过 `index.ts` 深入 feature 内部路径
- ❌ 禁止 feature 没有公共 API 就被其他模块使用

```typescript
// 正确：通过公共 API 导入组件和类型
import { ProjectList, type Project } from "@/features/project";

// 错误：绕过公共 API
import { ProjectListInner } from "@/features/project/components/project-list-inner";
```

### 2.3 单向依赖

依赖方向只能自上而下：

```text
共享层（components/hooks/utils/lib/config/types）
        ↓
    features/
        ↓
     pages/
        ↓
     app/
```

- ❌ `components/` 不能 import `features/`
- ❌ `hooks/` 不能 import `features/`
- ❌ `features/` 不能 import `pages/` 或 `app/`
- ❌ `utils/` 不能 import 任何业务模块

### 2.4 feature 之间禁止互相 import

- ❌ `features/A` 不能直接 import `features/B` 的任何导出
- 两个 feature 需要同一段逻辑时，按优先级处理：
  1. 该逻辑上移到共享层（`hooks/`、`utils/`、`lib/`）
  2. 或在 `pages/` 层组合两个 feature，数据通过 props 流转

### 2.5 第三方库必须经 `lib/` 封装

- ❌ 业务代码直接 `import axios from "axios"` 然后配置
- ❌ 业务代码直接调用 `firebase.initializeApp(...)`
- ✅ 必须在 `lib/` 内封装为预配置实例，业务代码消费封装后的导出

```typescript
// lib/axios.ts — 封装预配置实例
import axios from "axios";
export const apiClient = axios.create({ baseURL: import.meta.env.VITE_API_BASE });

// 业务代码
import { apiClient } from "@/lib/axios";
```

### 2.6 TypeScript 规范

- **文件扩展名**：含 JSX 用 `.tsx`，纯 TypeScript 用 `.ts`
- **严格模式**：`tsconfig.json` 必须启用 `strict: true`
- **类型就近放置**：仅单个 feature 使用的类型放在 feature 内 `types.ts`；跨 feature 共享的类型放在顶层 `types/`
- **公共 API 导出类型**：`index.ts` 必须同时 re-export 公共类型（使用 `export type`）
- **Props 定义**：使用 `interface XxxProps` 定义组件 Props，Props 接口与组件同文件或就近放置
- **interface vs type**：对象形状和 Props 用 `interface`；联合类型、交叉类型、工具类型用 `type`
- **泛型命名**：使用描述性名称（`TItem`、`TResponse`），避免单字母 `T`（标准工具类型除外）

## 3. DESIGN RULE（推荐实践）

### 3.1 feature 内部 segment 划分

`features/<name>/` 内部推荐以下 segment 结构：

```text
features/<name>/
├── api/             # 后端请求、query functions、mutations
├── components/      # feature 内部组件
├── hooks/           # feature 内部 Hook
├── stores/          # feature 局部状态（Zustand / Jotai）
├── types.ts         # feature 类型定义
├── utils/           # feature 工具函数
└── index.ts         # 公共 API（强制，见 2.2）
```

按需创建，空目录不必保留。

### 3.2 路由与 Context 组织

- `routes/`：声明 `path → page` 映射，组装 Router 实例
- `pages/`：每个 page 负责组合 feature，保持简短（< 100 行为佳）
- `context/`：定义 Context 对象（`createContext` + Hook 封装）
- `providers/`：组装 Provider 链（如 `AppProviders.tsx`）

### 3.3 共享层职责边界

| 目录 | 放什么 | 不放什么 |
|------|-------|---------|
| `components/` | 跨 feature 复用的 UI 组件 | 业务组件 |
| `hooks/` | 跨 feature 复用的 Hook | 业务 Hook |
| `utils/` | 与业务无关的纯函数 | 调用 API 的逻辑 |
| `lib/` | 第三方库封装 | 业务逻辑 |
| `types/` | 跨 feature 共享类型 | feature 内部类型 |

### 3.4 状态管理选型

- **局部状态**：`useState`、`useReducer`
- **feature 内跨组件**：feature 内部 `stores/`（Zustand 推荐）
- **跨 feature 共享**：`context/` + `providers/` 组合
- ❌ 不要套用 Spring 风格的 DI 容器

### 3.5 别过度设计

MVP 阶段（< 1 个月）不需要 `features/`，超过 5 个 feature、3 人以上协作时再升级。

---

## 4. Java 后端映射表

帮助 Java 工程师建立 React 心智模型。类比只是脚手架，理解后请抛开类比。

| React 概念 | Java/Spring 对应物 | 关键差异 |
|-----------|------------------|---------|
| `features/<name>` | DDD Bounded Context | 文件夹不是包，但边界规则一致 |
| `features/<name>/index.ts` | `public` API | barrel 显式声明对外接口 |
| `features/<name>/api/` | `Repository` / `FeignClient` | 函数集合，不是 Bean |
| `context/` + `providers/` | Bean scope | 显式 Provider 链，不是隐式容器 |
| `lib/` 的 axios instance | `@Bean RestTemplate` | 模块级单例 |
| 单向依赖 | DDD 依赖倒置 | 核心域不感知外部 |

## 5. 自检：删 feature 测试

想象删除某个 feature，按报错范围判断健康度：`pages/` 报错正常；`features/` 报错说明边界泄漏；`components/` 或 `lib/` 报错需立即重构。

## 6. 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 特性模块 | feature | 按业务功能划分的自包含代码模块 |
| 片段 | segment | feature 内部按技术职责的划分 |
| 公共 API | public API | feature 通过 `index.ts` 对外暴露的接口 |
| 就近放置 | colocation | 相关代码放在同一目录的原则 |

## 文档元数据

- 规范名称：React + TypeScript 项目目录结构
- 当前版本：v2.0.0
- 最新更新：2026-07-04
- 维护负责人：Xu Chengzi
- 关联文档：[ddd-architecture.md](./ddd-architecture.md)、[tdd-development-flow.md](./tdd-development-flow.md)

| 版本 | 日期 | 修订人 | 变更摘要 |
|------|------|--------|---------|
| v2.0.0 | 2026-07-04 | Xu Chengzi | 升级为 React + TypeScript 专属规范；新增 TS 严格模式与类型组织规则；移除 Java 误区章节（建议独立为 rules 文件）；压缩至 200 行以内。 |
| v1.0.0 | 2026-07-03 | Xu Chengzi | 首次发布。 |
