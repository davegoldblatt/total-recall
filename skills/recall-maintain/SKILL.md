---
description: Verify stale memory entries, find contradictions, prune working memory.
disable-model-invocation: true
---
Run maintenance on the memory system: verify stale entries, find contradictions, clean up.

## What To Do

### 1. Verify Stale Entries

Search all register files for entries where `last_verified` is older than 30 days.

For each stale entry, present it to the user:
```
Stale entries needing verification:

1. [registers/tech-stack.md] Last verified: 2025-12-01
   "Using Node 18 in production"
   → Still accurate? [y]es / [u]pdate / [a]rchive

2. [registers/people.md] Last verified: 2025-11-15
   "Sarah is PM for Project Alpha"
   → Still accurate? [y]es / [u]pdate / [a]rchive
```

- **Yes**: Update `last_verified` to today
- **Update**: Ask for the new value, mark old as superseded, write new
- **Archive**: Move to memory/archive/ with context

### 2. Check for Contradictions

Scan across tiers for conflicting claims:
- Same topic with different values in different files
- MEMORY.md says one thing, a register says another
- Superseded entries that still appear as current elsewhere

Flag any found:
```
Potential contradictions:

1. MEMORY.md says "deadline is March 1"
   decisions.md says "deadline moved to March 15"
   → Which is current?
```

### 3. MEMORY.md Pruning

Review MEMORY.md for:
- Items that haven't been relevant in 2+ weeks
- Completed open loops that should be closed
- Information that belongs in a register rather than working memory
- Anything that doesn't change default session behavior

Suggest removals:
```
MEMORY.md pruning candidates:

1. "Project Beta on hold since January" — still relevant?
2. "Waiting on budget approval from Sarah" — resolved?

Current: [N] words. Target: under 1500.
```

### 4. Open Loop Review

Read memory/registers/open-loops.md. For each active item:
- Is it still open?
- Is it past due?
- Should it be escalated to MEMORY.md?

### 5. Daily Log Archival

If daily logs older than 30 days exist:
- Check if all significant content has been promoted to registers
- Suggest archiving old logs to memory/archive/daily/

### 6. Summary

```
Maintenance complete:
  Stale entries verified: [N]
  Contradictions found: [N]
  MEMORY.md pruned: [N] words removed
  Open loops reviewed: [N] active, [N] closed
  Daily logs archived: [N]

Next maintenance recommended: [date + 7 days]
```
