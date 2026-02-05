Write a note to memory, applying the write gate. Default destination: daily log.

The user's note: $ARGUMENTS

## Write Gate Protocol

Before writing, evaluate:

1. **Does it change future behavior?** (preference, boundary, recurring pattern) → WRITE
2. **Is it a commitment with consequences?** (deadline, deliverable, follow-up) → WRITE
3. **Is it a decision with rationale?** (why X over Y, worth preserving) → WRITE
4. **Is it a stable fact that will matter again?** (not transient, not obvious) → WRITE
5. **Did the user explicitly say "remember this"?** → ALWAYS WRITE

If NONE of these are true, tell the user why it didn't pass the gate. Suggest `/recall-log` for raw capture without the gate.

## Default: Write to Daily Log

ALL writes go to `memory/daily/YYYY-MM-DD.md` first. Create the file if it doesn't exist:

```markdown
# YYYY-MM-DD

## Decisions

## Corrections

## Commitments

## Open Loops

## Notes
```

Append a timestamped entry under the appropriate section:
```
[HH:MM] note text here
```

## Suggest Promotion (Don't Auto-Promote)

After writing to the daily log, if the note seems durable, **suggest** where it could be promoted — but don't do it automatically:

```
Written to memory/daily/2026-02-05.md:
  [14:32] User prefers bullet points over prose for summaries

This looks like a lasting preference. Want me to also promote it to:
  → memory/registers/preferences.md
  → CLAUDE.local.md (if it should affect every session)
```

The user decides. If they say yes, write to the register with metadata:
```markdown
- **claim**: [the fact/preference/decision]
- **confidence**: high | medium | low
- **evidence**: [how we know — user said, observed, corrected]
- **last_verified**: [today's date]
```

## Exceptions: Direct Promotion

These can skip the "suggest" step and promote directly (but still write to daily log too):

1. **Explicit corrections** — user corrects a prior memory entry. Update the register immediately, mark old entry as `[superseded: date]`.
2. **Explicit "remember this"** — user clearly wants it stored durably. Write to the appropriate register.
3. **Deadline/commitment** — always goes to `registers/open-loops.md` AND daily log.

## Contradiction Check

Before writing, quickly check existing memory for related claims:
1. Check CLAUDE.local.md
2. Check relevant register (if promoting)

If a contradiction is found:
- Show the user: "Existing memory says [X]. You're now saying [Y]. Update?"
- Mark old entry as `[superseded: date]` with reason
- Write new entry

## After Writing

Confirm to the user:
```
Noted in memory/daily/[date].md: [one-line summary]
```

If also promoted: mention the additional destination.
