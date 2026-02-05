# TOTAL RECALL: Comprehensive Claude Code Memory Plugin Specification

## Philosophy

Claude Code is stateless. Every session starts from zero. The conversation history is a cache, not memory — it gets compacted, truncated, discarded. Anything not written to disk is gone.

Superpowers solved workflow. This solves persistence. Together they make Claude Code a continuous collaborator rather than a brilliant amnesiac.

### Design Principles

- Memory that doesn't change future behavior shouldn't exist
- Write less, trust more (quality over quantity)
- Retrieval must be fast and relevant (no drowning in context)
- Human corrections propagate immediately and permanently
- The system must understand itself (meta-memory)

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CONVERSATION CACHE                          │
│            (Ephemeral - compacted/discarded)                    │
│                        TIER 0                                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼ WRITE GATE
                      │ "Does this change future behavior?"
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                     DAILY CAPTURE                               │
│               memory/daily/YYYY-MM-DD.md                        │
│                        TIER 1                                   │
│                                                                 │
│  Timestamped entries, raw observations, session notes            │
│  Auto-created per day. Low ceremony, high capture.              │
│  Retention: 30 days, then auto-archived                         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼ PROMOTION
                      │ "Is this durable? Will it matter in 30 days?"
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                     REGISTERS                                   │
│              memory/registers/<domain>.md                        │
│                        TIER 2                                   │
│                                                                 │
│  Structured, domain-specific, versioned                         │
│  people.md | projects.md | decisions.md | preferences.md        │
│  Each entry has: claim, confidence, evidence, last_verified      │
│  Loaded on-demand when domain is relevant                       │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼ DISTILLATION
                      │ "Is this essential for every session?"
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                     WORKING MEMORY                              │
│                   memory/MEMORY.md                               │
│                        TIER 3                                   │
│                                                                 │
│  ~1500 word limit. Loaded EVERY session.                        │
│  Only the most behavior-changing facts survive here.            │
│  Active projects, key preferences, critical context.            │
│  This IS the persistent "personality" of the collaboration.     │
└─────────────────────────────────────────────────────────────────┘
                      │
                      ▼ EXPIRY
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                     ARCHIVE                                     │
│                memory/archive/                                   │
│                                                                 │
│  Completed projects, superseded decisions, old daily logs        │
│  Searchable but never auto-loaded                               │
│  Preserves history without consuming context                    │
└─────────────────────────────────────────────────────────────────┘
```

### The Write Gate

Every potential memory write passes through the gate:

```
┌──────────────────┐
│ Candidate Memory │
└────────┬─────────┘
         │
    ┌────▼────┐
    │ Does it  │──── NO ───→ Discard
    │ change   │
    │ future   │
    │ behavior?│
    └────┬────┘
         │ YES
    ┌────▼────┐
    │ Is it a  │──── YES ──→ Write + flag for verification
    │ correction│
    │ of prior │
    │ memory?  │
    └────┬────┘
         │ NO
    ┌────▼────┐
    │ Will it  │──── YES ──→ Register / MEMORY.md
    │ matter   │
    │ in 30    │
    │ days?    │
    └────┬────┘
         │ NO
         ▼
    Daily log (Tier 1)
