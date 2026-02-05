Review recent daily logs and surface candidates for promotion to registers or CLAUDE.local.md.

## What To Do

### 1. Gather Recent Logs

Read all daily log files from the last 7 days (memory/daily/YYYY-MM-DD.md).

If no daily logs exist, tell the user:
```
No daily logs found. Use /recall-write or /recall-log to start capturing.
```

### 2. Identify Promotion Candidates

Scan each entry and evaluate:

**Promote to CLAUDE.local.md if:**
- Active commitment or deadline that affects every session
- Behavioral preference that changes default output
- Current project state that's essential context

**Promote to a register if:**
- Decision with rationale → decisions.md
- Person context → people.md
- Technical choice → tech-stack.md
- Preference with staying power → preferences.md
- Project milestone or state change → projects.md

**Skip if:**
- Already captured in a register or CLAUDE.local.md
- One-off observation with no future impact
- Debugging detail or transient state

### 3. Present Candidates

For each candidate, show:

```
Candidates for promotion:

1. [2026-02-03] "Project deadline moved to March 15"
   → Suggest: CLAUDE.local.md (active commitment)

2. [2026-02-02] "Prefers tabs over spaces, 2-space indent"
   → Suggest: registers/preferences.md

3. [2026-02-01] "Decided to use Postgres over SQLite for scale"
   → Suggest: registers/decisions.md
```

### 4. Ask User

For each candidate, ask the user what to do:
- **Promote** — write to the suggested destination
- **Register** — write to a different register (ask which one)
- **Skip** — don't promote, leave in daily log
- **Promote all** — accept all suggestions at once

### 5. Execute

For each promoted item:
1. Write to the destination with proper metadata (claim, confidence, evidence, last_verified)
2. Do NOT remove from daily log (daily logs are append-only history)
3. Check for contradictions with existing entries before writing

### 6. Summary

```
Promotion complete:
  → 2 entries promoted to registers
  → 1 entry promoted to CLAUDE.local.md
  → 1 entry skipped

CLAUDE.local.md word count: [N]/1500
```

Warn if CLAUDE.local.md is approaching the 1500 word limit.
