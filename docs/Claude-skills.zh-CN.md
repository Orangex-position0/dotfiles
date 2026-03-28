# Claude Skills 文档

这个目录包含我为 Claude Code 开发的自定义 skills，用于增强 AI 辅助开发的效率和质量。

[English](Claude-skills.md) | 简体中文

## Skills 概览

### 1. PPP Generator - 工作汇报生成器

**路径：** `dot_claude/skills/ppp-generator/`

**功能：** 生成结构化的 PPP (Progress-Plans-Problems) 工作文档

**核心特点：**
- 结果导向的表达优化（将"做了什么"转换为"做成了什么"）
- 简短精炼（每个部分 1-3 句话）
- 三段式结构：Progress → Plans → Problems
- 输出标准 Markdown 格式，包含 YAML frontmatter

**使用场景：**
- 日常工作汇报
- 站会记录
- 项目进度同步
- 周报/日报生成

**触发条件：**
- 用户要求"生成 PPP"、"写工作日报"、"工作汇报"、"站会记录"等
- 明确提到 Progress/Plans/Problems 结构

**示例输出：**
```markdown
---
date: 2026-03-28
author: 张三
week: 2026-W13
---

# 工作汇报 - PPP

## ✅ Progress（进展）
- 修复了用户登录 token 过期的处理 bug
- 完成新功能需求讨论会议

## 📋 Plans（计划）
- 完成登录功能的测试用例
- 优化数据库查询性能

## ⚠️ Problems（问题/风险）
- 第三方 API 响应不稳定，需要监控和优化
```

**详细文档：** [ppp-generator/SKILL.md](../dot_claude/skills/ppp-generator/SKILL.md)

---

### 2. Tech Blog Coach - 技术博客写作教练

**路径：** `dot_claude/skills/tech-blog-coach/`

**功能：** 基于**费曼学习法**的技术博客写作教练，帮助开发者将"你掌握的知识"转化为"别人能看懂的文章"

**核心理念：**
- **费曼学习法**：如果你不能简单地说清楚，说明你还没有完全理解它
- **笔记 vs 文章**：笔记是给自己看的，文章是给读者看的（用于检验自己是否真懂）

**四大核心能力：**

1. **技术文章创作**
   - 支持三种创作模式：
     - 模式1：基于笔记修改文章初稿（Logseq 工作流 - 推荐）
     - 模式2：基于笔记创作新文章
     - 模式3：自主创作，AI 提供大纲和指导
   - 使用固定的 5 部分文章结构

2. **文章润色优化**
   - 分析现有文章的优势和问题
   - 确保内容连贯、不跳步骤
   - 验证代码可运行性

3. **写作策略规划**
   - 从日常开发中提炼主题
   - 创建选题池
   - 评估可行性和价值

4. **发布格式准备**
   - 优化标题和描述
   - SEO 优化
   - 最终质量检查

**技术文章固定模板（5 部分）：**
1. **背景 & 问题** - 介绍背景，让读者了解文章定位
2. **方案或原理** - 分点讲述核心概念，使用代码、图、列表辅助
3. **实现步骤** - 分步骤说明，代码示例完整可运行
4. **示例 / 踩坑** - 常见错误和解决方案
5. **总结** - 快速总结，提出延伸思路

**质量检查清单（核心）：**
- 是否跳过太多步骤？（内容要连贯）
- 是否假设了过多的前置知识？（必要概念需补充）
- 代码是否能运行？（先在 IDE 中验证）

**资源文件：**
- `templates/blog-post-template.md` - 基于 5 部分结构的文章模板
- `templates/blog-outline-template.md` - 大纲规划模板
- `templates/writing-checklist.md` - 质量检查清单
- `templates/note-to-article-guide.md` - 笔记到文章转化指南
- `templates/logseq-workflow-guide.md` - Logseq 工作流指南（推荐）
- `references/writing-workflows.md` - 详细工作流程

**使用场景：**
- 将学习笔记转化为技术博客
- 润色和优化现有文章
- 从零开始创作技术教程
- 准备发布格式

**详细文档：** [tech-blog-coach/SKILL.md](../dot_claude/skills/tech-blog-coach/SKILL.md)

---

### 3. Skill Creator - 技能创建指南

