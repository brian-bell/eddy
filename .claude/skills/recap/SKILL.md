---
name: recap
description: Daily or weekly summary of all activity - completed todos, PRs, ingests, work stream progress
---

# Recap

Generate a summary of activity over a day or week.

## Process

### 1. Determine Scope

Check if the user specified "daily" or "weekly" in their message. Default to "daily".

- **Daily**: Scan today's date (or a specific date if provided)
- **Weekly**: Scan the current week (Monday through today, or a specific week)

### 2. Scan Vault Changes

#### For Daily Recap (scan one day):

**Daily Log:**
- Read `notes/daily/YYYY-MM-DD.md` — all activity log entries

**Completed Todos:**
- Read `notes/todos/completed.md` — find the `## YYYY-MM-DD` heading for today and collect every `- [x]` line under it (until the next `## ` heading). Each line carries inline fields (`workstream`, `added`, `completed`, …); use `workstream` for grouping in the recap.
- If `notes/todos/running.md` contains stray `- [x]` lines (manual checkbox flips not yet migrated), include those whose `completed:` field matches today and migrate them into `completed.md` as part of this pass per `vault-conventions.md`.

**PR Activity:**
- Read files in `notes/prs/` modified today (check file modification time or git diff)
- Note: merged, updated, new review feedback

**Squawk Items:**
- Read files in `notes/squawk/` created today (match `date:` frontmatter)

**Ideas Captured:**
- Read files in `notes/ideas/` created today (match `date:` frontmatter)
- Note: title and related streams for each

**Ticket Changes:**
- Read files in `notes/tickets/` modified today — status changes (system-agnostic)

**Work Stream Updates:**
- Read files in `notes/workstreams/` modified today

#### For Weekly Recap:

Same sources, scanned across the week:

- **Completed Todos:** read every `## YYYY-MM-DD` heading in `notes/todos/completed.md` from this week's Monday through today (inclusive). Aggregate the `- [x]` lines under each heading.
- For other sources (daily logs, PRs, squawk, ideas, tickets, work streams), use `git log --since` to find modified files within the week.

### 3. Generate Recap

Create the recap with these sections:

```markdown
---
date: YYYY-MM-DD
type: daily/weekly
---

# Daily/Weekly Recap — YYYY-MM-DD

## Completed
- [x] Task A in [[Work Stream X]] 
- [x] Addressed review feedback on [[backflow-142]]
- [x] Merged PR backflow#142

## In Progress
- [ ] BACK-1235: Timeout handling — 60% complete
- [ ] PR graphql-edge#42 — awaiting review

## New Items
- Created task "Fix auth timeout" in [[Error Handling Overhaul]]
- Ingested 3 items: 2 Slack, 1 email
- Opened PR backflow#155
- Captured 2 ideas: [[2026-04-06-cli-dashboard]], [[2026-04-06-api-caching]]

## Blockers
- PR backflow#150 has merge conflicts
- BACK-1240 blocked by missing API spec

## Upcoming
- Design review tomorrow
- Error handling epic target: end of week
```

### 4. Save to Vault

- **Daily**: Write to `notes/recaps/YYYY-MM-DD.md`
- **Weekly**: Write to `notes/recaps/week-YYYY-WW.md` (ISO week number)

### 5. Print Terminal Summary

Print a concise highlight reel:

```
## Daily Recap — April 4, 2026
- Completed 4/7 todos
- Merged 1 PR, updated 2 PRs
- Ingested 3 items (2 Slack, 1 email)
- New: WTUI redesign kickoff
- Blockers: 1 merge conflict, 1 blocked ticket
- Open items: 3 review comments pending
```

### 6. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
```
- **HH:MM** — [recap] Generated daily/weekly recap → [[YYYY-MM-DD]] in recaps
```

## Important Rules

- Use `[[wikilinks]]` throughout the recap to link to source notes
- For weekly recaps, aggregate across days — don't list every individual entry
- Include work stream-level progress, not just task-level
- The terminal summary should be scannable in under 10 seconds
- If there's no activity for a section, omit it rather than showing empty sections
