# Total Recall — Memory Schema

> This file teaches Claude how the memory system works.
> Read it on session start for reference. The protocol rules
> auto-load via `.claude/rules/total-recall.md`.

---

## How Memory Works

You have a persistent memory system with four tiers. Data flows upward through compression (raw → structured → essential → archived) and is retrieved downward on demand.

### What Loads Automatically (Deterministic)

These files are loaded by Claude Code's native mechanisms — no action needed:

| File | Mechanism | Purpose |
|------|-----------|---------|
| `.claude/rules/total-recall.md` | Auto-loaded via rules/ | Memory protocol and write gate rules |
| `CLAUDE.local.md` | Auto-loaded via Claude Code | Working memory (~1500 words) |

### What To Check On Session Start

Read these proactively at the start of each session:

| File | Purpose |
|------|---------|
| `memory/registers/open-loops.md` | Active follow-ups and deadlines |
| `memory/daily/[today].md` | Today's daily log |
| `memory/daily/[yesterday].md` | Yesterday's daily log |
| `memory/registers/_index.md` | What registers exist |

### What To Search On Demand

| Location | Search When |
|----------|-------------|
| `memory/registers/people.md` | A person is mentioned |
| `memory/registers/projects.md` | A project is discussed |
| `memory/registers/decisions.md` | Past choices are questioned |
| `memory/registers/preferences.md` | Style/approach matters |
| `memory/registers/tech-stack.md` | Technical choices come up |
| `memory/archive/` | Historical context needed |

**Do NOT load everything.** Pull only what's relevant.

---

## Tier Architecture

```
Conversation (ephemeral — compacted/discarded)
    │
    ▼ WRITE GATE: "Does this change future behavior?"
    │
Daily Log (memory/daily/YYYY-MM-DD.md)
    Raw timestamped capture. All writes land here first.
    │
    ▼ PROMOTION: "Will this matter in 30 days?"
    │
Registers (memory/registers/*.md)
    Structured domain knowledge with metadata.
    │
    ▼ DISTILLATION: "Essential for every session?"
    │
Working Memory (CLAUDE.local.md)
    ~1500 words. Auto-loaded. Only behavior-changing facts.
    │
    ▼ EXPIRY: "Completed or superseded?"
    │
Archive (memory/archive/)
    Searchable history. Never auto-loaded.
```

---

## The Write Gate

Before writing ANYTHING to memory:

1. **Does it change future behavior?** → WRITE
2. **Is it a commitment with consequences?** → WRITE
3. **Is it a decision with rationale?** → WRITE
4. **Is it a stable fact that will matter again?** → WRITE
5. **Did the user explicitly say "remember this"?** → ALWAYS WRITE

If NONE are true → **DO NOT WRITE.**

### Default Destination: Daily Log

All writes go to `memory/daily/YYYY-MM-DD.md` first. Promotion to registers or CLAUDE.local.md is a separate step — suggest it, but let the user decide.

### Exceptions (Direct Promotion)

- **Corrections** — update the register immediately, mark old as superseded
- **Explicit "remember this"** — write to appropriate register directly
- **Deadlines/commitments** — always go to open-loops.md + daily log

---

## Routing Table

| Trigger | Primary Destination | Also Update |
|---------|-------------------|-------------|
| User says "remember" | Daily log + register | CLAUDE.local.md if behavioral |
| User corrects Claude | Supersede old + write new | ALL locations with old claim |
| Decision with rationale | Daily log, suggest decisions.md | CLAUDE.local.md if current |
| New person context | Daily log, suggest people.md | CLAUDE.local.md if active |
| Preference expressed | Daily log, suggest preferences.md | CLAUDE.local.md if default |
| Commitment/deadline | Daily log + open-loops.md | CLAUDE.local.md always |
| Technical choice | Daily log, suggest tech-stack.md | — |

---

## Contradiction Protocol

When new information contradicts existing memory:

1. **NEVER silently overwrite.**
2. Mark old entry as `[superseded: YYYY-MM-DD]` with reason
3. Write new entry with reference to what it replaces
4. If confidence is low, ask the user to confirm

```markdown
## [superseded: 2026-02-05]
- **claim**: Budget is $400K
- **superseded_by**: Budget increased to $500K (finance email, 2026-02-05)

## [current]
- **claim**: Budget is $500K
- **confidence**: high
- **evidence**: Finance email, confirmed by user
- **last_verified**: 2026-02-05
```

---

## Correction Gate

Human corrections are the highest-priority write signal:

