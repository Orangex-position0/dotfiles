# Introduction

This repo is my dotfiles collection, managed by [chezmoi](https://www.chezmoi.io/). It contains configuration files for various development tools and applications.

English | [简体中文](README.zh-CN.md)

## Overview

- `dot_claude/` - Claude Code configuration and custom skills
- `dot_ideavimrc` - IdeaVim configuration file for JetBrains IDEs
- `dot_config/yasb/` - YASB (Yet Another Status Bar) configuration files
- `dot_glzr/glazewm/` - GlazeWM configuration files for Windows tiling window manager
- `dot_config/zed/` - Zed editor configuration (macOS/Linux)
- `AppData/Roaming/Zed/` - Zed editor configuration (Windows)
- `keyboard-layouts/` - Custom keyboard layouts and keybindings
- `docs/` - Documentation for custom tools and configurations

## Claude Code Configuration

### Custom Skills

I have developed several custom skills for Claude Code to enhance my workflow:

- **PPP Generator** - Generate structured work reports using Progress-Plans-Problems format
- **Tech Blog Coach** - Technical writing coach based on Feynman Learning Method
- **Skill Creator** - Guide for creating effective Claude Code skills

📖 **Detailed documentation:** [Claude Skills Documentation](docs/Claude-skills.md)

### Configuration

My Claude Code configuration follows these principles:

- **Language:** Default to Simplified Chinese for communication
- **Code Style:** Readability-first, DRY, High Cohesion & Low Coupling
- **Architecture:** Domain-Driven Design (DDD) with SOLID principles
- **Documentation:** Unified documentation maintenance, no redundant summary files

## Zed

Cross-platform Zed editor configuration using chezmoi's shared template mechanism (`.chezmoitemplates/`). The same settings and keymap are deployed to platform-specific paths:

- **Windows:** `AppData/Roaming/Zed/`
- **macOS / Linux:** `~/.config/zed/`

To modify Zed config, edit the shared files in `.chezmoitemplates/` — changes apply to all platforms automatically.

## IdeaVim

IdeaVim configuration for JetBrains IDEs (IntelliJ IDEA, PyCharm, etc.) with custom keybindings optimized for development workflow.

## GlazeWM

Windows tiling window manager configuration for efficient window management and productivity.

## YASB

Custom status bar configuration for Windows, providing system information and quick access to common functions.

## Keyboard Layouts

Custom keyboard layouts and keybindings, including specialized layouts for coding and productivity.

## Installation

This repository is managed using chezmoi. To install these dotfiles on a new machine:

```bash
# Install chezmoi
curl -fsSL https://chezmoi.io/get | sh

# Initialize the repository
chezmoi init https://github.com/yourusername/yourrepo.git

# Apply the dotfiles
chezmoi apply
```

## Contributing

These configurations are personalized for my workflow. Feel free to fork and adapt them for your own needs.

## License

This repository is licensed under the MIT License.

