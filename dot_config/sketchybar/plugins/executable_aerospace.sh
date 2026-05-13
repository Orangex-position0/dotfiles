#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  # 焦点工作区：背景色高亮 + 显示
  sketchybar --set $NAME \
    drawing=on \
    background.color=0xff003547 \
    icon.color=0xffffffff \
    icon.padding_left=8 \
    background.border_width=2 \
    label.shadow.drawing=on \
    icon.shadow.drawing=on
else
  # 检查工作区是否有窗口
  has_windows=$(aerospace list-windows --workspace "$1" 2>/dev/null | grep -c "^." || echo "0")

  if [ "$has_windows" -gt 0 ]; then
    # 有应用的工作区：正常显示
    sketchybar --set $NAME \
      drawing=on \
      background.color=0x44ffffff \
      icon.color=0xffffffff \
      icon.padding_left=6 \
      background.border_width=0 \
      label.shadow.drawing=off \
      icon.shadow.drawing=off
  else
    # 空工作区：隐藏
    sketchybar --set $NAME \
      drawing=off
  fi
fi