```

---

## 2. File Structure

```
project/
├── .claude/
│   └── commands/
│       ├── recall-init.md        # /recall-init command
│       ├── recall-write.md       # /recall-write command
│       ├── recall-search.md      # /recall-search command
│       ├── recall-promote.md     # /recall-promote command
│       ├── recall-status.md      # /recall-status command
│       ├── recall-maintain.md    # /recall-maintain command
│       ├── recall-forget.md      # /recall-forget command
│       └── recall-context.md     # /recall-context command
│
├── memory/
│   ├── MEMORY.md                 # Tier 3: Working memory (~1500 words)
│   ├── SCHEMA.md                 # Self-documentation (teaches Claude how memory works)
│   ├── daily/
│   │   ├── 2026-02-05.md         # Today's log
│   │   ├── 2026-02-04.md         # Yesterday's log
│   │   └── ...
│   ├── registers/
│   │   ├── _index.md             # What registers exist and when to load them
│   │   ├── people.md             # People context
│   │   ├── projects.md           # Project state and history
│   │   ├── decisions.md          # Decisions with rationale
│   │   ├── preferences.md        # User preferences and style
│   │   ├── tech-stack.md         # Technical choices and constraints
│   │   └── open-loops.md         # Active items needing follow-up
│   └── archive/
│       ├── projects/
│       └── daily/
```

---

## 3. The Write Gate (Detailed)

The write gate is the core quality mechanism. It prevents memory bloat.

### Gate Criteria

| Signal | Action | Example |
|--------|--------|---------|
| User says "remember this" | Write immediately | "Remember I prefer tabs" |
| User corrects Claude | Write + supersede old | "No, the deadline is March 15, not April 1" |
| Decision made with rationale | Write to decisions.md | "Let's use Postgres because we need JSONB" |
| Commitment/deadline set | Write to open-loops.md | "I'll have the PR ready by Friday" |
| Preference expressed | Write to preferences.md | "Always use TypeScript, never raw JS" |
| New person introduced | Write to people.md | "Sarah is the new PM, she prefers async updates" |
| Technical fact stated | Write to tech-stack.md | "We're on Node 20, can't upgrade until Q3" |
| Casual observation | **DISCARD** | "This function is kinda ugly" |
| Transient state | **DISCARD** | "I'm working on the login page right now" |
| Debugging details | **DISCARD** | "The error was on line 47" |

### Contradiction Protocol

When a new memory contradicts an existing one:

1. **DO NOT** silently overwrite
2. Mark the old entry as `superseded` with date and reason
3. Write the new entry with reference to what it supersedes
4. If confidence is low, ask the user to confirm

```markdown
## [superseded: 2026-02-05]
- **claim**: Deadline is April 1
- **superseded_by**: Deadline moved to March 15 (user correction, 2026-02-05)

## [current]
- **claim**: Deadline is March 15
- **confidence**: high
- **evidence**: User correction on 2026-02-05
- **last_verified**: 2026-02-05
```

---

## 4. Commands

### `/recall-init`

Scaffolds the full memory directory structure.

```
/recall-init

Creating memory structure...
✓ memory/MEMORY.md (working memory template)
✓ memory/SCHEMA.md (self-documentation)
✓ memory/daily/ (daily capture)
✓ memory/registers/_index.md
✓ memory/registers/people.md
✓ memory/registers/projects.md
✓ memory/registers/decisions.md
✓ memory/registers/preferences.md
✓ memory/registers/tech-stack.md
✓ memory/registers/open-loops.md
✓ memory/archive/

Memory system initialized. Run /recall-status for health check.
```

### `/recall-write <note>`

Applies write gate, writes to appropriate tier.

```
/recall-write User prefers bullet points over prose for summaries

Evaluating write gate...
✓ Changes future behavior (output formatting)

Written to memory/daily/2026-02-05.md:
[14:32] User prefers bullet points over prose for summaries
```

### `/recall-log`

Quick append to daily log without write gate (for raw capture).

### `/recall-search <query>`

Search across all memory tiers.

```
/recall-search "API authentication approach"

Found 3 relevant entries:

[registers/tech-stack.md:45] (confidence: high)
Auth: JWT tokens with 24h expiry, refresh via /auth/refresh

[registers/decisions.md:23] (confidence: high)
2026-01-15: Chose JWT over session cookies for stateless scaling

[daily/2026-02-01.md:12]
Discussed adding OAuth2 for third-party integrations, decided to defer
```

### `/recall-promote`

Interactive review of recent daily logs, surfaces candidates for MEMORY.md or registers.

```
/recall-promote

Reviewing last 7 days of daily logs...

Candidates for promotion:

1. [2026-02-03] "Project deadline moved to March 15"
   → Suggest: MEMORY.md (active commitment)
   [p]romote / [s]kip / [r]egister?

2. [2026-02-02] "Prefers tabs over spaces, 2-space indent"
   → Suggest: registers/preferences.md
   [p]romote / [s]kip / [r]egister?

