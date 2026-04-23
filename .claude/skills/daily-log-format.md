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
- **09:15** — [new-task] Started "fix-auth-timeout" with repos: backflow, graphql-edge-workers → [[error-handling-overhaul]]
- **09:30** — [ingest] Captured Slack message from @alice re: auth errors → [[2026-04-04-auth-error-discussion]]
- **10:00** — [new-task] Created "draft-rollout-message" (output: draft message) → [[platform-rollout]]
- **14:00** — [my-prs] Updated PR [[backflow-142]] — 2 review comments addressed, 1 remaining
```

### Action Types

Use these prefixes in brackets:

| Prefix | Skill |
|--------|-------|
| `new-task` | /new-task |
| `complete-task` | task completion workflow (see `notes/templates/task.md`) |
| `ingest` | /ingest |
| `my-prs` | /my-prs |
| `review-prs` | /review-prs |
| `jira` | /jira |
| `linear` | /linear |
| `daily-plan` | /daily-plan |
| `recap` | /recap |
| `architecture` | /architecture |
| `idea` | /idea |
| `setup` | /eddy-setup |
| `checkpoint` | /checkpoint |

## Creating the Daily Log

If the daily log for today doesn't exist when a skill needs to append to it, create it using the template above, then append the entry.

## Timestamps

Fetch the current system time **immediately before writing each Activity Log entry** — run `date +%H:%M` right before the write and use that value verbatim. Do NOT reuse a timestamp captured earlier in the conversation (e.g., from session start, an earlier tool call, or the skill's first step). Long-running skills, tool chains, and waits can drift a cached timestamp by many minutes, which corrupts the chronological spine the daily log is meant to provide.
