# Total Recall

Persistent memory for Claude Code. Every session starts informed, not from zero.

## The Problem

Claude Code is stateless. The conversation cache gets compacted, truncated, discarded. Anything not written to disk is gone. You end up repeating yourself, re-explaining preferences, re-making decisions.

Total Recall fixes this with a tiered memory system that captures what matters, discards what doesn't, and loads the right context every session.

## How It Works

**Four tiers of memory:**

| Tier | What | Loaded |
|------|------|--------|
| Working Memory | `memory/MEMORY.md` — essential context, ~1500 words | Every session |
| Registers | `memory/registers/*.md` — structured domain knowledge | On demand |
| Daily Logs | `memory/daily/YYYY-MM-DD.md` — timestamped raw capture | Today + yesterday |
| Archive | `memory/archive/` — completed/superseded items | On search |

**The write gate** prevents memory bloat. Before anything gets written: *"Does this change future behavior?"* If not, it doesn't get saved.

**Corrections propagate immediately.** When the user corrects Claude, the correction is written to daily log + register + working memory. One correction, multiple writes. The same mistake never recurs.

## Install

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/total-recall.git

# Install into your project
cd total-recall
./install.sh /path/to/your/project
```

Or manually:
1. Copy `.claude/commands/recall-*.md` into your project's `.claude/commands/`
2. Copy `templates/` contents into a `memory/` directory in your project
3. Append `CLAUDE.md` contents to your project's `CLAUDE.md`

## Commands

| Command | What it does |
|---------|-------------|
| `/recall-init` | Scaffold the memory directory structure |
| `/recall-write <note>` | Write to memory with gate evaluation |
| `/recall-log <note>` | Quick append to daily log (no gate) |
| `/recall-search <query>` | Search across all memory tiers |
| `/recall-promote` | Review daily logs, promote to registers |
| `/recall-status` | Memory system health check |
| `/recall-maintain` | Verify stale entries, prune, clean up |
| `/recall-forget <query>` | Mark entries as superseded |
| `/recall-context` | Show what memory is loaded this session |

## Architecture

```
Conversation (ephemeral)
    │
    ▼ WRITE GATE: "Does this change future behavior?"
    │
Daily Log (raw capture, timestamped)
    │
    ▼ PROMOTION: "Will this matter in 30 days?"
    │
Registers (structured, domain-specific, with metadata)
    │
    ▼ DISTILLATION: "Essential for every session?"
    │
MEMORY.md (working memory, ~1500 words, always loaded)
    │
    ▼ EXPIRY
    │
Archive (searchable history, never auto-loaded)
```

### Key Mechanisms

**Write Gate** — Filters out noise. Only behavior-changing facts, commitments, decisions, and explicit "remember this" requests pass through.

**Contradiction Protocol** — Never silently overwrites. Old claims are marked `[superseded]` with date and reason. The pattern of change is preserved.

**Correction Gate** — Human corrections get the highest priority. One correction triggers writes to daily log + register + working memory. Corrections that only last one session are compliance, not learning.

**Promotion** — Daily log entries that prove durable get promoted to registers. Register entries that are essential for every session get distilled into MEMORY.md.

## File Structure

```
your-project/
├── .claude/
│   └── commands/
│       ├── recall-init.md
│       ├── recall-write.md
│       ├── recall-search.md
│       ├── recall-promote.md
│       ├── recall-status.md
│       ├── recall-maintain.md
│       ├── recall-forget.md
│       ├── recall-context.md
│       └── recall-log.md
├── memory/
│   ├── MEMORY.md              # Working memory (loaded every session)
│   ├── SCHEMA.md              # Self-docs (teaches Claude the protocol)
│   ├── daily/
│   │   └── YYYY-MM-DD.md      # Daily logs
│   ├── registers/
│   │   ├── _index.md          # Register directory
│   │   ├── people.md
│   │   ├── projects.md
│   │   ├── decisions.md
│   │   ├── preferences.md
│   │   ├── tech-stack.md
│   │   └── open-loops.md
│   └── archive/
│       ├── projects/
│       └── daily/
└── CLAUDE.md                  # Memory protocol (auto-loaded by Claude Code)
```

## Works With Superpowers

Total Recall is designed to complement [Superpowers](https://github.com/superpowers-ai/superpowers). No conflicts — they operate on different concerns:

| Superpowers | Total Recall |
|-------------|-------------|
| How to work (methodology) | What to remember (persistence) |
| Plans in `docs/plans/` | Memory in `memory/` |
| TDD enforcement | Write gate enforcement |
| Subagent dispatch | Memory search before action |

## Design Principles

- **Memory that doesn't change future behavior shouldn't exist**
- Write less, trust more (quality over quantity)
- Retrieval must be fast and relevant (no drowning in context)
- Human corrections propagate immediately and permanently
- The system must understand itself (meta-memory via SCHEMA.md)

## Privacy

The `memory/` directory may contain personal preferences, people context, and project decisions. Consider:
- Adding `memory/` to `.gitignore` for personal projects
- Reviewing register contents before committing to shared repos
- Using the archive system for sensitive completed items

## License

MIT
