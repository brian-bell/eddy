---
name: linear
description: Query, create, track, comment on, and update Linear tickets via linearis or MCP
---

# Linear

Manage Linear tickets via linearis CLI or the official Linear MCP server. Find tickets, create new ones, check status, add comments, and update fields.

## Process

### 1. Check Prerequisites

Read `config.md` (per `config-format.md`) for the **Backend** setting under `### Linear`.

**If backend is `linearis` (default):**

Run `which linearis` to verify linearis is installed. If not found, tell the user:
> The `/linear` skill requires `linearis` CLI. This is an optional integration — Eddy works fine without it.
>
> To set it up: `npm install -g linearis`, then `linearis auth login`. See https://github.com/linearis-oss/linearis

Then stop.

**If backend is `mcp`:**

The skill assumes the Linear MCP server is configured. If MCP tool calls fail with connection errors, surface:
> Linear MCP server is not configured. Run `claude mcp add --transport http linear-server https://mcp.linear.app/mcp` and authenticate.

### 2. Read Config

Read `config.md` (per `config-format.md`) for:
- **Default Team** — default Linear team for scoping queries
- **Backend** — `linearis` (default) or `mcp`

If Default Team is unconfigured and the mode needs it, ask the user.

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

1. Read `notes/workstreams/` for context — work stream descriptions, project names
2. Check `notes/tickets/` for existing cached Linear tickets (files matching `linear-*.md`). To extract the Linear key from a vault filename, strip the `linear-` prefix (e.g., `linear-BACK-123.md` → `BACK-123`).
3. Build query from user context
4. Execute search (see Backend Commands)
   - **linearis:** Run `linearis issues list --query "<text>" --limit 25`. Parse the JSON response. If results need filtering by team/status/assignee, filter client-side since `--team`/`--status`/`--assignee` flags are not yet available (linearis-oss/linearis#124).
   - **MCP:** Call `list_issues` with `query` param. If search fails (linear/linear#1028), fall back to `list_my_issues` and filter client-side. **Note:** `list_my_issues` only returns the current user's issues. If using this fallback, tell the user: "Search fell back to your issues only — results may be incomplete. Use `linearis` backend for full team search."
5. Display formatted results:
   ```
   ## Linear Tickets: <search context>
   
   | Key | Title | Status | Priority | Assignee |
   |-----|-------|--------|----------|----------|
   | BACK-123 | Fix error types | In Progress | High | brian |
   | BACK-124 | Add timeout handling | Todo | Medium | unassigned |
   ```
6. Cache referenced tickets as vault notes (see step 5 — Cache as Vault Notes)

### 4b. Create Mode

1. Read `notes/workstreams/` to infer team and project context
2. Ask the user for details if not provided:
   - Title
   - Description
   - Priority (default: Medium)
3. Read default team from `config.md`, confirm or allow override
4. Execute create (see Backend Commands)
   - **linearis:** Run `linearis issues create "<title>" --team <team> --description "<desc>" --priority <n>` (add `--project "<project>"` and `--status "<status>"` if applicable). Priority uses Linear's numeric scale: 1=Urgent, 2=High, 3=Medium, 4=Low.
   - **MCP:** Call `save_issue` with `title`, `team`, `description`, `priority`, `project`. Omit the issue identifier to create (not update). For status, call `list_issue_statuses` first to resolve the name to a UUID.
5. Display the created ticket key
6. Cache as vault note (see step 5 — Cache as Vault Notes)
7. Offer to add to the relevant work stream's todo list
8. Append `[linear]` entry to daily log

### 4c. Status Mode

1. Determine which tickets to check:
   - From user's context, match to work streams and their associated projects
   - Check existing cached notes in `notes/tickets/` where `system: linear`
   - Build query for relevant tickets
2. Execute search (see Backend Commands — same as Find)
3. Display status summary:
   ```
   ## Linear Status: <context>
   
   | Key | Title | Status | Priority | Assignee |
   |-----|-------|--------|----------|----------|
   | BACK-123 | Fix error types | Done | High | brian |
   | BACK-124 | Add timeout handling | In Progress | Medium | alice |
   | BACK-125 | Update error docs | Todo | Low | unassigned |
   
   Progress: 1/3 done
   ```
4. Update cached vault notes with latest status

### 4d. Comment Mode

1. Parse the ticket key and comment text from the user's message
2. If the ticket key is ambiguous, check `notes/tickets/` for recent Linear tickets and ask the user to confirm
3. Show the user the comment text and ticket key, and ask them to confirm before posting
4. Execute comment (see Backend Commands)
   - **linearis:** Run `linearis comments create <KEY> --body "<text>"`
   - **MCP:** Call `create_comment` with the issue identifier and comment body
5. Update the cached vault note at `notes/tickets/linear-<KEY>.md`:
   - If the vault note doesn't exist, create it using the unified schema (see step 5 — Cache as Vault Notes) first
   - Append the comment to the **Comments** section:
     ```
     - **YYYY-MM-DD HH:MM** — <comment text>
     ```
6. Append to daily log:
   ```
   - **HH:MM** — [linear] Commented on [[linear-<KEY>]]: <short summary of comment>
   ```

### 4e. Update Mode

1. Parse the ticket key, field to update, and new value from the user's message
2. Supported fields (only these three):

   **Status:**
   - **linearis:** Run `linearis issues update <KEY> --status "<status>"`
   - **MCP:** Call `list_issue_statuses` to resolve the status name to a UUID, then call `save_issue` with the issue identifier and the status UUID.

   **Assignee:**
   - **linearis:** Run `linearis issues update <KEY> --assignee "<name>"`
   - **MCP:** Call `save_issue` with the issue identifier and assignee field.

   **Priority:**
   - **linearis:** Run `linearis issues update <KEY> --priority <n>` (1=Urgent, 2=High, 3=Medium, 4=Low)
   - **MCP:** Call `save_issue` with the issue identifier and priority value.

3. If the field to update is ambiguous, ask the user which field and new value
4. Update the cached vault note at `notes/tickets/linear-<KEY>.md` to reflect the change:
   - If the vault note doesn't exist, create it using the unified schema first
   - Update the relevant frontmatter field and the Details section
5. Append to daily log:
   ```
   - **HH:MM** — [linear] Updated [[linear-<KEY>]]: <field> → <new value>
   ```

### 5. Cache as Vault Notes

For each ticket referenced, create or update `notes/tickets/linear-<KEY>.md` using the unified ticket schema (see `ticket-format.md`):

```markdown
---
system: linear
ticket_key: <KEY>
title: "<title>"
status: <status>
project: <Linear project name>
team: <Linear team name>
assignee: <assignee>
priority: <priority name>
url: <url from API/CLI response>
date: <today>
work_stream: <matched work stream or empty>
---

# <KEY>: <title>

## Details
- **Status:** <status>
- **Project:** [[<project>]]
- **Team:** <team>
- **Assignee:** <assignee>
- **Priority:** <priority name>
- **URL:** <url>

## Comments
<!-- Appended by comment mode -->

## Related
<!-- Add wikilinks to work streams, PRs, notes -->
```

**Priority mapping:** Convert Linear's numeric values to human-readable names: 1=Urgent, 2=High, 3=Medium, 4=Low.

**Work stream matching:** Compare ticket `project`, `title`, and `description` against work stream descriptions and repos. If a match is found, set `work_stream` in frontmatter and add a `[[Work Stream Name]]` wikilink in the Related section.

### 6. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md` (create from template if it doesn't exist):
- Find: `- **HH:MM** — [linear] Searched Linear: <context> — found N tickets`
- Create: `- **HH:MM** — [linear] Created ticket [[linear-<KEY>]]: <title>`
- Status: `- **HH:MM** — [linear] Checked Linear status: <context> — N tickets, X done`
- Comment: `- **HH:MM** — [linear] Commented on [[linear-<KEY>]]: <summary>`
- Update: `- **HH:MM** — [linear] Updated [[linear-<KEY>]]: <field> → <new value>`

## Backend Commands Reference

### linearis CLI

| Operation | Command |
|-----------|---------|
| Search | `linearis issues list --query "<text>" --limit 25` then filter JSON by team/status/assignee client-side |
| Get issue | `linearis issues read <KEY>` |
| Create | `linearis issues create "<title>" --team <team> --description "<desc>" --priority <n> [--project "<project>"] [--status "<status>"]` |
| Comment | `linearis comments create <KEY> --body "<text>"` |
| Update status | `linearis issues update <KEY> --status "<status>"` |
| Update assignee | `linearis issues update <KEY> --assignee "<name>"` |
| Update priority | `linearis issues update <KEY> --priority <n>` |
| List teams | `linearis teams list` |
| List projects | `linearis projects list` |

Priority values: 1=Urgent, 2=High, 3=Medium, 4=Low.

All linearis commands output JSON to stdout. Parse with standard JSON handling.

**Known limitation:** `issues list` does not yet support `--team`/`--status`/`--assignee` filter flags (linearis-oss/linearis#124). Workaround: use `--query` for text search, then filter JSON results client-side.

### Linear MCP

| Operation | MCP Tool | Key Params |
|-----------|----------|------------|
| Search | `list_issues` | `query`, `label`, `limit` |
| My issues | `list_my_issues` | — |
| Get issue | `get_issue` | issue identifier, `includeRelations: true` |
| Create | `save_issue` | `title`, `team`, `description`, `priority`, `project` |
| Update | `save_issue` | issue identifier + fields to change |
| Comment | `create_comment` | issue identifier, comment body |
| List statuses | `list_issue_statuses` | — |
| List labels | `list_issue_labels` | — |

**Important MCP notes:**
- `save_issue` is a unified create/update tool — include the issue identifier to update, omit to create
- Status field requires UUID, not name — always call `list_issue_statuses` first and resolve the name to UUID
- `list_issues` `query` param has a known bug (linear/linear#1028) — if search fails, fall back to `list_my_issues` and filter client-side. Always inform the user when this fallback is used, since `list_my_issues` only returns the current user's issues

## Important Rules

- Always check for the configured backend's availability first
- Cache tickets as vault notes for knowledge graph integration
- Link vault notes to work streams via `[[wikilinks]]`
- For create mode, always confirm the ticket details with the user before creating
- For comment mode, always show the comment text and confirm before posting
- Map Linear's numeric priority (1-4) to human-readable names in all vault output
