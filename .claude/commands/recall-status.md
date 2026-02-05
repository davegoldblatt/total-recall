Show the health and status of the memory system.

## What To Do

### 1. Check Memory System Exists

If memory/MEMORY.md doesn't exist:
```
Memory system not initialized. Run /recall-init to set up.
```

### 2. Gather Metrics

Read and analyze:

**MEMORY.md:**
- Word count (target: under 1500)
- Last updated date
- Number of open loops listed

**Daily Logs (memory/daily/):**
- Total number of files
- Date range (oldest → newest)
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

### 3. Display Status

```
Memory System Status
────────────────────

MEMORY.md:     [N] words ([N]% of 1500 limit)
               Last updated: [date]
               Open loops: [N]

Daily logs:    [N] files, [size] total
               Range: [oldest] → [newest]
               Last 7 days: [N] entries

Registers:     [N] files, [size] total
               Stale entries (>30 days): [N]
               Superseded entries: [N]

Archive:       [N] files, [size] total
```

### 4. Recommendations

Based on the metrics, suggest actions:

- If MEMORY.md > 1200 words: "MEMORY.md approaching limit — consider archiving stale items"
- If stale entries > 0: "Run /recall-maintain to verify [N] stale entries"
- If no daily log in 3+ days: "No recent daily logs — memory capture may have gaps"
- If open loops > 5: "Consider reviewing open loops — some may be resolved"
- If no registers populated: "Registers are empty — use /recall-promote to populate from daily logs"
- If MEMORY.md hasn't been updated in 7+ days: "MEMORY.md may be stale — review for accuracy"

### 5. Quick Actions

```
Quick actions:
  /recall-maintain     Verify stale entries and clean up
  /recall-promote      Review daily logs for promotion
  /recall-search       Find something in memory
```
