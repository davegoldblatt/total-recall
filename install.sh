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

# ─────────────────────────────────────────────────────────
# 1. Slash commands
# ─────────────────────────────────────────────────────────
echo "Installing commands..."
mkdir -p "$TARGET/.claude/commands"
for cmd in "$SCRIPT_DIR/.claude/commands"/recall-*.md; do
  filename="$(basename "$cmd")"
  if [ -f "$TARGET/.claude/commands/$filename" ]; then
    echo "  ~ $filename (already exists, skipping)"
  else
    cp "$cmd" "$TARGET/.claude/commands/$filename"
    echo "  + $filename"
  fi
done

# ─────────────────────────────────────────────────────────
# 2. Protocol rules (auto-loaded by Claude Code)
# ─────────────────────────────────────────────────────────
echo ""
echo "Installing protocol rules..."
mkdir -p "$TARGET/.claude/rules"
if [ -f "$TARGET/.claude/rules/total-recall.md" ]; then
  echo "  ~ .claude/rules/total-recall.md (already exists, skipping)"
else
  cp "$SCRIPT_DIR/.claude/rules/total-recall.md" "$TARGET/.claude/rules/total-recall.md"
  echo "  + .claude/rules/total-recall.md (auto-loads every session)"
fi

# ─────────────────────────────────────────────────────────
# 3. Working memory (CLAUDE.local.md — personal, gitignored)
# ─────────────────────────────────────────────────────────
echo ""
echo "Setting up working memory..."
if [ -f "$TARGET/CLAUDE.local.md" ]; then
  if grep -q "Working Memory" "$TARGET/CLAUDE.local.md" 2>/dev/null; then
    echo "  ~ CLAUDE.local.md (already has working memory, skipping)"
  else
    echo ""
    echo "  ! CLAUDE.local.md exists but doesn't contain Total Recall working memory."
    echo "    You can append the template manually from: $SCRIPT_DIR/templates/CLAUDE.local.md"
  fi
else
  cp "$SCRIPT_DIR/templates/CLAUDE.local.md" "$TARGET/CLAUDE.local.md"
  echo "  + CLAUDE.local.md (auto-loads every session, personal memory)"
fi

# Add CLAUDE.local.md to .gitignore
if [ -f "$TARGET/.gitignore" ]; then
  if ! grep -q "CLAUDE.local.md" "$TARGET/.gitignore" 2>/dev/null; then
    echo "CLAUDE.local.md" >> "$TARGET/.gitignore"
    echo "  + Added CLAUDE.local.md to .gitignore"
  fi
else
  echo "CLAUDE.local.md" > "$TARGET/.gitignore"
  echo "  + Created .gitignore with CLAUDE.local.md"
fi

# ─────────────────────────────────────────────────────────
# 4. Memory directory structure + templates
# ─────────────────────────────────────────────────────────
echo ""
echo "Scaffolding memory system..."
mkdir -p "$TARGET/memory/daily" "$TARGET/memory/registers" "$TARGET/memory/archive/projects" "$TARGET/memory/archive/daily"

# SCHEMA.md
if [ -f "$TARGET/memory/SCHEMA.md" ]; then
  echo "  ~ memory/SCHEMA.md (already exists, skipping)"
else
  cp "$SCRIPT_DIR/templates/SCHEMA.md" "$TARGET/memory/SCHEMA.md"
  echo "  + memory/SCHEMA.md"
fi

# Register templates
for tmpl in "$SCRIPT_DIR/templates/registers"/*.md; do
  filename="$(basename "$tmpl")"
  if [ -f "$TARGET/memory/registers/$filename" ]; then
    echo "  ~ memory/registers/$filename (already exists, skipping)"
  else
    cp "$tmpl" "$TARGET/memory/registers/$filename"
    echo "  + memory/registers/$filename"
  fi
done

# ─────────────────────────────────────────────────────────
# 5. Hooks (in .claude/hooks/ — conventional location)
# ─────────────────────────────────────────────────────────
echo ""
echo "Installing hooks..."
mkdir -p "$TARGET/.claude/hooks"

for hook in "$SCRIPT_DIR/.claude/hooks"/*.sh; do
  filename="$(basename "$hook")"
  if [ -f "$TARGET/.claude/hooks/$filename" ]; then
    echo "  ~ .claude/hooks/$filename (already exists, skipping)"
  else
    cp "$hook" "$TARGET/.claude/hooks/$filename"
    chmod +x "$TARGET/.claude/hooks/$filename"
    echo "  + .claude/hooks/$filename"
  fi
done

# Configure hooks in .claude/settings.local.json (personal, not committed)
SETTINGS="$TARGET/.claude/settings.local.json"
if [ -f "$SETTINGS" ]; then
  if grep -q "session-start\|pre-compact" "$SETTINGS" 2>/dev/null; then
    echo "  ~ .claude/settings.local.json (hooks already configured, skipping)"
  else
    echo ""
    echo "  ! .claude/settings.local.json exists. Add hooks manually:"
    echo '    "hooks": {'
    echo '      "SessionStart": [{"hooks":[{"type":"command","command":"\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh"}]}],'
    echo '      "PreCompact": [{"hooks":[{"type":"command","command":"\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh"}]}]'
    echo '    }'
  fi
else
  cat > "$SETTINGS" << 'SETTINGS_EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  echo "  + .claude/settings.local.json (SessionStart + PreCompact hooks)"
fi

# ─────────────────────────────────────────────────────────
# 6. CLAUDE.md (supplementary docs — safe to commit)
# ─────────────────────────────────────────────────────────
echo ""
echo "Configuring CLAUDE.md..."
if [ -f "$TARGET/CLAUDE.md" ]; then
  if grep -q "Total Recall" "$TARGET/CLAUDE.md" 2>/dev/null; then
    echo "  ~ CLAUDE.md already has Total Recall reference (skipping)"
  else
    echo "" >> "$TARGET/CLAUDE.md"
    cat "$SCRIPT_DIR/CLAUDE.md" >> "$TARGET/CLAUDE.md"
    echo "  + Appended Total Recall reference to existing CLAUDE.md"
  fi
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  + CLAUDE.md (supplementary docs)"
fi

# ─────────────────────────────────────────────────────────
# 7. Today's daily log
# ─────────────────────────────────────────────────────────
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
  echo "  + memory/daily/$TODAY.md (today's log)"
fi

# ─────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total Recall installed."
echo ""
echo "What auto-loads every session (deterministic):"
echo "  .claude/rules/total-recall.md   Memory protocol"
echo "  CLAUDE.local.md                 Working memory"
echo ""
echo "Hooks (in .claude/settings.local.json):"
echo "  SessionStart    Injects open loops + recent context"
echo "  PreCompact      Flushes to daily log before compaction"
echo ""
echo "IMPORTANT: If Claude Code is already running, restart it or"
echo "run /hooks to review and activate the new hooks."
echo ""
echo "Commands:"
echo "  /recall-write <note>    Save to daily log (promotes on request)"
echo "  /recall-search <query>  Search all memory tiers"
echo "  /recall-status          Memory health check"
echo "  /recall-promote         Review daily logs for promotion"
echo ""
echo "Privacy: CLAUDE.local.md is gitignored (personal memory)."
echo "Consider adding memory/ to .gitignore for personal projects."
echo ""
echo "Docs: memory/SCHEMA.md"