1. **Write immediately** to the daily log
2. **Update the relevant register** with superseded marking
3. **Update CLAUDE.local.md** if it changes default behavior
4. **Search everywhere** for the old claim and update all instances

### Correction Severity

| Type | Write To | Example |
|------|----------|---------|
| Behavioral | CLAUDE.local.md + register + daily | "Don't send emails without asking" |
| Factual | Register + daily | "Budget is $500K, not $400K" |
| Style | Preferences + CLAUDE.local.md if default | "Stop using headers in messages" |
| One-off | Daily log only | "Use blue logo for this deck" |

---

## Register Entry Schema

For durable claims in registers, include metadata:

```markdown
- **claim**: [the fact, preference, or decision]
- **confidence**: high | medium | low
- **evidence**: [source — user said, observed, document, corrected]
- **last_verified**: YYYY-MM-DD
```

Not every line needs full metadata. Use it for claims where being wrong has consequences.

---

## Entry IDs and the Remove Gate

Entries in managed files (CLAUDE.local.md, registers, archive) can have durable IDs for tracking and maintenance.

### ID Format

Each managed entry ends with an inline ID token:

```
- Dave prefers concise error messages ^tr8f2a1c3d7e
```

- Format: `^tr` + 10 lowercase hex characters
- Regex: `\^tr[0-9a-f]{10}$`
- IDs are visible, auditable, and user-editable

### What Gets an ID

- Single-line list items (`- text here`) in CLAUDE.local.md, registers, and archive
- NOT daily log entries (daily logs are not managed by the remove gate)
- NOT multi-line metadata blocks (claim/confidence/evidence/last_verified)
- NOT lines inside fenced code blocks
- NOT placeholder entries like `- [None captured yet]`

### Sidecar Metadata

Entry metadata lives in `memory/.recall/metadata.json`:

```json
{
  "tr8f2a1c3d7e": {
    "created_at": "2026-02-12T10:15:30Z",
    "last_reviewed_at": "2026-02-12T10:15:30Z",
    "pinned": false,
    "snoozed_until": null,
    "status": "active",
    "tier": "working"
  }
}
```

- `status`: `active`, `superseded`, or `archived`
- `tier`: `working`, `register`, or `archive` (derived from file location - file wins)
- `pinned`: if true, entry is excluded from pressure-based demotion
- `snoozed_until`: if set and in the future, entry is excluded from demotion

### Pressure-Based Demotion

When working memory (CLAUDE.local.md) exceeds the 1500-word target, `/recall-maintain` surfaces demotion candidates scored by word cost and staleness. Users choose per-entry: keep, pin, snooze, demote (to `registers/_inbox.md`), archive (to `archive/ARCHIVE.md`), or mark superseded.

### Commands

- `/recall-init-ids` - Add IDs to untagged entries (run before first maintain)
- `/recall-maintain` - Pressure-based cleanup with pin/snooze/demote/archive

---

## Hooks

If configured in `.claude/settings.json`:

**SessionStart** — Injects open loops and recent daily log highlights as additional session context.

**PreCompact** — Writes a `[pre-compact]` marker to today's daily log and captures recent conversation context before compaction discards it.

These are safety nets. The protocol in `.claude/rules/total-recall.md` also instructs Claude to flush before compaction — the hooks ensure it happens even if the protocol isn't followed.

---

## Maintenance Cadences

| Cadence | Trigger | Action |
|---------|---------|--------|
| Immediate | Correction or significant event | Write to daily log + register as needed |
| End-of-session | Session ending or compaction | Flush unsaved decisions, corrections, commitments |
| Periodic (weekly) | `/recall-maintain` | Verify stale entries, prune CLAUDE.local.md, promote |
| Quarterly | `/recall-maintain` | Distill registers into archive, reset cruft |

---

## CLAUDE.local.md Limits

- **Hard cap**: ~1500 words
- **Review**: Every few days
- **Rule**: If something hasn't been relevant in 2+ weeks, demote to register or delete
- **Every line earns its place**: Active goals, current commitments, behavioral preferences, recent corrections, open loops

---

## Commands Reference

| Command | Purpose |
|---------|---------|
| `/recall-init` | Scaffold the memory system |
| `/recall-init-ids` | Add durable IDs to memory entries |
| `/recall-write <note>` | Write to daily log with gate evaluation |
| `/recall-log <note>` | Quick append, no gate |
| `/recall-search <query>` | Search all tiers |
| `/recall-promote` | Review daily logs for promotion |
| `/recall-status` | Memory health check |
| `/recall-maintain` | Pressure-based cleanup with demotion and archival |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show loaded memory context |
