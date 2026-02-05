#!/usr/bin/env bash
# Total Recall — PreCompact Hook
#
# Fires before context compaction. Writes a compaction marker to today's
# daily log and attempts to extract recent context from the transcript.
#
# This is a safety net — the protocol in .claude/rules/ also instructs
# Claude to flush before compaction, but this hook ensures at minimum
# a marker and recent turns get captured even if Claude doesn't.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
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

# Read the transcript from stdin if provided
# PreCompact hook receives JSON on stdin with transcript info
TRANSCRIPT_PATH=""
if ! [ -t 0 ]; then
  INPUT=$(cat)
  # Try to extract transcript_path from JSON input
  TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # Navigate possible JSON structures
    if isinstance(data, dict):
        print(data.get('transcript_path', data.get('transcriptPath', '')))
except:
    pass
" 2>/dev/null || echo "")
fi

# Append compaction marker
echo "" >> "$DAILY"
echo "## [pre-compact $NOW]" >> "$DAILY"

if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  # Extract last few user messages from the JSONL transcript as context breadcrumbs
  echo "" >> "$DAILY"
  echo "Recent context before compaction:" >> "$DAILY"
  echo "" >> "$DAILY"

  # Get the last 10 user turns from the transcript
  python3 -c "
import json, sys

turns = []
try:
    with open('$TRANSCRIPT_PATH', 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
                role = entry.get('role', '')
                if role == 'user':
                    content = entry.get('content', '')
                    if isinstance(content, list):
                        texts = [b.get('text', '') for b in content if b.get('type') == 'text']
                        content = ' '.join(texts)
                    if isinstance(content, str) and content.strip():
                        # Truncate long messages
                        text = content.strip()[:200]
                        turns.append(text)
            except json.JSONDecodeError:
                continue
except Exception:
    pass

# Print last 5 user messages
for t in turns[-5:]:
    print(f'- {t}')
" >> "$DAILY" 2>/dev/null || echo "- (could not extract transcript context)" >> "$DAILY"

else
  echo "- Compaction occurred. No transcript available for extraction." >> "$DAILY"
  echo "- Check that any unsaved decisions/corrections were flushed above." >> "$DAILY"
fi

echo "" >> "$DAILY"
