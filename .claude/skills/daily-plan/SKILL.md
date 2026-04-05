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
- Read all files in `notes/todos/` — collect unchecked (`- [ ]`) items
- Note which work stream each belongs to

**PR Actions:**
- Read all files in `notes/prs/` — collect PRs with unchecked review feedback items
- Note PR status (changes_requested = high urgency)

**Squawk Items:**
- Read recent files in `notes/squawk/` (last 3 days) where `actionable: true`
- Collect any unchecked action items

**Jira (optional):**
- Read files in `notes/jira/` — collect tickets assigned to the user that are in progress or todo
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
   
2. **[Jira] BACK-1235 — Add timeout handling** (2 hours)
   Why: In progress, assigned to you, blocks QA
   
3. **[Todo] Update error documentation** (1 hour)
   Why: Part of Error Handling Overhaul, due this week

4. **[Squawk] Respond to Alice's auth question** (15 min)
   Why: Decision needed, ingested yesterday

### If Time Permits
5. **[Todo] Explore WTUI color system** (1 hour)
   Why: Design review tomorrow, helpful to have context
```

### 5. Interview to Adjust

Ask the user:
- "Does this plan look right? Want to reorder, defer, or add anything?"
- Use AskUserQuestion for structured input if helpful
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
- Carry over unfinished items from yesterday's plan if applicable
- Don't overwhelm — prioritize ruthlessly based on available focus time
