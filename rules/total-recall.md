# Total Recall — Memory Protocol

> This file auto-loads every session via .claude/rules/.
> It governs how you handle persistent memory. Follow these rules exactly.

## Memory System Active

This project uses Total Recall for persistent memory. Your memory lives in files on disk — not in conversation history.

### What Loads Automatically

- **This file** (.claude/rules/total-recall.md) — the protocol you're reading now
- **CLAUDE.local.md** — your working memory (~1500 words of essential context)
- **memory/SCHEMA.md** — detailed documentation of how memory works

### What To Check On Session Start

After loading, proactively read these files:
1. `memory/registers/open-loops.md` — active items needing follow-up
2. `memory/daily/[today].md` — today's daily log, if it exists
3. `memory/daily/[yesterday].md` — yesterday's daily log, if it exists
4. `memory/registers/_index.md` — know what registers exist

### Dynamic Loading

If the user's message implies a domain:
- Mentions a person → read `memory/registers/people.md`
- Mentions a project → read `memory/registers/projects.md`
- References a past decision → search `memory/registers/decisions.md`
- Asks "remember when" → search `memory/daily/`

**Do NOT load everything.** Pull only what's relevant.

---

## Write Gate — MANDATORY

Before writing ANYTHING to memory, apply this gate:

1. Does it change future behavior? → WRITE
2. Is it a commitment with consequences? → WRITE
3. Is it a decision with rationale? → WRITE
4. Is it a stable fact that will matter again? → WRITE
5. Did the user explicitly say "remember this"? → ALWAYS WRITE

**If none are true → DO NOT WRITE.**

### Default Destination: Daily Log

All writes go to `memory/daily/YYYY-MM-DD.md` FIRST as timestamped entries. Promotion to registers or CLAUDE.local.md happens separately via `/recall-promote` or explicit user request.

Exception: explicit corrections and "remember this" requests that are clearly durable can go directly to the appropriate register AND the daily log.

---

## Correction Handling — HIGHEST PRIORITY

When the user corrects you:
1. Write to today's daily log immediately
2. Update the relevant register (mark old entry as `[superseded: date]`)
3. Update CLAUDE.local.md if it changes default behavior
4. Search for the old claim everywhere and update all instances

**A correction that only lasts one session is compliance, not learning.**

---

## Contradiction Protocol

When new info conflicts with existing memory:
- **NEVER** silently overwrite
- Mark old entry as `[superseded: YYYY-MM-DD]` with reason
- Write new entry with reference to what it replaces
- Ask user to confirm if confidence is low

---

## Pre-Compaction / Session End

Before the session ends or if you sense the conversation is getting long:
- Sweep for unsaved decisions, corrections, commitments, open loops
- Write findings to today's daily log with `[session-flush]` tag
- Update CLAUDE.local.md "Session Continuity" section

---

## Commands

| Command | Purpose |
|---------|---------|
| `/recall-init` | Scaffold the memory system |
| `/recall-write <note>` | Write to daily log with gate evaluation |
| `/recall-log <note>` | Quick append to daily log, no gate |
| `/recall-search <query>` | Search all memory tiers |
| `/recall-promote` | Review daily logs, promote to registers |
| `/recall-status` | Memory health check |
| `/recall-maintain` | Verify stale entries, clean up |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show loaded memory context |

---

## Recall Nudges (Optional)

If `recall_suggestions` in CLAUDE.local.md is `off`, never suggest memory candidates unprompted.

If `recall_suggestions` is `low` (opt-in), you MAY append a small footer to your response with up to **2 candidates per session**, and only when the user does one of these:

- **Corrects you** — explicit "no, it's X"
- **Makes a commitment** — deadline, deliverable, follow-up
- **Makes a decision with rationale** — "we chose A because B"
- **States a durable preference** — "always do X", "never do Y"

Rules:
- Candidates must be **literal paraphrases**, not inferences. Quote what the user said.
- If you are not confident the item passes the write gate, do not suggest.
- **Never interrupt the main response.** Append at the very end as a small footer block.
- **Skip during code-only answers.** If the response is pure code output, no nudge.
- After 2 nudges in a session, stop. Do not nudge again until the next session.

Format:

```
---
Recall candidate: "<candidate text>"
→ /recall:recall-write <candidate text>  (plugin)
→ /recall-write <candidate text>  (standalone)
```

---

## Key Rules

- Before answering questions about history/preferences: **SEARCH MEMORY FIRST**
- Before writing to memory: **APPLY THE WRITE GATE**
- Default write destination: **DAILY LOG** (promote later)
- On corrections: **UPDATE ALL INSTANCES** across all tiers
- Keep CLAUDE.local.md under **1500 words**
- Register entries should include: claim, confidence, evidence, last_verified
- Daily logs are append-only — never modify past entries
- Archive superseded entries, don't delete them
