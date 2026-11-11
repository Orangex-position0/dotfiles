# Introduction

This repo is my dotfiles collection, managed by [chezmoi](https://www.chezmoi.io/). It contains configuration files for various development tools and applications.

English | [简体中文](README.zh-CN.md)

## Source and Target Paths

The **source directory** is this Git repository (`chezmoi source-path`). The **target directory** is the destination where chezmoi deploys files (`chezmoi target-path`, normally your home directory). Paths below are relative to those directories.

| Source | Target | Purpose |
| --- | --- | --- |
| `dot_zshrc` | `.zshrc` | Zsh initialization and proxy helpers |
| `dot_config/symlink_zsh` | `.config/zsh` (symlink) | Link to an external Zsh configuration |
| `dot_config/aerospace/` | `.config/aerospace/` | AeroSpace window manager for macOS |
| `dot_config/sketchybar/` | `.config/sketchybar/` | SketchyBar for macOS |
| `dot_config/yazi/` | `.config/yazi/` | Yazi file manager |
| `dot_config/tinycast/` | `.config/tinycast/` | TinyCast settings |
| `dot_config/yasb/` | `.config/yasb/` | YASB status bar for Windows |
| `dot_glzr/glazewm/` | `.glzr/glazewm/` | GlazeWM window manager for Windows |
| `dot_config/zed/*.tmpl` | `.config/zed/` | Zed settings and keymap for macOS/Linux |
| `AppData/Roaming/Zed/*.tmpl` | `AppData/Roaming/Zed/` | Zed settings and keymap for Windows |
| `dot_ideavimrc` | `.ideavimrc` | Main IdeaVim configuration |
| `dot_ideavimrc.vim.tmpl` | `.ideavimrc.vim` | Separate platform-specific IdeaVim file |

`dot_` becomes a leading `.`, `.tmpl` files are rendered, `executable_` marks executable files, and `symlink_` defines a symbolic link. `.chezmoitemplates/` contains shared templates rather than deployed files.

`README*.md`, `docs/`, `keyboard-layouts/` and `scripts/` are also currently managed and can be copied into the target directory. They are not excluded by `.chezmoiignore`.

**Platform caveat:** `.chezmoiignore` contains platform conditions, but some patterns use source names such as `dot_glzr/` and `dot_config/yasb/`. Ignore patterns match target paths, so these do not currently exclude the corresponding Windows files on macOS. Check `chezmoi managed` before applying; platform labels above describe intended use, not guaranteed exclusions.

## Claude Code Configuration

Claude Code configuration, rules and skills are managed in a separate repository. This chezmoi source no longer contains `dot_claude/` or `dot_claude_settings.json.tmpl` and does not deploy `~/.claude/` or `~/.claude_settings.json`. Maintain those targets through the separate repository; do not re-add them to chezmoi.

The existing Claude skills documents under `docs/` are historical references, not instructions for configurations currently shipped by this repository.

## Zed

Cross-platform Zed editor configuration using chezmoi's shared template mechanism (`.chezmoitemplates/`). The same settings and keymap are deployed to platform-specific paths:

- **Windows:** `AppData/Roaming/Zed/`
- **macOS / Linux:** `~/.config/zed/`

Edit `.chezmoitemplates/zed-settings.json` and `.chezmoitemplates/zed-keymap.json` for shared changes. Preview with `chezmoi diff`, then run `chezmoi apply` to deploy on the current machine. Both platform templates use these shared files; other machines receive changes after updating and applying the repository.

## IdeaVim

IdeaVim configuration for JetBrains IDEs (IntelliJ IDEA, PyCharm, etc.) with custom keybindings optimized for development workflow.

## GlazeWM

Windows tiling window manager configuration for efficient window management and productivity.

## YASB

Custom status bar configuration for Windows, providing system information and quick access to common functions.

## Keyboard Layouts

Custom keyboard layouts and keybindings, including specialized layouts for coding and productivity.

## Installation

Install [chezmoi](https://www.chezmoi.io/install/) for your platform first. Applications and their dependencies must be installed separately.

```bash
# Download the source without applying it
chezmoi init https://github.com/Orangex-position0/dotfiles.git

# Inspect the source location, managed targets and proposed changes
chezmoi source-path
chezmoi managed
chezmoi diff

# Apply only after reviewing and adapting the configuration
chezmoi apply
```

Back up existing files before applying. These are personal configurations: `.zshrc` includes a machine-specific Miniconda path, Homebrew plugin loading and proxy port `7897`. The `.config/zsh` symlink points to `../config-collections/zsh/.config/zsh`, whose destination is not included in this repository. Review these paths and required tools first.

## Daily Maintenance

```bash
# Edit a managed target's source, preview, then deploy
chezmoi edit ~/.zshrc
chezmoi diff ~/.zshrc
chezmoi apply ~/.zshrc

# Import changes made directly to a target back into the source
chezmoi add ~/.zshrc

# Enter the source repository to review and commit changes
chezmoi cd
git status
```

For Zed, edit the shared templates directly rather than importing rendered target files. Changes to the source are not deployed until `chezmoi apply` runs, and are not shared with other machines until committed and pushed.

Optional Git hook setup, from the source repository:

```bash
bash scripts/install-hooks.sh
```

This sets `core.hooksPath` to `.githooks/`. The pre-push hook blocks branch pushes when its merge-base check finds the local branch behind the remote; it does not modify local history.

## Documentation

- [Historical Claude skills documentation](docs/Claude-skills.md)
- [Keyboard layouts](keyboard-layouts/readme-keyboard-layouts.md)

## Contributing

These configurations are personalized for my workflow. Feel free to fork and adapt them for your own needs.

## License

No repository-wide `LICENSE` file is currently present. Do not assume an MIT license; confirm applicable permissions before redistribution.

