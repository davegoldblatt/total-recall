#!/usr/bin/env bash
set -euo pipefail

# Total Recall — Installer
# Installs the memory plugin into a Claude Code project.
#
# Usage:
#   ./install.sh                  # Install into current directory
#   ./install.sh /path/to/project # Install into specified project

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Resolve target to absolute path
TARGET="$(cd "$TARGET" && pwd)"

echo "Total Recall — Memory Plugin for Claude Code"
echo "Installing into: $TARGET"
echo ""

# 1. Copy slash commands
echo "Installing commands..."
mkdir -p "$TARGET/.claude/commands"
for cmd in "$SCRIPT_DIR/.claude/commands"/recall-*.md; do
  filename="$(basename "$cmd")"
  if [ -f "$TARGET/.claude/commands/$filename" ]; then
    echo "  ⊘ $filename (already exists, skipping)"
  else
    cp "$cmd" "$TARGET/.claude/commands/$filename"
    echo "  ✓ $filename"
  fi
done

# 2. Scaffold memory directory from templates
echo ""
echo "Scaffolding memory system..."
mkdir -p "$TARGET/memory/daily" "$TARGET/memory/registers" "$TARGET/memory/archive/projects" "$TARGET/memory/archive/daily"

for tmpl in "$SCRIPT_DIR/templates"/*.md; do
  filename="$(basename "$tmpl")"
  if [ -f "$TARGET/memory/$filename" ]; then
    echo "  ⊘ memory/$filename (already exists, skipping)"
  else
    cp "$tmpl" "$TARGET/memory/$filename"
    echo "  ✓ memory/$filename"
  fi
done

for tmpl in "$SCRIPT_DIR/templates/registers"/*.md; do
  filename="$(basename "$tmpl")"
  if [ -f "$TARGET/memory/registers/$filename" ]; then
    echo "  ⊘ memory/registers/$filename (already exists, skipping)"
  else
    cp "$tmpl" "$TARGET/memory/registers/$filename"
    echo "  ✓ memory/registers/$filename"
  fi
done

# 3. Append memory protocol to CLAUDE.md (or create it)
echo ""
echo "Configuring CLAUDE.md..."
if [ -f "$TARGET/CLAUDE.md" ]; then
  if grep -q "Total Recall" "$TARGET/CLAUDE.md" 2>/dev/null; then
    echo "  ⊘ CLAUDE.md already has Total Recall config (skipping)"
  else
    echo "" >> "$TARGET/CLAUDE.md"
    cat "$SCRIPT_DIR/CLAUDE.md" >> "$TARGET/CLAUDE.md"
    echo "  ✓ Appended memory protocol to existing CLAUDE.md"
  fi
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  ✓ Created CLAUDE.md with memory protocol"
fi

# 4. Create today's daily log
TODAY="$(date +%Y-%m-%d)"
DAILY="$TARGET/memory/daily/$TODAY.md"
if [ ! -f "$DAILY" ]; then
  cat > "$DAILY" << EOF
# $TODAY

## Decisions
- Total Recall memory system installed

## Corrections

## Commitments

## Open Loops

## Notes
- Memory system scaffolded and ready for use.
EOF
  echo ""
  echo "  ✓ Created today's daily log: memory/daily/$TODAY.md"
fi

# 5. Add memory/ to .gitignore suggestion
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total Recall installed successfully."
echo ""
echo "Quick start:"
echo "  /recall-write <note>    Save something to memory"
echo "  /recall-search <query>  Find in memory"
echo "  /recall-status          Check memory health"
echo "  /recall-promote         Review daily logs for promotion"
echo ""
echo "Note: Consider whether memory/ should be in .gitignore"
echo "(it may contain personal preferences, people context, etc.)"
echo ""
echo "See memory/SCHEMA.md for how the system works."
