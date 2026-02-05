#!/usr/bin/env bash
# Total Recall — SessionStart Hook
#
# Fires on session start. Stdout is injected as additional context.
# Reads open loops and recent daily log highlights to prime the session.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEMORY_DIR="$PROJECT_ROOT/memory"

# Bail if memory system isn't initialized
if [ ! -d "$MEMORY_DIR" ]; then
  exit 0
fi

TODAY="$(date +%Y-%m-%d)"
YESTERDAY="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d 2>/dev/null || echo '')"

echo "## Total Recall — Session Context"
echo ""

# Open loops (always relevant)
OPEN_LOOPS="$MEMORY_DIR/registers/open-loops.md"
if [ -f "$OPEN_LOOPS" ]; then
  # Check if there are actual items (not just template comments)
  ACTIVE_ITEMS=$(grep -c '^\- \[ \]' "$OPEN_LOOPS" 2>/dev/null || echo "0")
  if [ "$ACTIVE_ITEMS" -gt 0 ]; then
    echo "### Open Loops ($ACTIVE_ITEMS active)"
    grep '^\- \[ \]' "$OPEN_LOOPS" 2>/dev/null || true
    echo ""
  fi
fi

# Today's daily log
DAILY_TODAY="$MEMORY_DIR/daily/$TODAY.md"
if [ -f "$DAILY_TODAY" ]; then
  LINES=$(wc -l < "$DAILY_TODAY" | tr -d ' ')
  if [ "$LINES" -gt 5 ]; then
    echo "### Today's Log ($TODAY) — $LINES lines"
    # Show last 20 lines as recent context
    tail -20 "$DAILY_TODAY"
    echo ""
  fi
fi

# Yesterday's daily log (brief)
if [ -n "$YESTERDAY" ]; then
  DAILY_YESTERDAY="$MEMORY_DIR/daily/$YESTERDAY.md"
  if [ -f "$DAILY_YESTERDAY" ]; then
    echo "### Yesterday's Log ($YESTERDAY)"
    # Show just decisions, corrections, and commitments sections
    grep -A2 '## Decisions\|## Corrections\|## Commitments\|## Open Loops' "$DAILY_YESTERDAY" 2>/dev/null | head -20 || true
    echo ""
  fi
fi

# Word count on working memory
if [ -f "$PROJECT_ROOT/CLAUDE.local.md" ]; then
  WORD_COUNT=$(wc -w < "$PROJECT_ROOT/CLAUDE.local.md" | tr -d ' ')
  if [ "$WORD_COUNT" -gt 1200 ]; then
    echo "**Warning**: Working memory (CLAUDE.local.md) at $WORD_COUNT words (limit: 1500). Consider pruning."
    echo ""
  fi
fi
