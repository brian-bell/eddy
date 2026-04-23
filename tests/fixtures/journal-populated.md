---
type: task-journal
task: fix-auth-timeout
workstream: platform-auth
created: 2026-04-20
---

# Journal: fix-auth-timeout

Intro prose is preserved.

## Current State
Investigating the token-refresh race condition.

## Next Steps
- Reproduce with the repro script from the linked ticket.

## Open Questions
- Does the race exist on the staging cluster too?

## Blockers
None right now.

## Log
<!-- Append-only. Newest entries at the bottom. -->

### [session] 2026-04-20T09:15:00Z — initial exploration

Started poking at the auth handler.

### [checkpoint] 2026-04-20T14:00:00Z — narrowed to token-refresh

Confirmed the race is in refresh, not issuance.
