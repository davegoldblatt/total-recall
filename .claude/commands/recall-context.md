Show what memory context is currently available in this session.

## What To Do

### 1. Check What Exists

Read and report on what memory files are present and accessible:

**Always loaded:**
- memory/MEMORY.md — exists? Word count?
- memory/SCHEMA.md — exists?

**Session context:**
- Today's daily log (memory/daily/[today].md) — exists? Entry count?
- Yesterday's daily log — exists?
- memory/registers/open-loops.md — exists? Active items?

**Available on demand:**
- List all register files in memory/registers/
- List recent daily logs (last 7 days)
- List archive files

### 2. Display

```
Memory Context — Current Session
─────────────────────────────────

Loaded:
  MEMORY.md           ✓  [N] words
  SCHEMA.md           ✓

Session:
  daily/[today].md    ✓  [N] entries
  daily/[yesterday]   ✓  [N] entries
  open-loops.md       ✓  [N] active items

Available registers:
  people.md           [N] entries
  projects.md         [N] entries
  decisions.md        [N] entries
  preferences.md      [N] entries
  tech-stack.md       [N] entries

Archive:
  [N] files available for search

Use /recall-search <query> to pull specific context from any tier.
```

### 3. Highlight Gaps

If any expected files are missing, note them:
```
Missing:
  ✗ memory/SCHEMA.md — run /recall-init to create
  ✗ No daily log for today — will be created on first /recall-write
```
