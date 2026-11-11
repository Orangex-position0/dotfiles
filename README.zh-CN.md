# 简介

这是我的 dotfiles 仓库，由 [chezmoi](https://www.chezmoi.io/) 管理。它包含了各种开发工具和应用程序的配置文件。

[English](README.md) | 简体中文

## Source 与 Target 路径

**Source 目录**是当前 Git 仓库，可用 `chezmoi source-path` 查看。**Target 目录**是 chezmoi 部署文件的目标目录，可用 `chezmoi target-path` 查看，通常是用户主目录。下表路径分别相对于这两个目录。

| Source | Target | 用途 |
| --- | --- | --- |
| `dot_zshrc` | `.zshrc` | Zsh 初始化和代理辅助函数 |
| `dot_config/symlink_zsh` | `.config/zsh`（符号链接） | 指向外部 Zsh 配置 |
| `dot_config/aerospace/` | `.config/aerospace/` | macOS 的 AeroSpace 窗口管理器 |
| `dot_config/sketchybar/` | `.config/sketchybar/` | macOS 的 SketchyBar 状态栏 |
| `dot_config/yazi/` | `.config/yazi/` | Yazi 文件管理器 |
| `dot_config/tinycast/` | `.config/tinycast/` | TinyCast 设置 |
| `dot_config/yasb/` | `.config/yasb/` | Windows 的 YASB 状态栏 |
| `dot_glzr/glazewm/` | `.glzr/glazewm/` | Windows 的 GlazeWM 窗口管理器 |
| `dot_config/zed/*.tmpl` | `.config/zed/` | macOS/Linux 的 Zed 设置和快捷键 |
| `AppData/Roaming/Zed/*.tmpl` | `AppData/Roaming/Zed/` | Windows 的 Zed 设置和快捷键 |
| `dot_ideavimrc` | `.ideavimrc` | IdeaVim 主配置 |
| `dot_ideavimrc.vim.tmpl` | `.ideavimrc.vim` | 独立的平台差异 IdeaVim 文件 |

`dot_` 会转换为开头的 `.`，`.tmpl` 文件会经过模板渲染，`executable_` 标记可执行文件，`symlink_` 定义符号链接。`.chezmoitemplates/` 存放共享模板，不直接部署到目标目录。

`README*.md`、`docs/`、`keyboard-layouts/` 和 `scripts/` 目前也在管理范围内，可能被复制到目标目录；`.chezmoiignore` 没有排除它们。

**平台过滤注意事项：** `.chezmoiignore` 虽然包含平台条件，但部分模式使用了 `dot_glzr/`、`dot_config/yasb/` 等 source 名称。忽略规则匹配的是 target 路径，因此这些模式目前不会在 macOS 上排除对应的 Windows 文件。应用前请检查 `chezmoi managed`；上表的平台标注说明预期用途，不代表已经正确过滤。

## Claude Code 配置

Claude Code 配置、规则和技能已交由独立仓库管理。当前 chezmoi source 不再包含 `dot_claude/` 和 `dot_claude_settings.json.tmpl`，也不再部署 `~/.claude/` 和 `~/.claude_settings.json`。这些 target 请通过独立仓库维护，不要重新收录到 chezmoi。

`docs/` 中现存的 Claude Skills 文档仅供历史参考，不代表本仓库当前提供的配置。

## Zed

使用 chezmoi 共享模板机制（`.chezmoitemplates/`）管理跨平台 Zed 编辑器配置。相同的 settings 和 keymap 会自动部署到各平台的对应路径：

- **Windows:** `AppData/Roaming/Zed/`
- **macOS / Linux:** `~/.config/zed/`

共享配置请编辑 `.chezmoitemplates/zed-settings.json` 和 `.chezmoitemplates/zed-keymap.json`。用 `chezmoi diff` 预览，再执行 `chezmoi apply` 部署到当前机器。两个平台的模板引用同一组共享文件；其他机器需要更新仓库并应用后才会生效。

## IdeaVim

为 JetBrains IDEs（IntelliJ IDEA、PyCharm 等）优化的 IdeaVim 配置，包含自定义快捷键。

## GlazeWM

Windows 平铺窗口管理器配置，用于高效的窗口管理和提升生产力。

## YASB

自定义 Windows 状态栏配置，提供系统信息和常用功能的快速访问。

## 键盘布局

自定义键盘布局和快捷键，包括专门用于编码和提升生产力的布局。

## 安装

先按平台安装 [chezmoi](https://www.chezmoi.io/install/)。各应用及其依赖需要单独安装。

```bash
# 下载 source，暂不应用
chezmoi init https://github.com/Orangex-position0/dotfiles.git

# 查看 source 位置、受管理的 target 和待应用变更
chezmoi source-path
chezmoi managed
chezmoi diff

# 检查并调整配置后再应用
chezmoi apply
```

应用前请备份已有文件。这些是个人配置：`.zshrc` 包含本机 Miniconda 路径、Homebrew 插件加载和代理端口 `7897`；`.config/zsh` 符号链接指向 `../config-collections/zsh/.config/zsh`，其目标内容不在本仓库中。请先检查这些路径及所需工具。

## 日常维护

```bash
# 编辑受管理 target 对应的 source，预览后部署
chezmoi edit ~/.zshrc
chezmoi diff ~/.zshrc
chezmoi apply ~/.zshrc

# 将直接修改的 target 收录回 source
chezmoi add ~/.zshrc

# 进入 source 仓库检查并提交变更
chezmoi cd
git status
```

Zed 请直接编辑共享模板，不要把渲染后的 target 文件重新收录为 source。Source 变更需要执行 `chezmoi apply` 才会部署，需要提交并推送后才能同步给其他机器。

可选的 Git hook 安装步骤，在 source 仓库内执行：

```bash
bash scripts/install-hooks.sh
```

该脚本将 `core.hooksPath` 设置为 `.githooks/`。Pre-push hook 在 merge-base 检查发现本地分支落后远程时阻止推送，不会修改本地历史。

## 文档

- [Claude Skills 历史文档](docs/Claude-skills.zh-CN.md)
- [键盘布局说明](keyboard-layouts/readme-keyboard-layouts.md)

## 贡献

这些配置是为我的工作流程个性化定制的。欢迎 fork 并根据你自己的需求进行调整。

## 许可证

目前仓库根目录没有统一的 `LICENSE` 文件。请勿默认按 MIT 许可使用；再分发前应确认适用的授权。