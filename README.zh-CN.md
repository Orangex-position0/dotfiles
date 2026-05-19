# 简介

这是我的 dotfiles 仓库，由 [chezmoi](https://www.chezmoi.io/) 管理。它包含了各种开发工具和应用程序的配置文件。

[English](README.md) | 简体中文

## 概览

- `dot_claude/` - Claude Code 配置和自定义技能
- `dot_ideavimrc` - JetBrains IDEs 的 IdeaVim 配置文件
- `dot_config/yasb/` - YASB (Yet Another Status Bar) 配置文件
- `dot_glzr/glazewm/` - GlazeWM 配置文件（Windows 平铺窗口管理器）
- `dot_config/zed/` - Zed 编辑器配置（macOS/Linux）
- `AppData/Roaming/Zed/` - Zed 编辑器配置（Windows）
- `keyboard-layouts/` - 自定义键盘布局和快捷键
- `docs/` - 自定义工具和配置的文档

## Claude Code 配置

### 自定义技能

我为 Claude Code 开发了几个自定义技能来增强工作流程：

- **PPP 生成器** - 使用 Progress-Plans-Problems 格式生成结构化的工作汇报
- **技术博客教练** - 基于费曼学习法的技术写作教练
- **技能创建指南** - 创建有效的 Claude Code 技能的指南

📖 **详细文档：** [Claude Skills 文档](docs/Claude-skills.zh-CN.md)

### 配置原则

我的 Claude Code 配置遵循以下原则：

- **语言：** 默认使用简体中文进行交流
- **代码风格：** 可读性优先、DRY、高内聚低耦合
- **架构：** 领域驱动设计 (DDD) 结合 SOLID 原则
- **文档：** 统一文档维护，不创建冗余的总结文件

## Zed

使用 chezmoi 共享模板机制（`.chezmoitemplates/`）管理跨平台 Zed 编辑器配置。相同的 settings 和 keymap 会自动部署到各平台的对应路径：

- **Windows:** `AppData/Roaming/Zed/`
- **macOS / Linux:** `~/.config/zed/`

修改 Zed 配置时只需编辑 `.chezmoitemplates/` 下的共享文件，变更会自动应用到所有平台。

## IdeaVim

为 JetBrains IDEs（IntelliJ IDEA、PyCharm 等）优化的 IdeaVim 配置，包含自定义快捷键。

## GlazeWM

Windows 平铺窗口管理器配置，用于高效的窗口管理和提升生产力。

## YASB

自定义 Windows 状态栏配置，提供系统信息和常用功能的快速访问。

## 键盘布局

自定义键盘布局和快捷键，包括专门用于编码和提升生产力的布局。

## 安装

这个仓库使用 chezmoi 管理。要在新机器上安装这些 dotfiles：

```bash
# 安装 chezmoi
curl -fsSL https://chezmoi.io/get | sh

# 初始化仓库
chezmoi init https://github.com/yourusername/yourrepo.git

# 应用 dotfiles
chezmoi apply
```

## 贡献

这些配置是为我的工作流程个性化定制的。欢迎 fork 并根据你自己的需求进行调整。

## 许可证

本仓库采用 MIT 许可证。

---

**最后更新：** 2026-05-19
**维护者：** Orangex-position0