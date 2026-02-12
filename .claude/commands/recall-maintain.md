Run maintenance on the memory system. Primary function: pressure-based demotion when working memory exceeds the word budget. Secondary: stale entry verification, contradiction checks, open loop review.

## What To Do

### 0. Preconditions

**Check for IDs first.** Scan all managed files (CLAUDE.local.md, memory/registers/*.md, memory/archive/**/*.md) for single-line list item entries (lines starting with `- `, not inside code blocks, not placeholders).

- If ANY managed entry lacks an ID (no `^tr[0-9a-f]{10}` at end of line): **refuse to run**.
  ```
  Cannot run maintain: [N] entries are missing IDs.
  Run /recall-init-ids first to tag all entries.
  ```

- If ANY duplicate IDs are found across entries: **refuse to run**.
  ```
  Cannot run maintain: duplicate ID found.
  ID: ^tr8f2a1c3d7e
    1. CLAUDE.local.md line 15
    2. registers/preferences.md line 8
  Resolve manually before running maintain.
  ```

If preconditions pass, proceed.

### 1. Load and Reconcile

**Parse entries** from all managed files. For each entry, extract:
- The entry text (everything between `- ` and ` ^tr...`)
- The ID (the `^tr[0-9a-f]{10}` token)
- The file path and line number
- The tier (derived from file location):
  - `CLAUDE.local.md` -> `working`
  - `memory/registers/*` -> `register`
  - `memory/archive/*` -> `archive`

**Load metadata** from `memory/.recall/metadata.json`:
- If file doesn't exist, create it as empty `{}`
- For each inline ID missing from metadata, create a metadata entry with `created_at=now`, `last_reviewed_at=now`, `pinned=false`, `snoozed_until=null`, `status=active`, tier from file
- For each metadata entry, recompute `tier` from file location (file location is authoritative - overwrite metadata tier if it differs)

### 2. Compute Working Memory Pressure

Count words in working memory entries only (tier=working):
- For each working entry, count whitespace-separated tokens in the entry text
- Exclude the leading `- ` and trailing ` ^tr...` from word count
- Sum all working entry word counts = `working_words`
- Target = 1500 words

Report:
```
Working memory: [working_words] words (target: 1500)
```

### 3. Select Candidates

#### A. Pressure Candidates (only if working_words > 1500)

From working entries, exclude:
- Entries with `pinned: true` in metadata
- Entries with `snoozed_until` in the future

Score remaining working entries:
```
score = 1.0 * word_count(entry) + 0.1 * days_since(last_reviewed_at)
```
(If `last_reviewed_at` is missing, treat as 365 days.)

Sort by score descending. Take the top candidates until the sum of their word counts >= (working_words - 1500). This is the minimum set needed to bring working memory under budget.

#### B. Superseded Cleanup (always, regardless of pressure)

Find any entry across all tiers where metadata has `status: "superseded"` and tier is NOT `archive`. These should be archived.

### 4. Present Candidates

If no candidates (under budget and no superseded entries):
```
recall-maintain — all clear
━━━━━━━━━━━━━━━━━━━━━━━━━━

Working memory: [N] words (target: 1500) - under budget
No superseded entries pending cleanup.
No action needed.
```

Otherwise, present each candidate with its reason:

```
recall-maintain — [N] candidates
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Working memory: [working_words] words (target: 1500, over by [N])

Pressure candidates (need to free [N] words):

1. [CLAUDE.local.md] 23 words, last reviewed 45 days ago
   "Dave prefers concise error messages and no unnecessary logging"
   → [k]eep / [p]in / [s]nooze / [d]emote / [a]rchive / [m]ark superseded

2. [CLAUDE.local.md] 18 words, last reviewed 30 days ago
   "Current deployment target is AWS us-east-1 with fallback to us-west-2"
   → [k]eep / [p]in / [s]nooze / [d]emote / [a]rchive / [m]ark superseded

Superseded cleanup:

3. [registers/tech-stack.md] status: superseded
   "Using Node 16 in production"
   → [a]rchive (recommended) / [k]eep

Apply all / decide individually?
```

### 5. Execute Actions

For each candidate, apply the chosen action:

**keep**: Update `last_reviewed_at` to now in metadata. No file changes.

**pin**: Set `pinned: true` and update `last_reviewed_at` in metadata. No file changes. Entry will be excluded from future pressure candidates.

**snooze**: Set `snoozed_until` to now + 30 days (or user-specified duration) and update `last_reviewed_at` in metadata. No file changes. Entry will be excluded from pressure candidates until the snooze expires.

**demote** (working -> register):
1. Remove the entry line from CLAUDE.local.md
2. Append the entry line (with ID) to `memory/registers/_inbox.md`
   - Create `_inbox.md` with header if it doesn't exist:
     ```markdown
     # Inbox
     > Entries demoted from working memory. Review and file into appropriate registers.
     ```
3. Update metadata tier to `register` and `last_reviewed_at` to now

**archive** (working or register -> archive):
1. Remove the entry line from its current file
2. Append the entry line (with ID) to `memory/archive/ARCHIVE.md`
   - Create ARCHIVE.md with header if it doesn't exist:
     ```markdown
     # Archive
     > Archived memory entries. Searchable but never auto-loaded.
     ```
3. Update metadata: set `status: "archived"`, `tier: "archive"`, `last_reviewed_at` to now

**mark_superseded**: Set `status: "superseded"` and `last_reviewed_at` to now in metadata. No file changes. Entry will appear in superseded cleanup on next maintain run.

### File Editing Rules

When moving entries between files:
- Remove the ENTIRE line (including the `- ` prefix and `^tr...` suffix)
- Do NOT reflow, reformat, or modify any other lines in the source file
- Append the ENTIRE line to the destination file
- Preserve exact formatting of the entry text

### 6. Write Metadata

After all actions are applied, write `memory/.recall/metadata.json`:
- Sort keys alphabetically for readable diffs
- Use 2-space indentation
- Write deterministically (same input = same output)

### 7. Secondary Checks

After the pressure-based flow, run these additional checks (same as before):

**Stale entries**: Search registers for entries where metadata `last_reviewed_at` is older than 30 days. Present them:
```
Stale entries (not reviewed in 30+ days):
  1. [registers/tech-stack.md] Last reviewed: 2025-12-01
     "Using Postgres 15 in production" ^tra1b2c3d4e5
     → [v]erify (update last_reviewed_at) / [u]pdate / [a]rchive
```

**Contradictions**: Scan across tiers for conflicting claims on the same topic. Flag any found.

**Open loop review**: Check memory/registers/open-loops.md for items that are past due or resolved.

**Daily log archival**: If daily logs older than 30 days exist, suggest archiving to memory/archive/daily/.

### 8. Summary

```
recall-maintain — complete
━━━━━━━━━━━━━━━━━━━━━━━━━━

Working memory: [before] -> [after] words (target: 1500)

Actions taken:
  Kept (reviewed): [N]
  Pinned: [N]
  Snoozed: [N] (until [date])
  Demoted to _inbox.md: [N]
  Archived: [N]
  Marked superseded: [N]

Secondary checks:
  Stale entries verified: [N]
  Contradictions found: [N]
  Open loops reviewed: [N]
  Daily logs to archive: [N]

Metadata: [N] entries in memory/.recall/metadata.json
```
