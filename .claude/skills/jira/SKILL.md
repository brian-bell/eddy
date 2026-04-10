---
name: jira
description: Query, create, track, comment on, and update Jira tickets via acli
---

# Jira

Manage Jira tickets via the Atlassian CLI (`acli`). Find tickets, create new ones, check status, add comments, and update fields.

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

| Mode | Triggers |
|------|----------|
| **Find** | find, search, look for, what tickets, related to |
| **Create** | create, new, make, write |
| **Status** | status, what's happening, update on, how's, progress |
| **Comment** | comment, reply, note on, add note |
| **Update** | update, change, set, move, assign, close |

If ambiguous, ask the user.

### 4a. Find Mode

1. Read `notes/workstreams/` for context — work stream descriptions, Jira epics
2. Check `notes/tickets/` for existing cached Jira tickets (files matching `jira-*.md`). To extract the Jira key from a vault filename, strip the `jira-` prefix (e.g., `jira-BACK-1234.md` → `BACK-1234`).
3. Build a JQL query from the user's context. Examples:
   - "find tickets for error handling" → `project = <default> AND text ~ "error handling"`
   - "what's the Jira status for the auth epic" → `project = <default> AND "Epic Link" = <epic-key>`
4. Run: `acli jira --action getIssueList --jql "<query>" --outputFormat 2`
5. Parse results and display:
   ```
   ## Jira Tickets: <search context>
   
   | Key | Title | Status | Priority | Assignee |
   |-----|-------|--------|----------|----------|
   | BACK-1234 | Fix error types | In Progress | High | brian |
   | BACK-1235 | Add timeout handling | To Do | Medium | unassigned |
   ```
6. Cache referenced tickets as vault notes (see step 5)

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
   - Check existing `notes/tickets/` vault notes for cached Jira tickets (files matching `jira-*.md`)
   - Build JQL query for relevant tickets
2. Run: `acli jira --action getIssueList --jql "<query>" --outputFormat 2`
3. Display status summary:
   ```
   ## Jira Status: <context>
   
   **Epic:** BACK-1234 — Error Handling Overhaul
   
   | Key | Title | Status | Priority | Assignee |
   |-----|-------|--------|----------|----------|
   | BACK-1235 | Fix error types | Done | High | brian |
   | BACK-1236 | Add timeout handling | In Progress | Medium | alice |
   | BACK-1237 | Update error docs | To Do | Low | unassigned |
   
   Progress: 1/3 done
   ```
4. Update cached vault notes with latest status

### 4d. Comment Mode

1. Parse the ticket key and comment text from the user's message
2. If the ticket key is ambiguous, check `notes/tickets/` for recent Jira tickets and ask the user to confirm
3. Show the user the comment text and ticket key, and ask them to confirm before posting
4. Run: `acli jira --action addComment --issue "<KEY>" --comment "<text>"`
5. Update the cached vault note at `notes/tickets/jira-<KEY>.md`:
   - If the vault note doesn't exist, create it using the unified schema (see step 5) first
   - Append the comment to the **Comments** section:
     ```
     - **YYYY-MM-DD HH:MM** — <comment text>
     ```
6. Append to daily log:
   ```
   - **HH:MM** — [jira] Commented on [[jira-<KEY>]]: <short summary of comment>
   ```

### 4e. Update Mode

1. Parse the ticket key, field to update, and new value from the user's message
2. Supported fields (only these three):

   **Status:**
   - Run: `acli jira --action transitionIssue --issue "<KEY>" --transition "<status>"`
   - If the command fails (custom workflow state name mismatch), fall back:
     1. Run: `acli jira --action getTransitionList --issue "<KEY>"`
     2. Present available transitions to the user
     3. Ask the user to pick one, then retry with the selected transition name

   **Assignee:**
   - Run: `acli jira --action updateIssue --issue "<KEY>" --assignee "<username>"`

   **Priority:**
   - Run: `acli jira --action updateIssue --issue "<KEY>" --priority "<priority>"`

3. Update the cached vault note at `notes/tickets/jira-<KEY>.md` to reflect the change:
   - If the vault note doesn't exist, create it using the unified schema (see step 5) first
   - Update the relevant frontmatter field and the Details section
4. Append to daily log:
   ```
   - **HH:MM** — [jira] Updated [[jira-<KEY>]]: <field> → <new value>
   ```

### 5. Cache as Vault Notes

For each ticket referenced, create or update `notes/tickets/jira-<KEY>.md` using the unified ticket schema (see `ticket-format.md`):

```markdown
---
system: jira
ticket_key: <KEY>
title: "<title>"
status: <status>
project: <epic name>
team: <project key>
assignee: <assignee>
priority: <priority>
url: https://<instance>/browse/<KEY>
date: <today>
work_stream: <matched work stream or empty>
---

# <KEY>: <title>

## Details
- **Status:** <status>
- **Project:** [[<epic-name>]]
- **Assignee:** <assignee>
- **Priority:** <priority>
- **URL:** https://<instance>/browse/<KEY>

## Comments
<!-- Appended by comment mode -->

## Related
<!-- Add wikilinks to work streams, PRs, notes -->
```

Add `[[wikilinks]]` to related work streams (match via `jira_epic` in work stream frontmatter).

### 6. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
- Find: `- **HH:MM** — [jira] Searched Jira: <context> — found N tickets`
- Create: `- **HH:MM** — [jira] Created ticket [[jira-<KEY>]]: <title>`
- Status: `- **HH:MM** — [jira] Checked Jira status: <context> — N tickets, X done`
- Comment: `- **HH:MM** — [jira] Commented on [[jira-<KEY>]]: <summary>`
- Update: `- **HH:MM** — [jira] Updated [[jira-<KEY>]]: <field> → <new value>`

## Important Rules

- Always check for `acli` availability first
- The `acli` command syntax may vary by version — if a command fails, try alternative flags
- Cache tickets as vault notes for knowledge graph integration
- Link vault notes to work streams via `[[wikilinks]]`
- For create mode, always confirm the ticket details with the user before creating
