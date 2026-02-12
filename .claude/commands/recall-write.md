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

## ID Assignment on Promotion

When writing an entry to CLAUDE.local.md or a register (either via direct promotion or user-confirmed promotion), assign a durable ID:

1. Generate an ID: `^tr` + 10 random lowercase hex characters
2. Check for collisions against existing IDs in `memory/.recall/metadata.json` (if it exists) and any inline IDs visible in the destination file
3. Append ` ^[id]` to the end of the entry line (for single-line list items starting with `- `)
4. Create or update `memory/.recall/metadata.json` with an entry for the new ID:
   ```json
   {
     "created_at": "[ISO 8601 timestamp]",
     "last_reviewed_at": "[ISO 8601 timestamp]",
     "pinned": false,
     "snoozed_until": null,
     "status": "active",
     "tier": "working"
   }
   ```
   Set `tier` to `"working"` for CLAUDE.local.md or `"register"` for register files.
5. Create the `memory/.recall/` directory if it doesn't exist
6. Write metadata.json with sorted keys and 2-space indentation

**Daily log entries do NOT get IDs.** Only entries promoted to CLAUDE.local.md or registers are tagged.

**Multi-line metadata blocks** (claim/confidence/evidence/last_verified format) are not tagged with IDs in v1. Only single-line list items get IDs.

## After Writing

Confirm to the user:
```
Noted in memory/daily/[date].md: [one-line summary]
```

If also promoted: mention the additional destination and the assigned ID.
