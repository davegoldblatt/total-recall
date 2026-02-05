#!/usr/bin/env bash
# Total Recall — PreCompact Hook
#
# Fires before context compaction. Writes a compaction marker to today's
# daily log. Transcript extraction is OPT-IN via RECALL_EXTRACT_TRANSCRIPT=1
# to comply with Anthropic's directory policy.
#
# Hook input: JSON object on stdin with transcript_path field.
# Transcript file: JSONL (one JSON object per line).

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

# Read hook input from stdin (JSON with transcript_path)
TRANSCRIPT_PATH=""
if ! [ -t 0 ]; then
  INPUT=$(cat)
  TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('transcript_path', ''))
except:
    pass
" 2>/dev/null || echo "")
fi

# Append compaction marker (always — this is safe)
echo "" >> "$DAILY"
echo "## [pre-compact $NOW]" >> "$DAILY"
echo "" >> "$DAILY"
echo "- Compaction occurred at $NOW." >> "$DAILY"

# Transcript extraction is OPT-IN only.
# Set RECALL_EXTRACT_TRANSCRIPT=1 in your environment to enable.
# This reads recent user messages from the conversation transcript
# to preserve context across compaction.
if [ "${RECALL_EXTRACT_TRANSCRIPT:-0}" = "1" ] && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  echo "" >> "$DAILY"
  echo "Recent context before compaction:" >> "$DAILY"
  echo "" >> "$DAILY"

  # Transcript is JSONL — one JSON object per line
  python3 -c "
import json

turns = []
try:
    with open('$TRANSCRIPT_PATH', 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            role = entry.get('role', '')
            if role == 'user':
                content = entry.get('content', '')
                if isinstance(content, list):
                    texts = [b.get('text', '') for b in content if b.get('type') == 'text']
                    content = ' '.join(texts)
                if isinstance(content, str) and content.strip():
                    turns.append(content.strip()[:200])
except Exception:
    pass

for t in turns[-5:]:
    print(f'- {t}')
" >> "$DAILY" 2>/dev/null || echo "- (could not extract transcript context)" >> "$DAILY"
fi

echo "" >> "$DAILY"
