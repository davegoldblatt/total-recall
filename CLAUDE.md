# Total Recall

> Memory protocol auto-loads via `.claude/rules/total-recall.md`.
> Working memory auto-loads via `CLAUDE.local.md`.
> This file is supplementary documentation.

## Quick Reference

| What | Where | Loaded |
|------|-------|--------|
| Protocol & rules | `.claude/rules/total-recall.md` | Auto (every session) |
| Working memory | `CLAUDE.local.md` | Auto (every session) |
| Schema docs | `memory/SCHEMA.md` | Read on session start |
| Daily logs | `memory/daily/YYYY-MM-DD.md` | Check today + yesterday |
| Registers | `memory/registers/*.md` | On demand |
| Archive | `memory/archive/` | On search only |
| Entry metadata | `memory/.recall/metadata.json` | On maintain/status |

## Commands

| Command | Purpose |
|---------|---------|
| `/recall-init` | Scaffold the memory system |
| `/recall-init-ids` | Add durable IDs to memory entries |
| `/recall-write <note>` | Write to daily log with gate evaluation |
| `/recall-log <note>` | Quick append to daily log, no gate |
| `/recall-search <query>` | Search all memory tiers |
| `/recall-promote` | Review daily logs, promote to registers |
| `/recall-status` | Memory health check |
| `/recall-maintain` | Pressure-based cleanup with demotion and archival |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show loaded memory context |

## Core Rules

1. **Write gate**: Does it change future behavior? If not, don't write.
2. **Daily log first**: All writes land in `memory/daily/` before promotion.
3. **Corrections propagate**: One correction → update daily log + register + CLAUDE.local.md.
4. **Never silently overwrite**: Mark old entries as `[superseded]`.
5. **1500 word limit** on CLAUDE.local.md — demote or archive when approaching.

See `memory/SCHEMA.md` for complete documentation.