**路径：** `dot_claude/skills/skill-creator/`

**功能：** 创建有效的 Claude Code skills 的指南

**关于 Skills：**

Skills 是模块化、自包含的包，通过提供专业知识、工作流程和工具来扩展 Claude 的能力。可以将它们视为特定领域或任务的"入职指南"——将 Claude 从通用代理转变为配备了程序性知识的专业代理。

**Skill 提供的能力：**
1. **专门化工作流程** - 特定领域的多步骤程序
2. **工具集成** - 使用特定文件格式或 API 的说明
3. **领域专业知识** - 公司特定的知识、架构、业务逻辑
4. **打包资源** - 用于复杂和重复任务的脚本、参考和资产

**核心原则：**

1. **简洁是关键**
   - 默认假设：Claude 已经很聪明
   - 只添加 Claude 没有的上下文
   - 用简洁的示例替代冗长的解释

2. **设置适当的自由度**
   - **高自由度**（基于文本的说明）：多种方法有效时
   - **中等自由度**（伪代码或带参数的脚本）：存在首选模式时
   - **低自由度**（特定脚本，少参数）：操作脆弱且容易出错时

3. **渐进式披露**
   - Metadata（name + description）- 始终在上下文中（~100 词）
   - SKILL.md body - 当 skill 触发时（<5k 词）
   - 打包资源 - 根据 Claude 需要（无限制）

**Skill 结构：**
```
skill-name/
├── SKILL.md (必需)
│   ├── YAML frontmatter (name, description)
│   └── Markdown instructions
└── Bundled Resources (可选)
    ├── scripts/       - 可执行代码
    ├── references/    - 文档参考资料
    └── assets/        - 输出中使用的文件
```

**Skill 创建流程（6 步）：**

1. **理解 Skill** - 通过具体示例理解 skill 的使用模式
2. **规划可复用内容** - 确定需要的 scripts、references、assets
3. **初始化 Skill** - 运行 `init_skill.py` 生成模板
4. **编辑 Skill** - 实现资源并编写 SKILL.md
5. **打包 Skill** - 运行 `package_skill.py` 创建可分发的 .skill 文件
6. **迭代改进** - 基于实际使用进行优化

**资源文件：**
- `references/workflows.md` - 多步骤流程和条件逻辑的模式
- `references/output-patterns.md` - 模板和示例模式

**使用场景：**
- 创建新的自定义 skill
- 更新现有 skill
- 学习 skill 设计最佳实践
- 理解如何组织 skill 的资源结构

**详细文档：** [skill-creator/SKILL.md](../dot_claude/skills/skill-creator/SKILL.md)

---

## 安装和使用

### 安装 Skills

这些 skills 位于 `dot_claude/skills/` 目录下，会被 chezmoi 自动同步到 `~/.claude/skills/`。

### 使用 Skills

Skills 会根据其 description 中定义的触发条件自动激活。例如：

- **PPP Generator**: 当你说"生成 PPP"或"写工作日报"时自动触发
- **Tech Blog Coach**: 当你提到"技术博客"、"写作"、"费曼学习法"时自动触发
- **Skill Creator**: 当你说"创建 skill"或"写新 skill"时自动触发

### 开发新 Skills

使用 Skill Creator skill 来创建新的自定义 skills：

```bash
# 1. 使用 skill-creator 作为模板
cd dot_claude/skills/skill-creator

# 2. 运行初始化脚本
python scripts/init_skill.py my-new-skill --path ../

# 3. 编辑 SKILL.md 和添加资源

# 4. 打包 skill
python scripts/package_skill.py ../my-new-skill
```

## Skills 之间的关系

这三个 skills 相互补充，形成了一个完整的工具链：

1. **Skill Creator** - 用于创建新的 skills（包括其他两个）
2. **Tech Blog Coach** - 提升技术写作质量和效率
3. **PPP Generator** - 优化工作汇报和团队沟通

## 贡献和反馈

这些 skills 是根据我的个人工作流程和需求定制的。如果你有改进建议或发现了问题，欢迎提交 Issue 或 Pull Request。

## 许可证

这些 skills 遵循 MIT 许可证。你可以自由使用、修改和分发。

---

**最后更新：** 2026-03-28
**维护者：** Orangex-position0