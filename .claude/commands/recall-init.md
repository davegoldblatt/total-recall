Initialize the Total Recall memory system in this project.

## What To Do

Create the following directory structure and files. If any already exist, skip them (do not overwrite).

### Directory Structure

```
memory/
├── MEMORY.md
├── SCHEMA.md
├── daily/
├── registers/
│   ├── _index.md
│   ├── people.md
│   ├── projects.md
│   ├── decisions.md
│   ├── preferences.md
│   ├── tech-stack.md
│   └── open-loops.md
└── archive/
    ├── projects/
    └── daily/
```

### memory/MEMORY.md

```markdown
# Working Memory

> Loaded every session. ~1500 word limit. Only behavior-changing facts.
> Last updated: [today's date]

## Active Context

**Current Focus**: [not yet set]
**Key Deadline**: [none]
**Blockers**: [none]

## Project State

[No projects tracked yet. Use /recall-write to start capturing.]

## Critical Preferences

- [None captured yet]

## Key Decisions in Effect

- [None captured yet]

## People Context

- [None captured yet]

## Open Loops

- [None yet]

## Session Continuity

[Fresh install — no prior sessions.]

---
*For detailed history, see memory/registers/*
*For daily logs, see memory/daily/*
```

### memory/SCHEMA.md

Read the SCHEMA.md template from the templates/ directory if it exists, otherwise create it with the full schema documentation that teaches Claude how the memory system works. Include:

1. The four-tier architecture (daily logs, registers, working memory, archive)
2. Write gate rules ("Does this change future behavior?")
3. Read rules (what's loaded when)
4. When-to-write table (triggers and destinations)
5. When-NOT-to-write list
6. Contradiction protocol (never silently overwrite, mark superseded)
7. Correction handling (highest priority writes, propagate to all tiers)
8. Maintenance cadences (immediate, end-of-session, periodic, quarterly)

### Register Templates

Create each register file with its header and empty structure. Each should have a descriptive comment at the top explaining when it gets loaded and what belongs in it.

### memory/registers/_index.md

```markdown
# Register Index

> This file lists all available registers and when to load them.
> Claude reads this to know what memory domains exist.

| Register | Load When | Contains |
|----------|-----------|----------|
| people.md | A person is mentioned | Who matters, roles, preferences, contact context |
| projects.md | A project is discussed | Project state, goals, key decisions, blockers |
| decisions.md | Past choices are questioned | Decisions with rationale, alternatives, outcomes |
| preferences.md | Task involves user preferences | Code style, communication style, workflow prefs |
| tech-stack.md | Technical choices come up | Languages, frameworks, tools, constraints |
| open-loops.md | Every session (auto) | Active items needing follow-up, deadlines |

## Adding New Registers

Create a new .md file in this directory and add a row to the table above.
Name it semantically (e.g., `clients.md`, `health.md`, `finances.md`).
```

### Today's Daily Log

Create `memory/daily/[today's date].md`:

```markdown
# [today's date]

## Decisions
- Total Recall memory system initialized

## Corrections

## Commitments

## Open Loops

## Notes
- Memory system scaffolded. Ready for use.
```

### Output

After creating everything, display a summary:

```
Total Recall initialized.

Created:
  memory/MEMORY.md          (working memory — loaded every session)
  memory/SCHEMA.md          (self-documentation — teaches Claude the protocol)
  memory/daily/[date].md    (today's daily log)
  memory/registers/         (6 domain registers + index)
  memory/archive/           (for completed/superseded items)

Quick start:
  /recall-write <note>      Save something to memory
  /recall-search <query>    Find in memory
  /recall-status            Check memory health
  /recall-promote           Review daily logs for promotion

Memory protocol is active. See memory/SCHEMA.md for how it works.
```
