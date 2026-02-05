Write a note to memory, applying the write gate.

The user's note: $ARGUMENTS

## Write Gate Protocol

Before writing, evaluate:

1. **Does this change future behavior?** (preference, boundary, recurring pattern)
2. **Is this a commitment with consequences?** (deadline, deliverable, follow-up)
3. **Is this a decision with rationale?** (choice made, why X over Y)
4. **Is this a stable fact that will matter again?** (not transient, not obvious)
5. **Did the user explicitly say "remember this"?** (override — always write)

If NONE of these are true, tell the user why it didn't pass the gate and suggest `/recall-log` for raw capture.

## Determine Destination

Based on what the note contains:

| Content Type | Primary Destination | Also Update |
|---|---|---|
| Preference/style | registers/preferences.md | MEMORY.md if it affects every session |
| Person context | registers/people.md | MEMORY.md if actively engaging |
| Decision + rationale | registers/decisions.md | MEMORY.md if affects current work |
| Technical choice | registers/tech-stack.md | — |
| Commitment/deadline | registers/open-loops.md | MEMORY.md always |
| Correction of prior memory | Supersede old entry + write new | All locations where old claim exists |
| General behavioral note | memory/daily/[today].md | MEMORY.md if changes defaults |

## Contradiction Check

Before writing, search existing memory for related claims:

1. Read memory/MEMORY.md
2. Search memory/registers/ for related content
3. Check today's daily log

If a contradiction is found:
- DO NOT silently overwrite
- Show the user: "Existing memory says [X]. You're now saying [Y]. Should I update?"
- Mark old entry as `[superseded: date]` with reason
- Write new entry with reference to what it replaces

## Write Format

**For daily log entries** (memory/daily/YYYY-MM-DD.md):
```
[HH:MM] note text here
```

**For register entries**, include metadata:
```markdown
- **claim**: [the fact/preference/decision]
- **confidence**: high | medium | low
- **evidence**: [how we know — user said, observed, corrected]
- **last_verified**: [today's date]
```

## After Writing

Create today's daily log file if it doesn't exist. Always append a timestamped entry to the daily log, even if the primary destination is a register.

Confirm to the user:
```
Noted in [destination]: [one-line summary]
```

If the note was also written to additional locations, mention those too.
