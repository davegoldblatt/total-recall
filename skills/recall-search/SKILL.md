---
description: Search across all memory tiers (registers, daily logs, archive) for relevant information.
argument-hint: <query>
---
Search across all memory tiers for relevant information.

Query: $ARGUMENTS

## Search Protocol

Search in this order (narrow to wide):

### 1. Working Memory (CLAUDE.local.md)
Already loaded — check if the answer is here first.

### 2. Registers (memory/registers/*.md)
Search all register files for content matching the query:
- people.md
- projects.md
- decisions.md
- preferences.md
- tech-stack.md
- open-loops.md
- Any other .md files in registers/

### 3. Recent Daily Logs (memory/daily/)
Search the last 14 days of daily logs. Start with most recent.

### 4. Archive (memory/archive/)
Only search here if nothing found in tiers 1-3, or if the query explicitly asks about historical/past items.

## How to Search

Use grep/ripgrep across the memory directory for matching content. This is keyword/pattern matching — search for relevant terms, synonyms, and related phrases.

## Output Format

Present results grouped by source, most relevant first:

```
Found [N] relevant entries:

[registers/decisions.md] (confidence: high)
  2026-01-15: Chose JWT over session cookies for stateless scaling

[registers/tech-stack.md] (confidence: high)
  Auth: JWT tokens with 24h expiry, refresh via /auth/refresh

[daily/2026-02-01.md]
  [14:32] Discussed adding OAuth2 for third-party integrations, decided to defer
```

## If Nothing Found

Tell the user:
```
No matching entries found in memory.

Searched: CLAUDE.local.md, [N] registers, [N] daily logs, [N] archive files.
```

Suggest they use `/recall-write` to capture the information if they have it.

## Important

- Show the actual content, not just file names
- Include confidence levels when available on register entries
- Show dates and timestamps for daily log entries
- If a result is marked `[superseded]`, note that and show the current entry instead
- Do NOT fabricate results — only return what's actually in the files
