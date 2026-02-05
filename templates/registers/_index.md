# Register Index

> This file lists all available registers and when to load them.
> Claude reads this on session start to know what memory domains exist.

| Register | Load When | Contains |
|----------|-----------|----------|
| people.md | A person is mentioned | Roles, preferences, contact context, relationship notes |
| projects.md | A project is discussed | Project state, goals, key decisions, blockers, timelines |
| decisions.md | Past choices are questioned | Decisions with rationale, alternatives considered, outcomes |
| preferences.md | Task involves user style/prefs | Code style, communication style, workflow preferences |
| tech-stack.md | Technical choices come up | Languages, frameworks, tools, versions, constraints |
| open-loops.md | Every session (auto-loaded) | Active items needing follow-up, deadlines, commitments |

## Adding New Registers

Create a new `.md` file in this directory and add a row to the table above.
Name it semantically — e.g., `clients.md`, `health.md`, `finances.md`.

Each register should have:
1. A header comment explaining when to load it and what belongs
2. Entries using the metadata schema (claim, confidence, evidence, last_verified)
