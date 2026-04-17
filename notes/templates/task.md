---
type: task
---

# Task Line Template

A task lives as one line in a work stream's `## Tasks` section. There are two variants (coding vs. non-coding) and two states (open vs. completed).

## Open — coding task

```
- <task-name>: <brief description> — started: YYYY-MM-DD
```

Written by `/new-task` in coding mode when a task folder is scaffolded. `<task-name>` is the kebab-case folder name; `<brief description>` is a short phrase explaining the task.

## Open — non-coding task

```
- <task-name>: <brief description> (output: <artifact-type>) — started: YYYY-MM-DD
```

Written by `/new-task` in non-coding mode. `<task-name>` is a kebab-case identifier (no folder is created). `<artifact-type>` is the captured deliverable type (doc, slides, draft message, email, spec, meeting notes, review, research summary, other).

## Completed

Append ` | ended: YYYY-MM-DD` to the open line. The start date never changes. A task can be reopened by removing the `| ended: ...` segment. Works the same for coding and non-coding variants:

```
- <task-name>: <brief description> — started: YYYY-MM-DD | ended: YYYY-MM-DD
- <task-name>: <brief description> (output: <artifact-type>) — started: YYYY-MM-DD | ended: YYYY-MM-DD
```

## Completion workflow

When the user reports a task done — by saying "I completed <task>", "I finished <task>", "<task> is done", "wrapped up <task> last Tuesday", or similar, or by invoking this template explicitly — the agent should:

1. Parse a completion date from the user's phrase (today if unstated; resolve "yesterday", "last Tuesday", "on April 14", etc. against today). If ambiguous, ask.
2. Find the matching open bullet in a work stream's `## Tasks` section (search by task-name first, then substring on the description). Ask to disambiguate if multiple open tasks match. If the only match is already completed, ask whether to overwrite.
3. Append ` | ended: YYYY-MM-DD` to that line in place. Don't touch any other section of the work stream file, and don't modify the `started:` date.
4. Append an entry to today's daily log: `- **HH:MM** — [complete-task] Marked "<task-name>" ended <YYYY-MM-DD> in [[<work-stream>]]`.
5. Tell the user what line was updated and the task's duration (end − start).

## Rules

- ISO dates only (`YYYY-MM-DD`).
- Pre-existing lines in the older `started YYYY-MM-DD` form (no colon) should be normalized to `started: YYYY-MM-DD` when they're touched for completion.
- This template is the source of truth for the line format. `/new-task` writes the open form; the completion workflow above appends `ended:`.
- Tasks (this section) are separate from running-list todos (`notes/todos/running.md`). Don't conflate the two: the running list is day-to-day action items added by `/ingest` or manual entry as work progresses; the `## Tasks` section is a durable log of task kickoffs per work stream.