3. [2026-02-01] "Decided to use Postgres over SQLite for scale"
   → Suggest: registers/decisions.md
   [p]romote / [s]kip / [r]egister?
```

### `/recall-status`

Shows memory system health.

```
/recall-status

Memory System Status:

MEMORY.md: 1,247 words (83% of limit)
Daily logs: 12 files, 8.3KB total
Registers: 6 files, 4.1KB total
Archives: 2 files, 2.8KB total

Last maintenance: 3 days ago
Stale entries (>30 days unverified): 4
Open loops: 2

Recommendations:
• MEMORY.md approaching limit, consider archiving
• Run /recall-maintain to verify stale entries
```

### `/recall-maintain`

Runs maintenance: checks for stale entries, contradictions, promotes candidates.

### `/recall-forget <query>`

Marks matching entries as superseded (doesn't delete, preserves history).

### `/recall-context`

Shows what memory is currently loaded in this session.

---

## 5. Skills

### `memory-load` (triggers on session start)

```markdown
---
name: memory-load
description: Automatically loads relevant memory context on session start
triggers:
  - on_session_start
---

## On Session Start

1. Load memory/MEMORY.md (always)
2. Load memory/SCHEMA.md (always - teaches you how memory works)
3. Read memory/registers/_index.md to know what registers exist
4. Check memory/daily/ for yesterday and today (recent context)
5. Check memory/registers/open-loops.md for active items

## Dynamic Loading

If the user's first message implies a domain:
- Mentions a person → load relevant section of people.md
- Mentions a project → load relevant section of projects.md
- Mentions a past decision → search decisions.md
- Asks "remember when" → search daily logs

Do NOT load everything. Load what's relevant.
```

### `memory-write` (triggers on memory-relevant events)

```markdown
---
name: memory-write
description: Handles memory writes with proper gates
triggers:
  - user_says_remember
  - correction_detected
  - commitment_made
  - decision_with_rationale
---

## Write Protocol

When you detect something that should be remembered:

1. **Apply Write Gate**
   Ask: "Does this change future behavior?"
   If no → don't write
   If yes → continue

2. **Determine Tier**
   - Ephemeral but worth noting → daily log
   - Durable, affects every session → MEMORY.md
   - Domain-specific, structured → appropriate register

3. **Check for Contradictions**
   Search existing memory for related claims
   If contradiction found:
   - DO NOT silently overwrite
   - Note the change explicitly
   - Ask user if uncertain

4. **Write with Schema**
   For registers, include:
   - claim
   - confidence
   - evidence
   - last_verified

   For daily logs:
   - timestamp
   - raw note

5. **Confirm to User**
   "Noted in [location]: [summary]"
```

### `memory-flush` (triggers pre-compaction)

```markdown
---
name: memory-flush
description: Saves important context before compaction
triggers:
  - on_compact
  - on_session_end
---

## Pre-Compaction Sweep

Before context is compacted, scan the conversation for:

1. **Unsaved decisions** - Any "let's go with X" that wasn't written
2. **Uncommitted corrections** - Any "no, it's actually Y"
3. **Open loops created** - Any "I'll do X later" or "TODO"
4. **People introduced** - Any new names with context
5. **Session continuity** - What should the next session know?

Write all findings to today's daily log with [pre-compact] tag.

