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
| `system` | string | Ticket source system (e.g., jira) — ticket notes only |
| `ticket_key` | string | Ticket identifier within the system (e.g., BACK-1234) — ticket notes only |
| `project` | string | Project grouping (e.g., Jira epic) — ticket notes only |
| `team` | string | Team identifier (e.g., Jira project key) — ticket notes only |
| `assignee` | string | Ticket assignee — ticket notes only |
| `priority` | string | Priority level if explicitly set |

## Wikilinks

Use `[[wikilinks]]` to connect related notes:

- Link to work streams: `[[Work Stream Name]]`
- Link to PRs: `[[repo-123]]` (matching the filename in `notes/prs/`)
- Link to tickets: `[[jira-BACK-1234]]` (matching the filename in `notes/tickets/`)
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
- Ticket notes: `<system>-<KEY>.md` (e.g., `jira-BACK-1234.md`)
- Work streams: `<work-stream-name>.md` (e.g., `error-handling-overhaul.md`)
- Todos: a single running list at `notes/todos/running.md` (no per-stream todo files)
- Completed todos: archived in `notes/todos/completed.md`, organized by `## YYYY-MM-DD` headings (newest first)
- Recaps: `YYYY-MM-DD.md` for daily, `week-YYYY-WW.md` for weekly

## Running Todo List

All open todos live in one file, `notes/todos/running.md`. Each item is a Markdown checkbox line with pipe-separated inline fields after an em-dash:

```markdown
- [ ] Task description [[optional-link]] — workstream: <name> | source: <type> | added: YYYY-MM-DD | due: YYYY-MM-DD | stakeholder: @person
```

### Item Fields

| Field | Required | Description |
|-------|----------|-------------|
| `workstream` | yes | Name of the related work stream (must match a file in `notes/workstreams/`) |
| `added` | yes | ISO date (YYYY-MM-DD) when the item was added |
| `due` | optional | ISO date (YYYY-MM-DD) by which the item should be done. If omitted, the item is always eligible for today's plan (no deadline). |
| `source` | optional | Origin of the item: `help-request`, `followup`, `meeting-action`, `self`. Populated fully in Phase B1 — omit if unknown for now. |
| `stakeholder` | optional | `@handle` of the person the item primarily serves (requester for help-requests, attendee for meeting actions, etc.) |
| `completed` | on completion | ISO date when the checkbox is ticked. Append to the same trailing segment, then move the line into `completed.md` (see "Completing items"). |

### Rules

- Unknown optional fields are omitted rather than written empty.
- Keep the task description before the em-dash; fields come after.
- Put `[[wikilinks]]` and `#tags` in the description portion, not the fields.
- Skills that add items MUST populate `workstream` and `added` at minimum.

### Completing items

Completion is conversational — the user says "I finished X" / "wrapped up Y" and the agent:

1. Finds the matching `- [ ]` line in `notes/todos/running.md`.
2. Flips the box to `- [x]` and appends ` | completed: YYYY-MM-DD` (today, unless the user gave a different date).
3. Removes that line from `running.md`.
4. Appends it to `notes/todos/completed.md` under a `## YYYY-MM-DD` heading for today, creating that heading at the top of the file if it doesn't already exist (newest day first).
5. Writes the standard `[complete-todo]` action entry to today's daily log.

Completed items NEVER linger in `running.md`. The move is immediate, not a deferred sweep. If a user manually flips a `[ ]` to `[x]` in `running.md` (in their editor) without telling the agent, the next skill that reads `running.md` should treat any `[x]` lines it finds there as stragglers and migrate them on encounter.

### Snoozing

To snooze an item, edit its `due` field to a later date. That's the whole mechanism — there is no separate snooze state. An item with `due: 2026-04-20` is simply not eligible for today's plan until that date arrives (see `/daily-plan` for the filtering rules). To defer indefinitely, remove the `due` field — but note that undated items are always eligible; if you want to hide something from the active plan, push the `due` date out instead.

## Completed Todos Archive

Completed running-list items live in `notes/todos/completed.md`. The file is grouped by completion date — one `## YYYY-MM-DD` heading per day, newest first, each followed by the `- [x]` lines that completed on that date:

```markdown
## 2026-04-17
- [x] Audit timeout paths in backflow [[backflow-142]] — workstream: error-handling-overhaul | added: 2026-03-28 | completed: 2026-04-17
- [x] Document retry policy — workstream: error-handling-overhaul | added: 2026-04-02 | completed: 2026-04-17

## 2026-04-15
- [x] Land Linear ticket parity — workstream: eddy-development | added: 2026-04-08 | completed: 2026-04-15
```

Rules:

- Each item keeps its full pipe-separated field set; `completed: YYYY-MM-DD` matches the heading it sits under.
- Insert new completions at the TOP of the relevant day's section (most recent completion first within a day).
- If today's heading doesn't exist yet, add it as the new top section before any older days.
- Never reorder existing days; just prepend.
- Skills only write to this file in two cases: (a) the user marks a running-list item complete, or (b) a skill encounters a straggler `[x]` line in `running.md` and migrates it here per the "Completing items" rules. `/recap` and `/whats-next` otherwise read it as context.

## Work Stream Sovereignty

Skills MUST NEVER create or modify work stream files without explicit user confirmation. A skill may:
- Read work streams to match tasks
- Suggest creating a new work stream
- Suggest updating an existing work stream

But MUST ask the user before making any changes.
