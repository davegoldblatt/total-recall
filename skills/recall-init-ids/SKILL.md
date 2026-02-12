---
description: Add durable IDs to memory entries. Required before /recall-maintain can run.
disable-model-invocation: true
---
Add `^tr` IDs to untagged memory entries in managed files. This is safe to run multiple times - it only tags entries that don't already have IDs.

## What To Do

### 1. Identify Managed Files

Scan these locations for single-line list item entries:

- `CLAUDE.local.md` (working memory)
- `memory/registers/*.md` (all register files)
- `memory/archive/**/*.md` (archived entries, if they exist as list items)

**Do NOT scan** `memory/daily/*.md` - daily logs are not managed by the remove gate.

### 2. Parse Entries

An entry is exactly:

- A line starting with `- ` (dash + space)
- Single line only (the entire entry is on one line)
- NOT inside a fenced code block (``` markers)
- NOT a placeholder like `- [None captured yet]` or `- [None yet]` or `- [not yet set]`

**Already tagged**: If the line ends with ` ^tr` followed by exactly 10 lowercase hex characters, it already has an ID. Skip it.

**Malformed tag**: If the line ends with ` ^` followed by other text that doesn't match the `tr[0-9a-f]{10}` pattern, warn and skip it. Do not attempt to repair.

### 3. Show Preview

Before making any changes, show the user what will happen:

```
recall-init-ids — preview
━━━━━━━━━━━━━━━━━━━━━━━━━

Files scanned: [N]
Entries found: [N] total
  Already tagged: [N]
  Will be tagged: [N]
  Skipped (malformed): [N]

Examples:

  CLAUDE.local.md:
    Before: - Don't blast into writing code unless explicitly told to
    After:  - Don't blast into writing code unless explicitly told to ^tr8f2a1c3d7e

  registers/preferences.md:
    Before: - Prefers tabs over spaces
    After:  - Prefers tabs over spaces ^tra4b2c1d9e0

Apply? [y]es / [c]ancel
```

Show up to 5 before/after examples, spread across different files.

**If no untagged entries are found**, report that and exit:
```
All [N] entries already have IDs. Nothing to do.
```

### 4. Generate IDs

For each entry to be tagged:

1. Generate an ID: `tr` + 10 random lowercase hex characters (use crypto-secure randomness)
2. Check for collisions against:
   - All existing inline IDs found during parsing
   - All IDs already generated in this run
   - All keys in `memory/.recall/metadata.json` (if it exists)
3. If collision, regenerate. (Extremely unlikely with 10 hex chars, but be safe.)
4. Append ` ^[id]` to the end of the line

### 5. Apply Changes

Only after user confirms:

1. **Rewrite each file** with IDs appended to eligible entry lines. Do not modify any other lines in the file.

2. **Create or update `memory/.recall/metadata.json`**:
   - Create `memory/.recall/` directory if it doesn't exist
   - For each new ID, add an entry:
     ```json
     {
       "tr8f2a1c3d7e": {
         "created_at": "2026-02-12T10:15:30Z",
         "last_reviewed_at": "2026-02-12T10:15:30Z",
         "pinned": false,
         "snoozed_until": null,
         "status": "active",
         "tier": "working"
       }
     }
     ```
   - Set `tier` based on file location:
     - `CLAUDE.local.md` -> `"working"`
     - `memory/registers/*` -> `"register"`
     - `memory/archive/*` -> `"archive"`
   - For entries with existing inline IDs that are missing from metadata.json, add them without changing the file
   - Write JSON with sorted keys for readable diffs

### 6. Summary

```
recall-init-ids — complete
━━━━━━━━━━━━━━━━━━━━━━━━━━

Tagged: [N] entries across [M] files
Metadata: [N] entries in memory/.recall/metadata.json

Files modified:
  CLAUDE.local.md          [N] entries tagged
  registers/preferences.md [N] entries tagged
  ...

You can now run /recall-maintain for pressure-based memory cleanup.
```

### Important Notes

- This command is idempotent. Running it again will only tag NEW untagged entries.
- If a user manually removes an ID from an entry, running this command will re-tag it with a NEW ID (losing pin/snooze/review history for that entry).
- Metadata.json is the source of truth for pin/snooze/review state. The inline ID is the link between the entry text and its metadata.
