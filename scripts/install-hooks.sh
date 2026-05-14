#!/bin/bash
# 安装 git hooks

set -e

# 获取 chezmoi 仓库根目录
CHEZMOI_DIR="$(git rev-parse --show-toplevel)"

echo "🔧 Installing git hooks for chezmoi repository..."
echo "📁 Repository: $CHEZMOI_DIR"

# 配置 git 使用 .githooks 目录
git config core.hooksPath "$CHEZMOI_DIR/.githooks"

# 设置 hook 可执行权限
chmod +x "$CHEZMOI_DIR/.githooks/"*

echo "✅ Git hooks installed successfully!"
echo ""
echo "📝 Installed hooks:"
ls -1 "$CHEZMOI_DIR/.githooks/"
echo ""
echo "🚀 You can now use 'git push' normally. The hook will automatically check for remote updates."
