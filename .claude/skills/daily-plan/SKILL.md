---
name: daily-plan
description: Create today's plan from calendar availability, open todos, PRs, and priorities
---

# Daily Plan

Create a structured plan for today based on calendar, priorities, and open work.

## Process

### 1. Get Today's Date

Use the system date to determine today's date in YYYY-MM-DD format.

### 2. Ask for Calendar

Ask the user to paste their calendar for the day:
> "Paste your calendar/meetings for today (times and titles)."

Parse the pasted calendar to identify:
- Meeting times and durations
- Available focus blocks (gaps between meetings)
- Total focus time available

### 3. Gather Open Work

Read across the vault to build a picture of what's pending:

**Todos:**
- Read `notes/todos/running.md` — collect unchecked (`- [ ]`) items.
- For each item, parse the pipe-separated inline fields after the em-dash (`workstream`, `source`, `added`, `due`, `stakeholder`) per `vault-conventions.md`.
- Filter by `due` relative to today:
  - **Include in today's plan:** items where `due` is today, items where `due` is before today (overdue), and items with no `due` field at all (undated items are always eligible).
  - **Include in a "Coming up" section (not today's plan):** items where `due` is within the next 2 days (today+1 or today+2).
  - **Exclude entirely:** items where `due` is more than 2 days out. These are effectively snoozed — surface them again when their window arrives.
- Group / sort the eligible items by `workstream` and use `source` and `stakeholder` to inform priority. Flag overdue items prominently.

**PR Actions:**
- Read all files in `notes/prs/` — collect PRs with unchecked review feedback items
- Note PR status (changes_requested = high urgency)

**Squawk Items:**
- Read recent files in `notes/squawk/` (last 3 days) where `actionable: true`
- Collect any unchecked action items

**Tickets (optional):**
- Read files in `notes/tickets/` — collect tickets assigned to the user that are in progress or todo (filter by `status` and `assignee`, system-agnostic)
- If the user wants, refresh via `/jira` first

**Work Streams:**
- Read `notes/workstreams/` — understand active stream priorities

**Yesterday's Daily Log:**
- Read `notes/daily/<yesterday>.md` if it exists — check for carryover items

### 4. Propose the Plan

Calculate available focus time from the calendar. Then propose a prioritized plan:

```
## Today's Plan — YYYY-MM-DD

### Calendar
- 09:00-09:30 — Standup
- 10:00-11:00 — Design review
- 14:00-15:00 — 1:1 with Alice

### Focus Time: ~4.5 hours

### Priorities
1. **[PR] Address review feedback on backflow#142** (30 min)
   Why: Changes requested 2 days ago, blocking merge

2. **[Todo] Ship retry policy doc** (1 hour) ⚠ OVERDUE
   Why: Due 2026-04-14, still open — 2 days past

3. **[Todo] Review Alice's auth RFC** (45 min) · due today
   Why: Decision needed by EOD

4. **[Todo] Update error documentation** (1 hour)
   Why: No due date — steady progress on Error Handling Overhaul

### If Time Permits
5. **[Todo] Explore WTUI color system** (1 hour)
   Why: Undated; design review prep

### Coming Up (next 2 days)
- **[Todo] Finalize Q2 roadmap** — due tomorrow (2026-04-17)
- **[Todo] Prep for BACK-1240 review** — due 2026-04-18
```

### 5. Interview to Adjust

Ask the user:
- "Does this plan look right? Want to reorder, defer, or add anything?"
- Use structured questions where appropriate
- Iterate until the user is satisfied

### 6. Write to Daily Log

Create or update `notes/daily/YYYY-MM-DD.md`:
- Fill in the **Plan** section with the finalized plan
- Add an Activity Log entry:
  ```
  - **HH:MM** — [daily-plan] Created today's plan — N priority items, ~X hours focus time
  ```

### 7. Summarize

Print the final plan to the terminal.

## Important Rules

- Estimate time for each item based on complexity
- Always explain WHY each item is prioritized (age, blocking, urgency, deadlines)
- Include an "If Time Permits" section for lower-priority items
- Include a **"Coming Up"** section listing items with `due` in the next 2 days (today+1, today+2) — these are not scheduled for today but the user should see them approaching. Omit the section if nothing qualifies.
- Items with `due` more than 2 days out are excluded entirely — they're effectively snoozed until their window arrives. Users can adjust by editing the item's `due` field (see `vault-conventions.md` "Snoozing").
- Undated items (no `due` field) are always eligible for today's plan; rank them by the usual signals.
- Flag overdue items (`due` before today, still unchecked) prominently — e.g., ⚠ OVERDUE — and rank them at the top of Priorities.
- Carry over unfinished items from yesterday's plan if applicable
- Don't overwhelm — prioritize ruthlessly based on available focus time
