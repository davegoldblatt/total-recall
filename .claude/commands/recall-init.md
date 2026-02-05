Initialize the Total Recall memory system in this project.

## What To Do

Create the following directory structure and files. If any already exist, skip them (do not overwrite).

### Directory Structure

```
memory/
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

Plus at the project root:
- `CLAUDE.local.md` — working memory (auto-loaded, gitignored)

### CLAUDE.local.md (Working Memory)

If CLAUDE.local.md does not exist, create it:

```markdown
# Working Memory

> This is your working memory. Auto-loaded every session via CLAUDE.local.md.
> ~1500 word limit. Only behavior-changing facts earn a place here.
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

Also add `CLAUDE.local.md` to `.gitignore` if not already there (it contains personal memory).

### memory/SCHEMA.md

Create the full schema documentation that teaches Claude how the memory system works. Include:

1. The four-tier architecture (daily logs → registers → working memory → archive)
2. Write gate rules ("Does this change future behavior?")
3. Read rules (what's auto-loaded vs on-demand)
4. Routing table (triggers and destinations)
5. Contradiction protocol (never silently overwrite, mark superseded)
6. Correction handling (highest priority writes, propagate to all tiers)
7. Maintenance cadences (immediate, end-of-session, periodic, quarterly)
8. Note that working memory is in CLAUDE.local.md (auto-loaded) and protocol is in .claude/rules/total-recall.md (auto-loaded)

### Register Templates

Create each register file with its header and empty structure. Each should have a descriptive comment explaining when it gets loaded and what belongs in it.

### memory/registers/_index.md

```markdown
# Register Index

> Lists all registers and when to load them. Read on session start.

| Register | Load When | Contains |
|----------|-----------|----------|
| people.md | A person is mentioned | Roles, preferences, contact context |
| projects.md | A project is discussed | State, goals, decisions, blockers |
| decisions.md | Past choices are questioned | Decisions with rationale and outcomes |
| preferences.md | Task involves user style | Code style, communication, workflow prefs |
| tech-stack.md | Technical choices come up | Languages, frameworks, tools, constraints |
| open-loops.md | Every session (auto) | Active follow-ups, deadlines, commitments |
```

### Today's Daily Log

Create `memory/daily/[today's date].md` with the daily log template.

### Output

After creating everything, display a summary:

```
Total Recall initialized.

Created:
  CLAUDE.local.md             (working memory — auto-loaded every session)
  memory/SCHEMA.md            (protocol docs — loaded every session)
  memory/daily/[date].md      (today's daily log)
  memory/registers/           (6 domain registers + index)
  memory/archive/             (for completed/superseded items)

Protocol: .claude/rules/total-recall.md (auto-loaded)
Hooks: SessionStart + PreCompact (if configured)

Quick start:
  /recall-write <note>    Save something to memory (→ daily log first)
  /recall-search <query>  Find in memory
  /recall-status          Check memory health
  /recall-promote         Promote daily log entries to registers
```
