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
3. **If the task has a `JOURNAL.md` (coding task with a scaffolded task folder), synthesize a retrospective and gate the workstream write on user approval** — see "Retrospective synthesis" below.
4. Append ` | ended: YYYY-MM-DD` to the matched bullet in place. Don't touch any other section of the work stream file, and don't modify the `started:` date.
5. Append an entry to today's daily log: `- **HH:MM** — [complete-task] Marked "<task-name>" ended <YYYY-MM-DD> in [[<work-stream>]]`.
6. Tell the user what line was updated, the task's duration (end − start), and — if a retrospective was written — that the work stream's `## Notes` section was updated.

**Task folder is left intact** (cloned repos, unpushed branches, `JOURNAL.md` history). The user deletes it manually once they're sure nothing is left behind.

## Retrospective synthesis

This step runs only when the task has a populated `JOURNAL.md`. When the matched bullet is a non-coding task or the task folder has no `JOURNAL.md` (pre-feature folder, manually removed, non-coding task, etc.), **skip this section entirely** and fall through to step 4 unchanged.

Locate the task folder: read `config.md` for the Dev Directory (default `~/dev`), then look for `<dev-dir>/<task-name>/JOURNAL.md`. If the folder or journal is absent, skip.

If present:

1. Read the journal:
   - State header via `.claude/hooks/journal-ops.py read-state <path>`.
   - Full `## Log` section (all `[session]` and `[checkpoint]` entries).
2. Synthesize a retrospective block with exactly these four subsections, in this order:

   ```markdown
   ### Retrospective: <task-name> (ended YYYY-MM-DD)

   **Outcome**
   <2–4 sentences on what shipped, what didn't, and why.>

   **Key Decisions**
   - <decision 1, with short rationale>
   - <decision 2>

   **Outputs / PRs**
   - <PR link, doc, artifact — use [[wikilinks]] for PR notes like [[repo-123]] if present>

   **Lessons / Follow-ups**
   - <one insight or open thread worth remembering>
   ```

   Draw only from the journal + well-known project context (repos.md, ARCHITECTURE.md). Do not invent outcomes that aren't attested by the journal.
3. Show the draft to the user and ask for explicit approval:
   > "I'll append this retrospective to `notes/workstreams/<work-stream>.md` under `## Notes`. OK to write as-is, edit first, or skip?"
4. **Only on approval**, append the retrospective block to the workstream's `## Notes` section. Preserve all other sections exactly.
   - If the user asks to edit: iterate on the draft, then re-confirm before writing.
   - If the user declines: skip the workstream write entirely and proceed to step 4 of the outer flow. Completion still succeeds.
5. Do NOT modify `notes/todos/running.md` from this flow — the journal's Next Steps section is private to the task and does not sync to the running list.

This matches eddy's standing rule: never modify a work stream file without explicit user confirmation (see `vault-conventions.md`).

## Rules

- ISO dates only (`YYYY-MM-DD`).
- Pre-existing lines in the older `started YYYY-MM-DD` form (no colon) should be normalized to `started: YYYY-MM-DD` when they're touched for completion.
- This template is the source of truth for the line format. `/new-task` writes the open form; the completion workflow above appends `ended:`.
- Tasks (this section) are separate from running-list todos (`notes/todos/running.md`). Don't conflate the two: the running list is day-to-day action items added by `/ingest` or manual entry as work progresses; the `## Tasks` section is a durable log of task kickoffs per work stream.
