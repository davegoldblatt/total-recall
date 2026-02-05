# Total Recall — Memory Schema

> This file teaches Claude how the memory system works.
> It is loaded every session alongside MEMORY.md.
> Do NOT delete or modify this file unless upgrading Total Recall.

---

## How Memory Works

You have a persistent memory system with four tiers. Data flows upward through compression (raw → structured → essential → archived) and is retrieved downward on demand (working memory → registers → daily logs → archive).

### Tier Architecture

| Tier | Location | Loaded | Purpose |
|------|----------|--------|---------|
| Working Memory | memory/MEMORY.md | Every session | Essential context (~1500 words). Only behavior-changing facts. |
| Registers | memory/registers/*.md | On demand | Structured domain knowledge with metadata. Searched when a topic arises. |
| Daily Logs | memory/daily/YYYY-MM-DD.md | Today + yesterday | Raw timestamped capture. Low ceremony, high fidelity. |
| Archive | memory/archive/ | On search only | Completed projects, superseded decisions, old logs. Never auto-loaded. |

### Data Flow

```
Conversation (ephemeral)
    │
    ▼ WRITE GATE: "Does this change future behavior?"
    │
Daily Log (raw capture)
    │
    ▼ PROMOTION: "Will this matter in 30 days?"
    │
Registers (structured knowledge)
    │
    ▼ DISTILLATION: "Is this essential for every session?"
    │
MEMORY.md (working memory)
    │
    ▼ EXPIRY: "Is this completed or superseded?"
    │
Archive (searchable history)
```

---

## The Write Gate

Before writing ANYTHING to memory, apply this gate:

1. **Does it change future behavior?** (preference, boundary, recurring pattern) → WRITE
2. **Is it a commitment with consequences?** (deadline, deliverable, follow-up) → WRITE
3. **Is it a decision with rationale?** (why X over Y, worth preserving) → WRITE
4. **Is it a stable fact that will matter again?** (not transient, not obvious) → WRITE
5. **Did the user explicitly say "remember this"?** → ALWAYS WRITE

If NONE of these are true → **DO NOT WRITE**. Resist the urge to log. The bar is: would a sharp chief of staff note this, or would only a junior analyst bother?

### Write — Examples

- "I prefer bullet points over prose" → preferences.md + MEMORY.md
- "The deadline is March 15" → open-loops.md + MEMORY.md
- "We chose Postgres because we need JSONB" → decisions.md
- "Sarah is the new PM, she prefers async" → people.md
- "Remember: never CC Dave on technical threads" → preferences.md + MEMORY.md

### Don't Write — Examples

- "Can you make that a bulleted list?" (one-off formatting, unless it's the third time)
- "Thanks, that looks good" (acknowledgment)
- "The error was on line 47" (debugging ephemera)
- "I'm working on the login page right now" (transient state)

---

## Routing Table

| Trigger | Primary Destination | Also Update |
|---------|-------------------|-------------|
| User says "remember" | Daily log + register if durable | MEMORY.md if behavioral |
| User corrects Claude | Supersede old + write new | ALL locations with old claim |
| Decision with rationale | registers/decisions.md | MEMORY.md if current |
| New person context | registers/people.md | MEMORY.md if actively engaging |
| Preference expressed | registers/preferences.md | MEMORY.md if affects defaults |
| Commitment/deadline | registers/open-loops.md | MEMORY.md always |
| Technical choice | registers/tech-stack.md | — |
| Project state change | registers/projects.md | MEMORY.md if active project |

---

## Contradiction Protocol

When new information contradicts existing memory:

1. **NEVER silently overwrite.** The pattern of change is information.
2. Mark the old entry as `[superseded: YYYY-MM-DD]` with reason.
3. Write the new entry with reference to what it replaces.
4. If confidence is low, ask the user to confirm before writing.

```markdown
## [superseded: 2026-02-05]
- **claim**: Budget is $400K
- **superseded_by**: Budget increased to $500K (finance email, 2026-02-05)

## [current]
- **claim**: Budget is $500K
- **confidence**: high
- **evidence**: Finance email, confirmed by user 2026-02-05
- **last_verified**: 2026-02-05
```

---

## Correction Gate

Human corrections are the highest-priority write signal. When a correction arrives:

1. **Write immediately** to the daily log
2. **Update the relevant register** with superseded marking
3. **Update MEMORY.md** if it changes default behavior
4. **Search for the old claim** in all tiers and update everywhere

One correction, multiple writes. A correction that only lasts one session is a compliance, not learning.

### Correction Severity

| Type | Write To | Example |
|------|----------|---------|
| Behavioral | MEMORY.md + register + daily | "Don't send emails without asking" |
| Factual | Register + daily | "The budget is $500K, not $400K" |
| Style | Preferences + MEMORY.md if default | "Stop using headers in chat messages" |
| One-off | Daily log only | "Use the blue logo for this specific deck" |

---

## Register Entry Schema

For durable claims in registers, include metadata:

```markdown
- **claim**: [the fact, preference, or decision]
- **confidence**: high | medium | low
- **evidence**: [source — user said, observed, document, corrected]
- **last_verified**: YYYY-MM-DD
```

Not every line needs full metadata — use it for claims that matter. Decisions with rationale, facts you'll act on, anything where being wrong has consequences.

---

## Session Protocol

### On Session Start

1. MEMORY.md is loaded (via CLAUDE.md)
2. This file (SCHEMA.md) is loaded (via CLAUDE.md)
3. Check today's and yesterday's daily logs for recent context
4. Check open-loops.md for active items
5. Read registers/_index.md to know what domains exist

### Dynamic Loading

If the user's message implies a domain:
- Mentions a person → read registers/people.md
- Mentions a project → read registers/projects.md
- Mentions a past decision → search registers/decisions.md
- Asks "remember when" → search daily logs

**Do NOT load everything.** Context window space is expensive. Pull the relevant section, not the whole file.

### On Session End / Pre-Compaction

Sweep the conversation for unsaved:
1. Decisions made but not logged
2. Commitments with deadlines
3. Corrections from the user
4. Open loops without resolution
5. New preferences or behavioral changes

Write findings to today's daily log with `[pre-compact]` tag.
Update MEMORY.md "Session Continuity" section.

---

## Maintenance Cadences

| Cadence | Trigger | Action |
|---------|---------|--------|
| Immediate | Correction or significant event | Write to daily log + register + MEMORY.md as needed |
| End-of-session | Session ending or compaction | Flush unsaved decisions, commitments, corrections |
| Periodic (weekly) | User runs /recall-maintain | Verify stale entries, prune MEMORY.md, promote from daily logs |
| Quarterly | User runs /recall-maintain | Distill registers into archive, reset cruft |

---

## MEMORY.md Limits

- **Hard cap**: ~1500 words
- **Review**: Every few days
- **Rule**: If something hasn't been relevant in 2+ weeks, demote to register or delete
- **Every line earns its place**: Active goals, current commitments, behavioral preferences, recent corrections, open loops

---

## Commands Reference

| Command | Purpose |
|---------|---------|
| `/recall-init` | Scaffold the memory system |
| `/recall-write <note>` | Write with gate evaluation |
| `/recall-log <note>` | Quick append, no gate |
| `/recall-search <query>` | Search all tiers |
| `/recall-promote` | Review daily logs for promotion |
| `/recall-status` | Memory health check |
| `/recall-maintain` | Verify stale entries, prune, clean up |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show loaded memory context |