Update memory/MEMORY.md "Session Continuity" section.
```

---

## 6. Hooks

### `on-session-start.js`

```javascript
export default async function onSessionStart(context) {
  const memoryDir = context.projectRoot + '/memory';

  // Check if memory system is initialized
  if (!context.fileExists(memoryDir + '/MEMORY.md')) {
    context.notify('Memory system not initialized. Run /recall-init to set up.');
    return;
  }

  // Always load working memory
  const workingMemory = await context.readFile(memoryDir + '/MEMORY.md');
  context.injectContext('working-memory', workingMemory);

  // Load schema (teaches Claude how memory works)
  const schema = await context.readFile(memoryDir + '/SCHEMA.md');
  context.injectContext('memory-schema', schema);

  // Load today's and yesterday's daily log if they exist
  const today = new Date().toISOString().split('T')[0];
  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

  for (const date of [today, yesterday]) {
    const dailyPath = `${memoryDir}/daily/${date}.md`;
    if (context.fileExists(dailyPath)) {
      const daily = await context.readFile(dailyPath);
      context.injectContext(`daily-${date}`, daily);
    }
  }

  // Load open loops
  const openLoopsPath = `${memoryDir}/registers/open-loops.md`;
  if (context.fileExists(openLoopsPath)) {
    const openLoops = await context.readFile(openLoopsPath);
    context.injectContext('open-loops', openLoops);
  }

  // Load register index
  const indexPath = `${memoryDir}/registers/_index.md`;
  if (context.fileExists(indexPath)) {
    const index = await context.readFile(indexPath);
    context.injectContext('register-index', index);
  }
}
```

### `on-compact.js`

```javascript
export default async function onCompact(context) {
  const memoryDir = context.projectRoot + '/memory';
  const today = new Date().toISOString().split('T')[0];
  const dailyPath = `${memoryDir}/daily/${today}.md`;

  // Scan conversation for unsaved items
  const unsaved = await context.scanConversation({
    patterns: [
      'decision_made',
      'correction_given',
      'commitment_made',
      'preference_expressed',
      'person_introduced'
    ]
  });

  if (unsaved.length > 0) {
    let flushContent = `\n\n## [pre-compact flush ${new Date().toISOString()}]\n\n`;

    for (const item of unsaved) {
      flushContent += `- [${item.type}] ${item.summary}\n`;
    }

    await context.appendFile(dailyPath, flushContent);
    context.notify(`Flushed ${unsaved.length} items to daily log before compaction`);
  }
}
```

### `on-session-end.js`

```javascript
export default async function onSessionEnd(context) {
  const daysSinceLastMaintenance = await context.getDaysSince('last-maintenance');

  if (daysSinceLastMaintenance > 7) {
    context.notify('Memory maintenance recommended - run /recall-maintain');
  }
}
```

---

## 7. Register Schemas

### `people.md`

```markdown
# People Register

> Who matters and what to know about them. Load when a person is mentioned.

## [Name]
- **role**: [Their role/relationship]
- **contact**: [How to reach them]
- **preferences**: [Communication style, preferences]
- **context**: [Key things to remember]
- **last_interaction**: [Date]
- **confidence**: high | medium | low
- **last_verified**: YYYY-MM-DD
```

### `decisions.md`

```markdown
# Decisions Register

> Choices made with rationale. Load when past decisions are questioned.

## YYYY-MM-DD: [Decision Title]
- **choice**: [What was decided]
- **alternatives**: [What was considered]
- **rationale**: [Why this choice]
- **status**: active | superseded | revisit
- **confidence**: high | medium | low
- **last_verified**: YYYY-MM-DD
```

### `preferences.md`

```markdown
# Preferences Register

> How the user likes things done. Load on relevant tasks.

## Code Style
- [Preference with context]

## Communication
- [Preference with context]

## Workflow
- [Preference with context]

Each entry:
- **claim**: [The preference]
- **confidence**: high | medium | low
- **evidence**: [How we know - user said, observed, corrected]
- **last_verified**: YYYY-MM-DD
```

### `open-loops.md`

```markdown
# Open Loops

> Active items that need follow-up. Loaded every session.

## Active

- [ ] [Item] — created YYYY-MM-DD, due YYYY-MM-DD
- [ ] [Item] — created YYYY-MM-DD

## Recently Closed

- [x] [Item] — closed YYYY-MM-DD
```

---

## 8. MEMORY.md Template

```markdown
# Working Memory

> Loaded every session. ~1500 word limit. Only behavior-changing facts.
> Last updated: YYYY-MM-DD

## Active Context

