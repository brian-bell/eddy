# Work Stream Format

Work streams are defined as individual markdown files in `notes/workstreams/`. Each represents a coherent body of work (like an epic or initiative).

## Template

```markdown
---
status: active
repos: [repo1, repo2]
jira_epic: PROJ-1234
description: "Brief one-line description"
---

# Work Stream Name

## Description
Longer description of what this work stream encompasses and its goals.

## Related
- Repos: [[repo1]], [[repo2]]
- Jira Epic: [[PROJ-1234]]
- PRs: <!-- links added as PRs are created -->

## Tasks
<!-- Populated ONLY by /start-coding — a historical log of coding tasks kicked off for this stream. -->

## Notes
<!-- Prose: decisions, observations, open questions -->

## Links & Context
<!-- Pointers: screenshots, decision docs, external references, linked squawk items -->
```

Work streams are a **doc-of-docs**, not a progress tracker. Day-to-day todos live in the single running list at `notes/todos/running.md` (tagged with `workstream: <name>`), NOT in the work stream file itself. The `## Tasks` section is the one exception: `/start-coding` appends a bullet there each time a coding task folder is scaffolded, giving the stream a durable record of the coding sessions that contributed to it. No other skill writes to `## Tasks`.

## Reading Work Streams

To load active work streams, read all `.md` files in `notes/workstreams/`. Parse the YAML frontmatter to get:
- `status` — filter for `active` streams when matching tasks
- `repos` — list of related repository names (matching entries in `repos.md`)
- `jira_epic` — associated Jira epic key
- `description` — for semantic matching when categorizing tasks

## Matching Tasks to Work Streams

When a new task needs to be categorized:
1. Read all active work streams
2. Compare the task description against work stream descriptions, repos, and Jira epics
3. Present the best match(es) to the user
4. If no good match, suggest creating a new work stream (but NEVER create without user confirmation)

## Todos

All open todos across all work streams live in a single running list at `notes/todos/running.md`. Per-work-stream todo files are not used. See the "Running Todo List" section in `vault-conventions.md` for the item format and required fields.
