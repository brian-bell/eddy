# Ticket Format

Shared convention for ticket tracker skills. All ticket vault notes live in `notes/tickets/` regardless of source system.

## Frontmatter Schema

```yaml
---
system: jira                 # ticket tracker system
ticket_key: BACK-1234        # identifier within the system
title: "Fix auth timeout"
status: In Progress
project: Error Handling       # Jira epic or equivalent grouping
team: BACK                    # Jira project key or equivalent
assignee: brian-bell
priority: High
date: 2026-04-08
work_stream: Eddy Development
---
```

Required fields: `system`, `ticket_key`, `title`, `status`, `priority`, and `date`. All other fields are optional — include what's available from the tracker.

**Field mapping note:** `project` and `team` are system-agnostic names. In Jira, `project` maps to the epic name (or equivalent grouping) and `team` maps to the Jira project key (e.g., BACK). Other trackers should map their closest equivalents to these fields.

## File Naming

Files live in `notes/tickets/` and are named `{system}-{KEY}.md`:

- Jira: `jira-BACK-1234.md`

The system prefix prevents collisions if additional trackers are added in the future.

## Wikilinks

Link to tickets using the system-prefixed filename:

- `[[jira-BACK-1234]]`

## Ticket Note Template

Use `notes/templates/ticket.md` as the base. The body structure:

```markdown
# {KEY}: {title}

## Details
- **Status:** {status}
- **Project:** [[{project}]]
- **Assignee:** {assignee}
- **Priority:** {priority}

## Comments
<!-- Appended by comment mode -->

## Related
<!-- Links to work streams, PRs, notes -->
```

## Linking Tickets to Work Streams

Match tickets to work streams by checking:
- `jira_epic` field in work stream frontmatter (for Jira tickets)
- Semantic match between ticket title/description and work stream description

When a match is found, set the `work_stream` field in the ticket frontmatter and add a `[[Work Stream Name]]` wikilink in the Related section.

## How Consuming Skills Read Tickets

Skills like `/daily-plan`, `/whats-next`, `/recap`, and `/new-task` read from `notes/tickets/` **system-agnostically**. They filter by:
- `status` — e.g., In Progress, To Do
- `assignee` — match to the configured username
- `work_stream` — match to active work streams

They NEVER filter by `system`. All tickets are treated equally regardless of source.

## Daily Log Entries

Jira uses the `[jira]` action type prefix:

```markdown
- **09:15** — [jira] Searched Jira: error handling — found 3 tickets
- **09:30** — [jira] Created ticket [[jira-BACK-1234]]: Fix auth timeout
- **10:00** — [jira] Commented on [[jira-BACK-1234]]: investigating root cause
- **10:15** — [jira] Updated [[jira-BACK-1234]]: status → In Progress
```
