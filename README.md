# Total Recall

**Curated** persistent memory for Claude Code. Not auto-ingest — a write gate that asks *"Does this change future behavior?"* before anything gets saved.

Other memory tools dump everything into context. Total Recall does the opposite: it filters aggressively, captures to a daily log first, and only promotes to long-term memory when you say so. The result is a lean, trustworthy memory that doesn't bloat your context window with noise.

## Install

**As a plugin** (recommended):

```
/plugin marketplace add davegoldblatt/recall-marketplace
/plugin install recall@recall-marketplace
```

**Or standalone** (copies files into your project's `.claude/` directory):

```bash
git clone https://github.com/davegoldblatt/total-recall.git
cd total-recall
./install.sh /path/to/your/project
```

After installing: restart Claude Code or run `/hooks` to activate hooks. Claude Code snapshots hooks at startup.

## Why a Write Gate?

Most memory systems have a capture problem — they save too much. Every observation, every intermediate thought, every transient detail gets persisted. Your context fills with stale facts and the model starts hallucinating from its own outdated notes.

Total Recall's write gate is a five-point filter:

1. **Does it change future behavior?** (preference, boundary, recurring pattern)
2. **Is it a commitment with consequences?** (deadline, deliverable, follow-up)
3. **Is it a decision with rationale?** (why X over Y, worth preserving)
4. **Is it a stable fact that will matter again?** (not transient, not obvious)
5. **Did the user explicitly say "remember this"?**

If none are true, it doesn't get saved. Period.

## How It Works

**Four tiers of memory, two loaded deterministically:**

| Tier | What | How It Loads |
|------|------|-------------|
| Working Memory | `CLAUDE.local.md` — essential context, ~1500 words | **Auto-loaded** by Claude Code |
| Registers | `memory/registers/*.md` — structured domain knowledge | On demand (searched when relevant) |
| Daily Logs | `memory/daily/YYYY-MM-DD.md` — timestamped raw capture | Checked on session start |
| Archive | `memory/archive/` — completed/superseded items | On search |

**The protocol** lives in `.claude/rules/total-recall.md` (standalone) or `rules/total-recall.md` (plugin) and **auto-loads** every session — no "please remember to follow these rules" needed.

**All writes go to the daily log first.** Promotion to registers is a separate, user-controlled step via `/recall-promote`. This prevents the model from prematurely solidifying inferences.

**Corrections propagate immediately.** When you correct Claude, it updates the daily log + register + working memory in one shot. The same mistake never recurs.

## Commands

When installed as a plugin, commands are namespaced: `/recall:recall-write`. Standalone install uses `/recall-write`.

| Command | What it does |
|---------|-------------|
| `recall-init` | Scaffold the memory directory structure |
| `recall-write <note>` | Write to daily log with gate evaluation (suggests promotion) |
| `recall-log <note>` | Quick append to daily log (no gate) |
| `recall-search <query>` | Search across all memory tiers |
| `recall-promote` | Review daily logs, promote to registers |
| `recall-status` | Memory system health check |
| `recall-maintain` | Verify stale entries, prune, clean up |
| `recall-forget <query>` | Mark entries as superseded |
| `recall-context` | Show what memory is loaded this session |

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

## Hooks

| Hook | When | What |
|------|------|------|
| **SessionStart** | Session begins | Injects open loops + recent daily log highlights into Claude's context |
| **PreCompact** | Before compaction | Writes compaction marker to daily log (file write only, not injected) |

**How they differ:** SessionStart stdout is injected as model-visible context — Claude sees it. PreCompact stdout is not visible to the model; it only writes files to disk. This is by design: SessionStart primes the session, PreCompact preserves a record.

Hooks use `$CLAUDE_PROJECT_DIR` (standalone) or `${CLAUDE_PLUGIN_ROOT}` (plugin) to resolve paths portably. All hooks fail open — errors never block Claude Code.

**No transcript parsing.** The PreCompact hook only writes a timestamp marker to the daily log. It does not read or parse conversation transcripts. This complies with Anthropic's directory policy on conversation data.

## What Auto-Loads (Deterministic)

These use Claude Code's native mechanisms — they load every session without any prompting:

| File | Mechanism | Purpose |
|------|-----------|---------|
| `rules/total-recall.md` | `.claude/rules/` auto-discovery | Write gate, correction protocol, session behavior |
| `CLAUDE.local.md` | Claude Code local memory | Working memory (~1500 words, gitignored) |

## File Structure

**Plugin format** (installed via `/plugin install`):

```
total-recall/                     # Plugin root
├── .claude-plugin/
│   └── plugin.json               # Plugin manifest
├── skills/                       # Slash commands (namespaced)
│   ├── recall-write/SKILL.md
│   ├── recall-search/SKILL.md
│   └── ...
├── hooks/
│   ├── hooks.json                # Hook configuration
│   ├── session-start.sh
│   └── pre-compact.sh
├── rules/
│   └── total-recall.md           # Protocol (auto-loaded)
└── templates/                    # Scaffolding templates
    ├── SCHEMA.md
    ├── CLAUDE.local.md
    └── registers/
```

**Standalone format** (installed via `install.sh`):

```
your-project/
├── .claude/
│   ├── commands/recall-*.md      # Slash commands
│   ├── rules/total-recall.md     # Protocol (auto-loaded)
│   ├── hooks/*.sh                # Hook scripts
│   └── settings.local.json       # Hook configuration
├── memory/
│   ├── SCHEMA.md
│   ├── daily/YYYY-MM-DD.md
│   ├── registers/*.md
│   └── archive/
├── CLAUDE.md
└── CLAUDE.local.md               # Working memory (gitignored)
```

## Compared to Other Memory Tools

| | Total Recall | Auto-ingest tools |
|---|---|---|
| **What gets saved** | Only what passes the write gate | Everything |
| **Default destination** | Daily log (promote later) | Permanent storage |
| **Context cost** | ~1500 words working memory | Grows unbounded |
| **Corrections** | Propagate to all tiers immediately | Varies |
| **User control** | Promotion is explicit | Automatic |
| **Architecture** | 4-tier with metadata | Flat or 2-tier |

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

## Privacy & Security

- **Local only. No network calls. No telemetry. No external dependencies.**
- All memory is stored as plain markdown files in your project directory
- `CLAUDE.local.md` is automatically gitignored (personal working memory)
- `memory/` is automatically gitignored (contains preferences, people context, project decisions)
- `.claude/settings.local.json` is personal hook config (not committed)
- **No transcript parsing** — hooks never read conversation history or transcripts
- Hooks only read/write files inside your project's `memory/` directory
- To audit: all hook code is in `hooks/*.sh`, all memory is in `memory/` — plain text, fully inspectable
- To uninstall: remove `memory/`, `CLAUDE.local.md`, and the `.claude/` entries (or `/plugin uninstall recall`)

## License

MIT
