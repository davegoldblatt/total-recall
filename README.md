# Total Recall

Persistent memory for Claude Code. Every session starts informed, not from zero.

## The Problem

Claude Code's conversation cache gets compacted, truncated, discarded. You end up repeating yourself, re-explaining preferences, re-making decisions.

Total Recall fixes this with a tiered memory system that captures what matters, discards what doesn't, and loads the right context every session — using Claude Code's native loading mechanisms so it actually works.

## How It Works

**Four tiers of memory, two loaded deterministically:**

| Tier | What | How It Loads |
|------|------|-------------|
| Working Memory | `CLAUDE.local.md` — essential context, ~1500 words | **Auto-loaded** by Claude Code |
| Registers | `memory/registers/*.md` — structured domain knowledge | On demand (searched when relevant) |
| Daily Logs | `memory/daily/YYYY-MM-DD.md` — timestamped raw capture | Checked on session start |
| Archive | `memory/archive/` — completed/superseded items | On search |

**The protocol** lives in `.claude/rules/total-recall.md` and **auto-loads** every session — no "please remember to follow these rules" needed.

**The write gate** prevents memory bloat. Before anything gets written: *"Does this change future behavior?"* If not, it doesn't get saved. All writes go to the daily log first; promotion to registers is a separate, user-controlled step.

**Corrections propagate immediately.** When the user corrects Claude, it's written to daily log + register + working memory. One correction, multiple writes. The same mistake never recurs.

## Install

```bash
git clone https://github.com/davegoldblatt/total-recall.git
cd total-recall
./install.sh /path/to/your/project
```

Or manually:
1. Copy `.claude/commands/recall-*.md` → your project's `.claude/commands/`
2. Copy `.claude/rules/total-recall.md` → your project's `.claude/rules/`
3. Copy `templates/CLAUDE.local.md` → your project root as `CLAUDE.local.md`
4. Copy `templates/SCHEMA.md` + `templates/registers/` → `memory/` in your project
5. Copy `hooks/` → your project's `hooks/` and configure in `.claude/settings.local.json`

## What Auto-Loads (Deterministic)

These use Claude Code's native mechanisms — they load every session without any prompting:

| File | Mechanism | Purpose |
|------|-----------|---------|
| `.claude/rules/total-recall.md` | `.claude/rules/` auto-discovery | Write gate, correction protocol, session behavior |
| `CLAUDE.local.md` | Claude Code local memory | Working memory (~1500 words, gitignored) |

## Hooks

Configured in `.claude/settings.local.json`:

| Hook | When | What |
|------|------|------|
| **SessionStart** | Session begins | Injects open loops + recent daily log highlights |
| **PreCompact** | Before compaction | Flushes conversation context to daily log |

The hooks are safety nets. The protocol in `.claude/rules/` also instructs Claude on these behaviors — hooks ensure it happens even if the protocol isn't followed.

## Commands

| Command | What it does |
|---------|-------------|
| `/recall-init` | Scaffold the memory directory structure |
| `/recall-write <note>` | Write to daily log with gate evaluation (suggests promotion) |
| `/recall-log <note>` | Quick append to daily log (no gate) |
| `/recall-search <query>` | Search across all memory tiers |
| `/recall-promote` | Review daily logs, promote to registers |
| `/recall-status` | Memory system health check |
| `/recall-maintain` | Verify stale entries, prune, clean up |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show what memory is loaded this session |

## Architecture

```
Conversation (ephemeral — compacted/discarded)
    │
    ▼ WRITE GATE: "Does this change future behavior?"
    │
Daily Log (memory/daily/YYYY-MM-DD.md)
    All writes land here first. Raw, timestamped.
    │
    ▼ PROMOTION: user-controlled via /recall-promote
    │
Registers (memory/registers/*.md)
    Structured claims with metadata (confidence, evidence, last_verified)
    │
    ▼ DISTILLATION: only what's essential for every session
    │
Working Memory (CLAUDE.local.md)
    ~1500 words. Auto-loaded. The persistent "personality."
    │
    ▼ EXPIRY
    │
Archive (memory/archive/)
    Searchable history. Never auto-loaded.
```

### Key Mechanisms

**Write Gate** — Filters out noise. Only behavior-changing facts, commitments, decisions, and explicit "remember this" requests pass through.

**Daily Log First** — All writes land in the daily log. Promotion to registers is a separate step, controlled by the user. This prevents the model from prematurely solidifying inferences.

**Contradiction Protocol** — Never silently overwrites. Old claims are marked `[superseded]` with date and reason. The pattern of change is preserved.

**Correction Gate** — Human corrections get highest priority. One correction triggers writes to daily log + register + working memory.

## File Structure

```
your-project/
├── .claude/
│   ├── commands/
│   │   ├── recall-init.md       # /recall-init
│   │   ├── recall-write.md      # /recall-write <note>
│   │   ├── recall-log.md        # /recall-log <note>
│   │   ├── recall-search.md     # /recall-search <query>
│   │   ├── recall-promote.md    # /recall-promote
│   │   ├── recall-status.md     # /recall-status
│   │   ├── recall-maintain.md   # /recall-maintain
│   │   ├── recall-forget.md     # /recall-forget <query>
│   │   └── recall-context.md    # /recall-context
│   ├── rules/
│   │   └── total-recall.md      # Protocol (auto-loaded)
│   └── settings.local.json      # Hook configuration
├── hooks/
│   ├── session-start.sh         # SessionStart hook
│   └── pre-compact.sh           # PreCompact hook
├── memory/
│   ├── SCHEMA.md                # Protocol documentation
│   ├── daily/
│   │   └── YYYY-MM-DD.md        # Daily logs
│   ├── registers/
│   │   ├── _index.md            # Register directory
│   │   ├── people.md
│   │   ├── projects.md
│   │   ├── decisions.md
│   │   ├── preferences.md
│   │   ├── tech-stack.md
│   │   └── open-loops.md
│   └── archive/
├── CLAUDE.md                    # Supplementary docs (committable)
└── CLAUDE.local.md              # Working memory (gitignored, personal)
```

## Works With Superpowers

Total Recall complements [Superpowers](https://github.com/superpowers-ai/superpowers). No conflicts:

| Superpowers | Total Recall |
|-------------|-------------|
| How to work (methodology) | What to remember (persistence) |
| Plans in `docs/plans/` | Memory in `memory/` |
| TDD enforcement | Write gate enforcement |

## Design Principles

- **Memory that doesn't change future behavior shouldn't exist**
- **Daily log first** — capture safely, promote deliberately
- Human corrections propagate immediately and permanently
- Deterministic loading via native Claude Code mechanisms
- Transparent markdown files, not a black-box database

## Privacy

- `CLAUDE.local.md` is automatically gitignored (personal working memory)
- `memory/` may contain preferences, people context, project decisions
- Consider adding `memory/` to `.gitignore` for personal projects
- `.claude/settings.local.json` is personal hook config (not committed)

## License

MIT
