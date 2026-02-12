Show the health and status of the memory system.

## What To Do

### 1. Check Memory System Exists

If CLAUDE.local.md and memory/ directory don't exist:
```
Memory system not initialized. Run /recall-init to set up.
```

### 2. Gather Metrics

**CLAUDE.local.md (Working Memory):**
- Word count (target: under 1500)
- Last updated date
- Number of open loops listed

**Daily Logs (memory/daily/):**
- Total number of files
- Date range (oldest to newest)
- Total size
- Entries in last 7 days

**Registers (memory/registers/):**
- Number of register files
- Total size
- Count entries with `last_verified` dates older than 30 days (stale)
- Count entries marked `[superseded]`

**Archive (memory/archive/):**
- Number of files
- Total size

**Entry IDs (memory/.recall/metadata.json):**
- Count entries with `^tr` IDs (tagged) vs without (untagged) across managed files (CLAUDE.local.md, registers, archive)
- Count metadata.json entries total
- Count pinned entries
- Count snoozed entries (with active snooze)
- Count superseded entries

**Hooks:**
- Check .claude/settings.json or .claude/settings.local.json for SessionStart and PreCompact hook config

### 3. Display Status

```
Memory System Status
────────────────────

Working Memory:  [N] words ([N]% of 1500 limit)
  (CLAUDE.local.md)  Last updated: [date]
                     Open loops: [N]

Protocol:        .claude/rules/total-recall.md ✓
Schema:          memory/SCHEMA.md ✓

Daily logs:      [N] files, [size] total
                 Range: [oldest] → [newest]
                 Last 7 days: [N] entries

Registers:       [N] files, [size] total
                 Stale entries (>30 days): [N]
                 Superseded entries: [N]

Archive:         [N] files, [size] total

Entry IDs:       [N] tagged / [M] untagged
                 metadata.json: [N] entries
                 Pinned: [N], Snoozed: [N], Superseded: [N]

Hooks:
  SessionStart   [✓ configured / ✗ not configured]
  PreCompact     [✓ configured / ✗ not configured]
```

### 4. Recommendations

Based on metrics, suggest actions:

- If working memory > 1200 words: "Working memory approaching limit — consider archiving stale items"
- If stale entries > 0: "Run /recall-maintain to verify [N] stale entries"
- If no daily log in 3+ days: "No recent daily logs — memory capture may have gaps"
- If open loops > 5: "Consider reviewing open loops — some may be resolved"
- If registers are empty: "Registers are empty — use /recall-promote to populate from daily logs"
- If working memory stale (7+ days): "Working memory may be stale — review for accuracy"
- If hooks not configured: "Consider configuring SessionStart/PreCompact hooks for automated memory loading and flush"
- If untagged entries > 0: "Run /recall-init-ids to tag [N] untagged entries (required for /recall-maintain)"
- If superseded entries in metadata > 0: "Run /recall-maintain to clean up [N] superseded entries"
