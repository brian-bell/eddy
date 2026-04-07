---
name: jira
description: Query, create, and track Jira tickets via acli - find, create, and status modes
---

# Jira

Manage Jira tickets via the Atlassian CLI (`acli`). Find tickets, create new ones, check status.

## Process

### 1. Check Prerequisites

Run `which acli` to verify acli is installed. If not found, tell the user:
> The `/jira` skill requires the Atlassian CLI (`acli`). This is an optional integration — Eddy works fine without it.
>
> To set it up: install [acli](https://bobswift.atlassian.net/wiki/spaces/ACLI/overview) and add your Jira credentials to the "Optional Integrations" section in `config.md`.

Then stop.

### 2. Read Config

Read `config.md` (per `config-format.md`) for:
- **Jira Instance** — the Atlassian instance URL
- **Jira Username** — the user's Jira identity
- **Default Project** — default project key for creating tickets

If any are unconfigured, ask the user to fill them in.

### 3. Determine Mode

From the user's message, determine which mode to use:

- **Find** — User wants to search for tickets. Trigger words: "find", "search", "look for", "what tickets", "related to"
- **Create** — User wants to create a ticket. Trigger words: "create", "write", "make", "new ticket"
- **Status** — User wants ticket status. Trigger words: "status", "what's happening", "update on", "how's"

If ambiguous, ask the user.

### 4a. Find Mode

1. Read `notes/workstreams/` for context — work stream descriptions, Jira epics
2. Build a JQL query from the user's context. Examples:
   - "find tickets for error handling" → `project = <default> AND text ~ "error handling"`
   - "what's the Jira status for the auth epic" → `project = <default> AND "Epic Link" = <epic-key>`
3. Run: `acli jira --action getIssueList --jql "<query>" --outputFormat 2`
4. Parse results and display:
   ```
   ## Jira Tickets: <search context>
   
   | Key | Title | Status | Assignee |
   |-----|-------|--------|----------|
   | BACK-1234 | Fix error types | In Progress | brian |
   | BACK-1235 | Add timeout handling | To Do | unassigned |
   ```
5. Cache referenced tickets as vault notes (see step 5)

### 4b. Create Mode

1. Read `notes/workstreams/` to infer project and epic from context
2. Ask the user for details if not provided:
   - Summary (title)
   - Description
   - Issue type (default: Task)
   - Priority (default: Medium)
   - Epic (infer from work stream's `jira_epic` field)
3. Run: `acli jira --action createIssue --project "<project>" --type "<type>" --summary "<summary>" --description "<description>" --priority "<priority>"`
4. If an epic is identified: `acli jira --action updateIssue --issue "<key>" --field "Epic Link" --values "<epic-key>"`
5. Display the created ticket key and link
6. Cache as vault note (see step 5)
7. Offer to add to the relevant work stream's todo list

### 4c. Status Mode

1. Determine which tickets to check:
   - From user's context, match to work streams and their `jira_epic` fields
   - Check existing `notes/jira/` vault notes for cached tickets
   - Build JQL query for relevant tickets
2. Run: `acli jira --action getIssueList --jql "<query>" --outputFormat 2`
3. Display status summary:
   ```
   ## Jira Status: <context>
   
   **Epic:** BACK-1234 — Error Handling Overhaul
   
   | Key | Title | Status | Assignee |
   |-----|-------|--------|----------|
   | BACK-1235 | Fix error types | Done | brian |
   | BACK-1236 | Add timeout handling | In Progress | alice |
   | BACK-1237 | Update error docs | To Do | unassigned |
   
   Progress: 1/3 done
   ```
4. Update cached vault notes with latest status

### 5. Cache as Vault Notes

For each ticket referenced, create or update `notes/jira/<TICKET-KEY>.md`:

```markdown
---
jira_key: <KEY>
title: "<title>"
status: <status>
epic: <epic name>
assignee: <assignee>
date: <today>
---

# <KEY>: <title>

## Details
- **Status:** <status>
- **Epic:** [[<epic-name>]]
- **Assignee:** <assignee>
- **Priority:** <priority>

## Related
<!-- Add wikilinks to work streams, PRs, notes -->
```

Add `[[wikilinks]]` to related work streams (match via `jira_epic` in work stream frontmatter).

### 6. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
- Find: `- **HH:MM** — [jira] Searched Jira: <context> — found N tickets`
- Create: `- **HH:MM** — [jira] Created ticket [[<KEY>]]: <title>`
- Status: `- **HH:MM** — [jira] Checked Jira status: <context> — N tickets, X done`

## Important Rules

- Always check for `acli` availability first
- The `acli` command syntax may vary by version — if a command fails, try alternative flags
- Cache tickets as vault notes for knowledge graph integration
- Link vault notes to work streams via `[[wikilinks]]`
- For create mode, always confirm the ticket details with the user before creating
