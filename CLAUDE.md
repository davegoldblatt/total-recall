# Total Recall — Memory Protocol

> This file governs how Claude handles persistent memory in this project.
> It is loaded automatically every session via Claude Code's CLAUDE.md system.

## Memory System

This project uses **Total Recall** for persistent memory across sessions.

**Always loaded**: `memory/MEMORY.md` (working memory), `memory/SCHEMA.md` (protocol docs)
**Auto-checked**: `memory/registers/open-loops.md`, today's + yesterday's daily log
**On-demand**: `memory/registers/*` (searched when a relevant topic arises)
**Daily capture**: `memory/daily/YYYY-MM-DD.md`

## Session Start Protocol

At the start of every session:

1. Read `memory/MEMORY.md` — this is your working memory
2. Read `memory/SCHEMA.md` — this teaches you how memory works
3. Check `memory/registers/open-loops.md` for active items
4. Check `memory/daily/` for today's and yesterday's logs
5. Read `memory/registers/_index.md` to know what registers exist

**Dynamic loading**: If the user's first message mentions a person, project, past decision, or asks "remember when," search the relevant register or daily logs before responding.

**Do NOT load everything.** Pull only what's relevant. Context window space is expensive.

## Write Gate — MANDATORY

Before writing ANYTHING to memory, apply this gate:

1. Does it change future behavior? → WRITE
2. Is it a commitment with consequences? → WRITE
3. Is it a decision with rationale? → WRITE
4. Is it a stable fact that will matter again? → WRITE
5. Did the user explicitly say "remember this"? → ALWAYS WRITE

**If none of these are true → DO NOT WRITE.** Resist the urge to log everything.

## Correction Handling — HIGHEST PRIORITY

When the user corrects you:
1. Write to today's daily log immediately
2. Update the relevant register (mark old entry as superseded)
3. Update MEMORY.md if it changes default behavior
4. Search for the old claim everywhere and update all instances

**A correction that only lasts one session is compliance, not learning.**

## Contradiction Protocol

When new info conflicts with existing memory:
- NEVER silently overwrite
- Mark old entry as `[superseded: date]`
- Write new entry with reference to what it replaces
- Ask user to confirm if confidence is low

## Pre-Compaction / Session End

Before the session ends or context gets compacted, sweep for:
- Unsaved decisions
- Uncommitted corrections
- Open loops created
- New preferences or behavioral changes

Write findings to today's daily log with `[session-flush]` tag.
Update MEMORY.md "Session Continuity" section.

## Commands

| Command | Purpose |
|---------|---------|
| `/recall-init` | Scaffold the memory system |
| `/recall-write <note>` | Write with gate evaluation |
| `/recall-log <note>` | Quick append, no gate |
| `/recall-search <query>` | Search all tiers |
| `/recall-promote` | Review daily logs for promotion |
| `/recall-status` | Memory health check |
| `/recall-maintain` | Verify stale entries, clean up |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show loaded memory context |

## Key Rules

- Before answering questions about history or preferences: **SEARCH MEMORY FIRST**
- Before writing to memory: **APPLY THE WRITE GATE**
- On corrections: **UPDATE ALL INSTANCES** across all tiers
- Keep MEMORY.md under **1500 words** — demote or archive when approaching
- Register entries should include: claim, confidence, evidence, last_verified
- Daily logs are append-only — never modify past entries
- Archive superseded entries, don't delete them

See `memory/SCHEMA.md` for the complete protocol documentation.
