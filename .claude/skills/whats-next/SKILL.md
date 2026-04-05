---
name: whats-next
description: Signal-based prioritized list of next actions across all data sources
---

# What's Next

Synthesize all open work across the vault and present a prioritized action list.

## Process

### 1. Gather All Open Items

Read across the entire vault:

**Open Todos:**
- Read all files in `notes/todos/` — collect all unchecked (`- [ ]`) items
- For each, note: description, work stream, date added, any linked notes

**PR Actions:**
- Read all files in `notes/prs/` — collect:
  - PRs with unchecked review feedback (need to address comments)
  - PRs with failing checks (need to fix)
  - PRs with merge conflicts (need to resolve)
  - PRs that are approved and ready to merge

**Squawk Action Items:**
- Read files in `notes/squawk/` where `actionable: true`
- Collect unchecked items from Action Items sections

**Jira Tickets:**
- Read files in `notes/jira/` — collect tickets where:
  - Assigned to the user and status is In Progress or To Do
  - Status recently changed (might need follow-up)

**Work Stream Context:**
- Read `notes/workstreams/` — understand which streams are active and their relative importance

### 2. Score Each Item

Score items using these signals (no manual priority tags required):

| Signal | Weight | Description |
|--------|--------|-------------|
| **Age** | High | Older items score higher — things shouldn't languish |
| **Blocking** | Highest | Items that block others (PRs awaiting your changes, tickets blocking QA) |
| **Work stream importance** | Medium | Active, high-priority work streams boost their items |
| **Urgency markers** | High | Review feedback (changes_requested), failing checks, merge conflicts |
| **Staleness** | Medium | Items that haven't been touched recently |
| **Deadlines** | Highest | Items with approaching deadlines (inferred from context) |
| **Quick wins** | Bonus | Items that take <15 min get a small boost (momentum) |

### 3. Present Ranked List

Group by category and present the top items:

```
## What's Next

### Top Priority
1. **[PR] Address review feedback on backflow#142**
   Why: changes_requested 3 days ago, 2 unresolved comments
   Work stream: [[Error Handling Overhaul]]

2. **[Jira] BACK-1235 — Add timeout handling**  
   Why: In Progress, blocks QA testing, assigned to you
   Work stream: [[Error Handling Overhaul]]

### Should Do Soon
3. **[Squawk] Respond to Alice's auth question**
   Why: Decision needed, ingested yesterday, actionable
   Source: [[2026-04-03-auth-error-discussion]]

4. **[PR] Merge backflow#148** 
   Why: Approved, checks passing, no conflicts — ready to merge

5. **[Todo] Update error documentation**
   Why: Part of [[Error Handling Overhaul]], added 5 days ago

### On the Radar
6. **[Todo] Explore WTUI color system**
   Why: Design review coming up, added 2 days ago
   Work stream: [[WTUI v2 Redesign]]

7. **[Jira] BACK-1240 — API spec for new endpoints**
   Why: To Do, unassigned but in your epic
```

### 4. Offer Actions

After presenting the list, ask:
- "Want to start on any of these? I can help with PR feedback, task setup, or Jira updates."

### 5. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
```
- **HH:MM** — [whats-next] Reviewed priorities — top item: <description>
```

## Important Rules

- Read ALL data sources — don't skip any vault directory
- Always explain WHY each item is ranked where it is
- Group into: Top Priority, Should Do Soon, On the Radar
- Keep the list actionable — each item should be something the user can start right now
- If the vault is empty/sparse, say so and suggest using other skills to populate it
- Don't show completed items — only open/pending work
- Use `[[wikilinks]]` to let the user navigate to source notes