**Current Focus**: [What we're primarily working on]
**Key Deadline**: [If any]
**Blockers**: [If any]

## Project State

[Brief description of where things stand]

## Critical Preferences

- [Preference 1]
- [Preference 2]

## Key Decisions in Effect

- [Decision 1 - brief]
- [Decision 2 - brief]

## People Context

- **[Name]**: [One-line context for anyone we're actively engaging]

## Open Loops

- [ ] [Active item 1]
- [ ] [Active item 2]

## Session Continuity

[Anything the next session needs to know from this one]

---
*For detailed history, see memory/registers/*
*For daily logs, see memory/daily/*
```

---

## 9. SCHEMA.md (Self-Documentation)

```markdown
# Total Recall Memory Schema

> This file teaches Claude how the memory system works.
> It is loaded every session alongside MEMORY.md.

## How Memory Works

You have a persistent memory system with four tiers:

1. **Daily logs** (memory/daily/YYYY-MM-DD.md) — raw timestamped notes
2. **Registers** (memory/registers/*.md) — structured domain knowledge
3. **Working memory** (memory/MEMORY.md) — essential context, always loaded
4. **Archive** (memory/archive/) — searchable but never auto-loaded

## Write Rules

- Apply the WRITE GATE before saving anything: "Does this change future behavior?"
- Never silently overwrite. Mark old entries as superseded.
- Corrections from the user are highest priority writes.
- Keep MEMORY.md under 1500 words. If approaching limit, archive or demote.

## Read Rules

- MEMORY.md and this file are always loaded.
- Registers are loaded on-demand based on task relevance.
- Daily logs are checked for today and yesterday.
- Use /recall-search for anything older.

## When to Write

| Trigger | Destination |
|---------|-------------|
| User says "remember" | Daily log + maybe register |
| User corrects you | Supersede old + write new |
| Decision with rationale | registers/decisions.md |
| New person context | registers/people.md |
| Preference expressed | registers/preferences.md |
| Commitment/deadline | registers/open-loops.md |
| Technical choice | registers/tech-stack.md |

## When NOT to Write

- Debugging details
- Transient state ("I'm on the login page")
- Observations without behavioral impact
- Anything you're not confident about (ask first)
```

---

## 10. CLAUDE.md Integration

Add to project's CLAUDE.md:

```markdown
## Memory System

This project uses Total Recall for persistent memory.

**Always loaded**: memory/MEMORY.md, memory/SCHEMA.md
**On-demand**: memory/registers/* (search when relevant)
**Daily capture**: memory/daily/YYYY-MM-DD.md

### Key Commands
- `/recall-search <query>` - find in memory
- `/recall-write <note>` - save with write gate
- `/recall-status` - check memory health
- `/recall-promote` - review daily logs for promotion

### Memory Protocol
- Before answering questions about history/preferences: SEARCH FIRST
- Before writing to memory: apply write gate (does this change future behavior?)
- On corrections: update all instances, mark old as superseded
- Pre-compaction: flush unsaved decisions/commitments to daily log

See memory/SCHEMA.md for full documentation.
```

---

## 11. Integration with Superpowers

If Superpowers is installed, Total Recall complements it:

| Superpowers | Total Recall |
|-------------|-------------|
| How to work (methodology) | What to remember (persistence) |
| Plan files in `docs/plans/` | Memory in `memory/` |
| Session-independent via plans | Session-independent via memory |
| TDD enforcement | Write gate enforcement |
| Subagent dispatch | Memory search before action |

### Combined Workflow

1. Session starts → Total Recall loads memory context
2. Superpowers kicks in for task methodology
3. During work → Both systems active
4. Pre-compaction → Total Recall flushes, Superpowers saves plan state
5. Next session → Both restore context, continuity preserved

**No conflicts**: They operate on different concerns. Superpowers doesn't touch `memory/`, Total Recall doesn't touch `docs/plans/`.

---

## 12. Implementation Order

Build iteratively in this order:

1. **Scaffold** — `/recall-init` command, directory structure, templates
2. **Write** — `/recall-write` with write gate logic
3. **Search** — `/recall-search` across all tiers
4. **Session load** — CLAUDE.md integration, SCHEMA.md
5. **Promote** — `/recall-promote` for daily-to-register flow
6. **Status** — `/recall-status` health check
7. **Maintain** — `/recall-maintain` for stale entry cleanup
8. **Hooks** — Pre-compaction flush (when Claude Code supports it)
9. **Polish** — Edge cases, error handling, docs
