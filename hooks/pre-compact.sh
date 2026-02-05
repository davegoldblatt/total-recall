#!/usr/bin/env bash
# Total Recall — PreCompact Hook
#
# Fires before context compaction. Writes a compaction marker to today's
# daily log. Does NOT read or parse conversation transcripts.
#
# Hook input: JSON object on stdin (ignored — we only write files).

set -euo pipefail

# Use Claude Code's project dir env var, fall back to git root or cwd
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
MEMORY_DIR="$PROJECT_ROOT/memory"
TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%H:%M)"
DAILY="$MEMORY_DIR/daily/$TODAY.md"

# Bail if memory system isn't initialized
if [ ! -d "$MEMORY_DIR/daily" ]; then
  exit 0
fi

# Create today's daily log if it doesn't exist
if [ ! -f "$DAILY" ]; then
  cat > "$DAILY" << EOF
# $TODAY

## Decisions

## Corrections

## Commitments

## Open Loops

## Notes
EOF
fi

# Drain stdin so the hook doesn't hang
if ! [ -t 0 ]; then
  cat > /dev/null
fi

# Append compaction marker
echo "" >> "$DAILY"
echo "## [pre-compact $NOW]" >> "$DAILY"
echo "" >> "$DAILY"
echo "- Compaction occurred at $NOW. Review recent work and use /recall-write to preserve anything important." >> "$DAILY"
echo "" >> "$DAILY"
