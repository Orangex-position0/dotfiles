---
paths:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle*"
  - "**/lefthook.yml"
---

# Java 项目工作流规则

> 本规范聚焦**本地开发与提交工作流**：工具链选型、命令节奏、Git Hooks 配置。
> CI/CD、发布、回滚、数据库迁移流程另行规范（待建）。
> 编码规范见 [Java 编码规范](./java-coding-standards.md)；commit 规范见 [Conventional Commit](./conventional-commit.md)；测试节奏见 [TDD 开发流程](./tdd-development-flow.md)。

---

## 1. 工具链选型

### 1.1 职责一览

| 职责 | 工具 | 何时跑 |
|------|------|--------|
| 格式化 | Spotless（显式选 google-java-format 或 palantir-java-format） | pre-commit |
| 编译期 Bug 检测 | Error Prone（运行需 JDK 21+，可编译老 source） | 编译时自动触发 |
| 字节码 Bug 检测 | SpotBugs | pre-push |
| 源码静态分析 | PMD | pre-push（可选） |
| 编码规范检查 | Checkstyle | pre-commit |
| 测试覆盖率 | JaCoCo | pre-push |
| 安全扫描 | OWASP Dependency-Check | 仅 CI |
| Secret 检测 | Gitleaks / TruffleHog | pre-commit |
| Commit 消息规范 | gitlint | commit-msg |

工具的具体配置（POM XML、规则集）不在本规范展开。新建项目参考团队模板，存量项目沿用既有配置。

### 1.2 组合策略

| 项目规模 | 推荐组合 |
|----------|---------|
| 个人 / 小项目 | Spotless + Error Prone |
| 中型团队 | Spotless + Error Prone + SpotBugs + JaCoCo |
| 大型 / 高安全 | 全量 + OWASP（CI） + Gitleaks |
| 中国团队 / 国内项目 | 上述组合 + Alibaba Java Coding Guidelines（p3c） |

工具之间存在检测重叠（如 Error Prone 与 SpotBugs 都查 `equals/hashCode`），这是有意为之。Google 研究表明，单一工具无法捕获所有问题，多工具配合能显著提升检测覆盖率。

### 1.3 OWASP 强制走 CI

OWASP Dependency-Check 依赖 NVD 数据库，**首次运行或数据库更新时较慢**（分钟级）。严禁放入 pre-commit / pre-push，必须由 CI 承担。

现代替代：Trivy（免费、全栈）/ Snyk（商业、Reachability 分析）/ Dependabot（GitHub 原生）—— 任选其一与 OWASP 互补或替换。

---

## 2. 本地命令节奏

按提交阶段分层执行，遵守耗时预期：

| 阶段 | 跑什么 | 耗时预期 |
|------|--------|---------|
| 写完代码 | `./mvnw spotless:apply` | < 5s |
| pre-commit | Spotless check + Checkstyle + Gitleaks + gitlint | < 10s |
| pre-push | 单元测试 + SpotBugs + JaCoCo | 10-60s |
| CI / PR | 全量工具 + OWASP + 集成测试 | 分钟级 |

**核心原则**：每层只跑该层能消化的任务，重型任务下沉到下一层。

---

## 3. Git Hooks：Lefthook

### 3.1 为什么选 Lefthook

- Go 单二进制，启动开销低
- Windows / macOS / Linux 体验一致
- 与 Maven / Gradle 调度干净
- 原生支持并行执行（`parallel: true`）

Java 项目通常不需要 pre-commit 框架（Python 生态）的大 hook 注册表，所以选 Lefthook。存量 pre-commit 项目可用 [prek](https://github.com/j178/prek)（Rust 重写，drop-in 替换）零成本提速。

### 3.2 安装

```bash
brew install lefthook                                # macOS
scoop install lefthook                               # Windows
go install github.com/evilmartians/lefthook@latest   # 通用
```

### 3.3 参考配置（lefthook.yml）

```yaml
pre-commit:
  parallel: true
  commands:
    spotless:
      run: ./mvnw -q spotless:check
    checkstyle:
      run: ./mvnw -q checkstyle:check
    gitleaks:
      run: gitleaks protect --staged

pre-push:
  commands:
    test:
      run: ./mvnw -q test
    spotbugs:
      run: ./mvnw -q spotbugs:check

commit-msg:
  commands:
    gitlint:
      run: gitlint
```

Gradle 项目把 `./mvnw -q xxx` 换成 `./gradlew -q xxx` 即可。

---

## 4. 禁止项

- ❌ pre-commit / pre-push 跑 `mvn compile`、`mvn test` 等重型任务（违背 < 10s / < 60s 原则）
- ❌ 本地跑 OWASP Dependency-Check（NVD 数据库慢，强制走 CI）
- ❌ 在工作流文档钉死工具版本号（用 `mvnw` 包装、BOM 管理或团队模板）
- ❌ 复述工具的 POM XML 配置细节（参考 [Java 编码规范](./java-coding-standards.md) 或官方文档）
- ❌ 同一份文档混用 `mvn` 与 `./mvnw`（统一使用 `./mvnw`，保证零额外安装）
- ❌ 把 hooks 当作安全边界（`git commit --no-verify` 可绕过任何本地 hook，强制必须走 CI）

---

## 5. 相关文档

- **Java 编码规范**：[java-coding-standards.md](./java-coding-standards.md) — HARD RULE + DESIGN RULE
- **Java Optional 规范**：[java-optional-standards.md](./java-optional-standards.md)
- **Spring Boot 测试规范**：[spring-boot-testing-standards.md](./spring-boot-testing-standards.md)
- **通用测试规范**：[testing-standards.md](./testing-standards.md)
- **TDD 开发流程**：[tdd-development-flow.md](./tdd-development-flow.md)
- **Conventional Commit**：[conventional-commit.md](./conventional-commit.md)

---

## 附录 A：纯 bash 退化方案

无 Lefthook 时，可直接写 `.git/hooks/pre-commit`：

```bash
#!/bin/bash
set -e

echo "Running pre-commit checks..."
./mvnw -q spotless:check
./mvnw -q checkstyle:check
gitleaks protect --staged
gitlint

echo "pre-commit passed!"
```

不推荐长期使用：多 hook 文件维护繁琐、无法并行、跨平台脚本兼容性差。团队规模超过 1 人即应迁移到 Lefthook。
