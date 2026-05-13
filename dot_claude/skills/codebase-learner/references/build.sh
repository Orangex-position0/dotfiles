#!/bin/bash
# Assembles the course from parts.
# Run from the course directory: bash build.sh [--format html|markdown]
set -e

FORMAT="${1:-html}"

if [ "$FORMAT" = "html" ]; then
  # 验证必要文件存在
  if [ ! -f "_base.html" ]; then
    echo "Error: _base.html not found. Run from the course directory."
    exit 1
  fi
  if [ ! -d "modules" ]; then
    echo "Error: modules/ directory not found. No learning units to assemble."
    exit 1
  fi

  MODULE_COUNT=$(ls modules/*.html 2>/dev/null | wc -l)
  if [ "$MODULE_COUNT" -eq 0 ]; then
    echo "Error: No .html files found in modules/"
    exit 1
  fi

  cat _base.html modules/*.html _footer.html > index.html
  echo "Built index.html ($MODULE_COUNT modules) — open it in your browser."

elif [ "$FORMAT" = "markdown" ]; then
  # Markdown 模式：验证必要文件
  if [ ! -f "README.md" ]; then
    echo "Error: README.md not found. Run from the notes directory."
    exit 1
  fi

  MD_COUNT=$(ls [0-9]*.md 2>/dev/null | grep -v README.md | wc -l)
  echo "Markdown output ready: README.md + $MD_COUNT learning units."

else
  echo "Usage: bash build.sh [--format html|markdown]"
  echo "  html     — Assemble interactive HTML course (default)"
  echo "  markdown — Validate Markdown learning notes structure"
  exit 1
fi
