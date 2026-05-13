#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"

# 简化的工作区状态更新函数
update_space_icons() {
    local sid=$1
    local focused_workspace=$(aerospace list-workspaces --focused 2>/dev/null)
    local has_windows=$(aerospace list-windows --workspace "$sid" 2>/dev/null | grep -c "^." || echo "0")

    if [ "$has_windows" -gt 0 ] || [ "$sid" = "$focused_workspace" ]; then
        # 有应用或焦点工作区：显示工作区
        sketchybar --set space.$sid drawing=on icon.color=0xffffffff
    else
        # 空工作区且非焦点：隐藏
        sketchybar --set space.$sid drawing=off
    fi
}

# Update all workspaces to ensure clean state
for monitor in $(aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}"); do
    for sid in $(aerospace list-workspaces --monitor "$monitor"); do
        update_space_icons "$sid"
    done
done