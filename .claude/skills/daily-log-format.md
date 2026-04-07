# Daily Log Format

Daily logs live at `notes/daily/YYYY-MM-DD.md`. They serve as the chronological spine of each day.

## Template

When creating a new daily log, use this structure:

```markdown
---
date: YYYY-MM-DD
---

# YYYY-MM-DD

## Plan
<!-- Populated by /daily-plan -->

## Activity Log
<!-- Entries appended throughout the day by skills -->

## Notes
<!-- Manual notes, observations, thoughts -->
```

## Appending Entries

When a skill performs an action, append a timestamped entry to the **Activity Log** section:

```markdown
- **HH:MM** — [action type] Description with [[wikilinks]] to related notes
```

Examples:

```markdown
- **09:15** — [new-task] Created task "Fix auth timeout" in [[Error Handling Overhaul]] → [[error-handling-overhaul]]
- **09:30** — [ingest] Captured Slack message from @alice re: auth errors → [[2026-04-04-auth-error-discussion]]
- **10:00** — [start-coding] Started coding task "fix-auth-timeout" with repos: backflow, graphql-edge-workers
- **14:00** — [my-prs] Updated PR [[backflow-142]] — 2 review comments addressed, 1 remaining
```

### Action Types

Use these prefixes in brackets:

| Prefix | Skill |
|--------|-------|
| `new-task` | /new-task |
| `ingest` | /ingest |
| `start-coding` | /start-coding |
| `my-prs` | /my-prs |
| `review-prs` | /review-prs |
| `jira` | /jira |
| `daily-plan` | /daily-plan |
| `recap` | /recap |
| `architecture` | /architecture |
| `idea` | /idea |

## Creating the Daily Log

If the daily log for today doesn't exist when a skill needs to append to it, create it using the template above, then append the entry.

Use the current time from the system when creating timestamps.
