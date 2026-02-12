Mark memory entries matching a query as superseded. Does not delete — preserves history.

Query to forget: $ARGUMENTS

## What To Do

### 1. Search for Matching Entries

Search across all memory tiers for content matching the query:
- memory/CLAUDE.local.md
- memory/registers/*.md
- memory/daily/*.md

### 2. Show Matches

```
Found [N] entries matching "[query]":

1. [CLAUDE.local.md] "Prefers dark mode for all mockups"
2. [registers/preferences.md] "Dark mode preference (confidence: high, 2026-01-10)"
3. [daily/2026-01-10.md] "[14:00] User said they prefer dark mode"
```

### 3. Confirm with User

```
Mark these as superseded? This won't delete them — they'll be annotated as no longer current.

[a]ll / select by number / [c]ancel
```

### 4. Execute

For each confirmed entry:

**In registers:** Mark as superseded with date
```markdown
## [superseded: 2026-02-05]
- **claim**: Prefers dark mode for all mockups
- **superseded_by**: User requested removal via /recall-forget
- **original_date**: 2026-01-10
```

**In CLAUDE.local.md:** Remove the entry entirely (working memory should only contain current facts)

**In daily logs:** Add a note but don't modify the original entry (daily logs are historical record)
```
[HH:MM] [superseded] "Prefers dark mode" — marked as no longer current via /recall-forget
```

### 5. Update Metadata

If any superseded entry has an inline `^tr` ID:
1. Load `memory/.recall/metadata.json` (if it exists)
2. For each entry with an ID, set `status: "superseded"` and update `last_reviewed_at` to now
3. Write metadata.json with sorted keys and 2-space indentation

Entries without IDs are handled as before (no metadata update).

### 6. Confirm

```
Superseded [N] entries for "[query]".
Memory updated across [N] files.
Metadata updated: [N] entries marked superseded.
```
