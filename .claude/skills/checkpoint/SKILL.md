---
name: checkpoint
description: Checkpoint a task by rewriting the task folder's JOURNAL.md state header and appending a log entry. Use after significant events — decisions, pivots, blockers, end-of-session. Pass --promote to also add a dated line to the work stream's Notes section.
---

# Checkpoint

Capture the current state of work in the task folder's `JOURNAL.md`, so the
agent can resume cleanly next time and the workstream can (optionally)
inherit a pointer back to what just happened.

## When to use

- The user (or agent) made a significant decision or pivot.
- A blocker appeared or got resolved.
- A session is wrapping up and the agent wants to leave a clean handoff.
- The user says something like "checkpoint", "note this in the journal",
  or "let's mark where we are".
- With `--promote`: the moment is worth surfacing in the work stream
  (e.g., a milestone, a durable decision, a mid-task insight).

## Preconditions

This skill operates on the current working directory as a task folder.

- Task folder := a directory containing `CLAUDE.md` (scaffolded by
  `/new-task`) and a `JOURNAL.md`.
- If no `JOURNAL.md` is present, fall through to the **Init path** below.

## Process

### 1. Detect the task folder and journal

1. Check `$PWD` for `JOURNAL.md`.
2. If present, read it:
   - Parse frontmatter fields `task`, `workstream`, `created`.
   - Parse the current state header using Module A:
     ```sh
     <workflow-repo>/.claude/hooks/journal-ops.py read-state JOURNAL.md
     ```
3. If absent, go to the **Init path** in step 5.

### 2. Rewrite the state header

Based on the current conversation — recent tool calls, files touched,
decisions, and what's next — compose a new state region with these four
sections (in this order, all four always present, even if empty):

```markdown
## Current State
<1–4 sentences on where the task actually stands right now>

## Next Steps
- <concrete next action>
- <next action>

## Open Questions
- <unresolved question or decision needed>

## Blockers
- <what is blocking progress, or "None">
```

Do NOT invent content. If a section has nothing new, carry forward what's
already there (or leave it empty). The goal is truthful state, not
verbose state.

Write it in with Module A:

```sh
<workflow-repo>/.claude/hooks/journal-ops.py write-state JOURNAL.md < new-state
```

### 3. Append a `[checkpoint]` log entry

Append an entry that records the checkpoint moment. Format:

```markdown
### [checkpoint] <ISO-datetime> — <one-line reason>

<2–4 sentence body: what changed since the last entry, what this
checkpoint marks, what's explicitly deferred or decided>
```

- `<ISO-datetime>` — fetch fresh via `date -u +%Y-%m-%dT%H:%M:%SZ` **immediately**
  before writing. Do not reuse a cached timestamp.
- `<one-line reason>` — what this checkpoint is for (e.g., "decided on
  retry-with-backoff", "blocked on staging access", "end of session").
- Body — facts, not recap.

Append it with Module A:

```sh
<workflow-repo>/.claude/hooks/journal-ops.py append-log JOURNAL.md < entry
```

### 4. Optional: `--promote`

If the user invoked `/checkpoint --promote` (or said something like "note
this in the workstream"), additionally propose a single dated line for
the **work stream's `## Notes` section**:

```markdown
- YYYY-MM-DD — <short phrase, 10–20 words>. See [[<task-name>]] journal.
```

**Draft → show → write on approval:**

1. Load `notes/workstreams/<workstream>.md`.
2. Compose the line (one bullet, one date, links back to the task folder
   name if helpful).
3. Show the draft line to the user and ask for explicit approval:
   > "I'll append this to `notes/workstreams/<workstream>.md` under `## Notes`:
   > `<line>`. OK?"
4. Only on approval, append the line to the `## Notes` section of the
   workstream file. Do not touch any other section.
5. If the user rejects, skip the workstream write. Still do steps 2–3
   (state + log) — `--promote` is additive.

This follows eddy's "never auto-modify work stream files without explicit
user confirmation" rule (see `vault-conventions.md`).

### 5. Init path (no `JOURNAL.md` present)

If the current folder has no `JOURNAL.md`, offer to initialize one:

> "No `JOURNAL.md` found in this folder. Initialize one from
> `<workflow-repo>/notes/templates/journal.md` so future `/checkpoint`
> and hook runs have something to write to? (y/N)"

On yes:

1. Read the workstream/task from the folder's `CLAUDE.md` if present (the
   `## Work Stream` line and the folder name), otherwise ask the user.
2. Copy the template to `./JOURNAL.md`, substituting `{{task}}`,
   `{{workstream}}`, and `{{created}}` (today's date).
3. Install the `SessionStart` and `SessionEnd` hooks into
   `./.claude/settings.json` so auto-resume and auto-capture work
   going forward. Write (merging with any existing file):

   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-workflow-repo>/.claude/hooks/session-start.sh"
             }
           ]
         }
       ],
       "SessionEnd": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-workflow-repo>/.claude/hooks/session-end.sh"
             }
           ]
         }
       ]
     }
   }
   ```

   `<absolute-workflow-repo>` is the absolute path to the workflow repo
   (parse it from the task folder's `CLAUDE.md` Workflow Repo line if
   present, else ask the user). If a hook entry already points
   elsewhere, ask before replacing.
4. Proceed with steps 2–3 as normal.

On no: stop silently.

### 6. Append a daily log entry

Append to `notes/daily/YYYY-MM-DD.md` Activity Log:

```markdown
- **HH:MM** — [checkpoint] Checkpointed "<task-name>" → [[<workstream>]]
```

If `--promote` was accepted:

```markdown
- **HH:MM** — [checkpoint] Checkpointed "<task-name>" and promoted note to [[<workstream>]]
```

Fetch `date +%H:%M` fresh per the daily-log rule.

### 7. Summarize

Tell the user:
- The new state header (quote its `## Current State` and `## Next Steps` lines).
- The one-line reason of the appended log entry.
- Whether `--promote` landed anything in the work stream.

## Important rules

- **NEVER write to `notes/todos/running.md`.** The journal is private to
  the task; the running list stays under manual curation.
- **Last-write-wins on the state header** is acceptable. The `## Log`
  section is append-only; multiple sessions writing simultaneously will
  not collide on entries (they stack) but may race on the state header.
  That's OK for solo use per PRD #28.
- **Workstream writes require user approval**, always (even for a
  one-line append).
- **Timestamps must be fetched fresh**: ISO datetime for log entries via
  `date -u +%Y-%m-%dT%H:%M:%SZ`, wall-clock for daily log via
  `date +%H:%M`. Do not reuse cached timestamps.
- **Module A is the contract.** Do not edit `JOURNAL.md` with sed/awk
  from the skill body; always go through `journal-ops.py` so the state
  region / log section invariants hold.
