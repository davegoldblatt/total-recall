Quick append to today's daily log. No write gate — raw capture.

Note to log: $ARGUMENTS

## What To Do

1. Create today's daily log file (`memory/daily/YYYY-MM-DD.md`) if it doesn't exist, using the daily log template
2. Append a timestamped entry:

```
[HH:MM] note text
```

3. Confirm:

```
Logged to memory/daily/[date].md
```

That's it. No gate, no analysis, no routing. This is for quick capture when the user doesn't want the write gate overhead.
