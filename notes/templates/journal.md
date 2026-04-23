---
type: task-journal
task: {{task}}
workstream: {{workstream}}
created: {{created}}
---

# Journal: {{task}}

A durable per-task log for work on this task. Co-located with the task folder
so it travels with the cloned repos and stays close to the work.

- The state header below is **rewritten in place** by `/checkpoint` and (later)
  by the `SessionStart`/`SessionEnd` hooks. Last-write-wins.
- The `## Log` section is **append-only** (newest at the bottom). Two entry
  types: `[session]` (written by hooks) and `[checkpoint]` (written by the
  `/checkpoint` skill). Each entry starts with an ISO datetime and a one-line
  reason or title.

## Current State
<!-- What's the latest understanding of where this task stands? -->

## Next Steps
<!-- What's the next thing to pick up? -->

## Open Questions
<!-- What's unresolved and needs a decision or lookup? -->

## Blockers
<!-- What's preventing forward progress right now? -->

## Log
<!-- Append-only. Newest entries at the bottom. -->
