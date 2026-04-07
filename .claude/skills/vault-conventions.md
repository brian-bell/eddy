# Vault Conventions

All skills that create or modify notes in the `notes/` vault MUST follow these conventions.

## Frontmatter

Every note starts with YAML frontmatter between `---` fences:

```yaml
---
field: value
date: YYYY-MM-DD
tags: [tag1, tag2]
---
```

### Standard Frontmatter Fields

These fields are used across note types. Only include fields relevant to the note type.

| Field | Type | Description |
|-------|------|-------------|
| `date` | string | ISO date (YYYY-MM-DD) when the note was created |
| `tags` | list | Categorization tags (lowercase, hyphenated) |
| `work_stream` | string | Name of the related work stream (must match a file in `notes/workstreams/`) |
| `source` | string | Origin of the content (slack, email, meeting, etc.) — squawk notes only |
| `category` | string | Inferred category (no fixed list, infer from content) |
| `related_streams` | list | Work streams related to the note (soft link, idea notes only) |
| `actionable` | boolean | Whether the note contains action items |
| `status` | string | Current status (e.g., open, in_progress, closed, changes_requested) |
| `repo` | string | Related repository name (must match an entry in `repos.md`) |
| `pr` | number | Pull request number — PR notes only |
| `title` | string | Human-readable title |
| `reviewers` | list | GitHub usernames of reviewers — PR notes only |
| `jira_key` | string | Jira ticket key (e.g., BACK-1234) — Jira notes only |
| `epic` | string | Jira epic name — Jira notes only |
| `assignee` | string | Jira assignee — Jira notes only |
| `priority` | string | Priority level if explicitly set |

## Wikilinks

Use `[[wikilinks]]` to connect related notes:

- Link to work streams: `[[Work Stream Name]]`
- Link to PRs: `[[repo-123]]` (matching the filename in `notes/prs/`)
- Link to Jira tickets: `[[BACK-1234]]` (matching the filename in `notes/jira/`)
- Link to daily logs: `[[YYYY-MM-DD]]`
- Link to other notes by their filename (without extension)

When creating a note, add wikilinks to all related entities. This builds the knowledge graph.

## Tags

Use `#tags` in the note body (not just frontmatter) for quick visual filtering in Obsidian:

- Use lowercase, hyphenated tags: `#error-handling`, `#backend`
- Tag with repo names: `#backflow`, `#wtui`
- Tag with source types in squawk notes: `#slack`, `#email`
- Keep tags consistent — reuse existing tags from the vault

## Daily Log Entries

Every skill that creates or modifies vault data MUST append a summary entry to today's daily log at `notes/daily/YYYY-MM-DD.md`. See `daily-log-format.md` for the format.

## File Naming

- Daily logs: `YYYY-MM-DD.md`
- Squawk notes: `YYYY-MM-DD-<short-slug>.md` (e.g., `2026-04-04-auth-error-discussion.md`)
- Idea notes: `YYYY-MM-DD-<short-slug>.md` (e.g., `2026-04-06-cli-dashboard.md`)
- PR notes: `<repo>-<number>.md` (e.g., `backflow-142.md`)
- Jira notes: `<TICKET-KEY>.md` (e.g., `BACK-1234.md`)
- Work streams: `<work-stream-name>.md` (e.g., `error-handling-overhaul.md`)
- Todo files: `<work-stream-name>.md` (matches the work stream name)
- Recaps: `YYYY-MM-DD.md` for daily, `week-YYYY-WW.md` for weekly

## Work Stream Sovereignty

Skills MUST NEVER create or modify work stream files without explicit user confirmation. A skill may:
- Read work streams to match tasks
- Suggest creating a new work stream
- Suggest updating an existing work stream

But MUST ask the user before making any changes.
