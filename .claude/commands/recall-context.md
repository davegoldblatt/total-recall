Show what memory context is currently available in this session.

## What To Do

### 1. Check What's Auto-Loaded

These files load automatically via Claude Code's native mechanisms:

**Via .claude/rules/ (deterministic):**
- .claude/rules/total-recall.md — memory protocol

**Via CLAUDE.local.md (deterministic):**
- CLAUDE.local.md — working memory

### 2. Check What Exists On Disk

Read and report on what memory files are present:

**Schema:**
- memory/SCHEMA.md — exists?

**Daily Logs:**
- Today's log (memory/daily/[today].md) — exists? Entry count?
- Yesterday's log — exists?

**Registers:**
- List all .md files in memory/registers/ with entry counts

**Archive:**
- List files in memory/archive/

### 3. Display

```
Memory Context — Current Session
─────────────────────────────────

Auto-loaded (deterministic):
  .claude/rules/total-recall.md   ✓  Protocol rules
  CLAUDE.local.md                 ✓  Working memory ([N] words)

On disk:
  memory/SCHEMA.md                ✓  Protocol docs
  memory/daily/[today].md         ✓  [N] entries
  memory/daily/[yesterday].md     ✓  [N] entries
  memory/registers/open-loops.md  ✓  [N] active items

Available registers:
  people.md           [N] entries
  projects.md         [N] entries
  decisions.md        [N] entries
  preferences.md      [N] entries
  tech-stack.md       [N] entries

Archive: [N] files

Hooks:
  SessionStart    [configured/not configured]
  PreCompact      [configured/not configured]
```

### 4. Highlight Gaps

If expected files are missing:
```
Missing:
  ✗ CLAUDE.local.md — run /recall-init to create
  ✗ No daily log for today — will be created on first /recall-write
```

### 5. Quick Actions

```
Use /recall-search <query> to pull context from any tier.
Use /recall-status for memory health metrics.
```
