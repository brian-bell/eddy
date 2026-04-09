---
name: new-task
description: Create and categorize a new task into work streams, add todos, update daily log
---

# New Task

Create a new task, categorize it into a work stream, and track it.

## Process

### 1. Gather Context

Read the following files to understand current state:
- All `.md` files in `notes/workstreams/` — load active work streams (parse frontmatter for `status`, `repos`, `jira_epic`, `description`)
- `repos.md` — available repositories
- `ARCHITECTURE.md` — system context

### 2. Check for Ticket Reference

If the user's message contains what looks like a ticket number (e.g., "BACK-123", "ENG-456"), check `notes/tickets/` for a cached note matching that key. Look for any file matching `*-<KEY>.md` (e.g., `linear-BACK-123.md`, `jira-BACK-123.md`).

**If a cached ticket is found:** read its frontmatter and use the ticket's `title`, `project`, and `work_stream` to pre-populate the task context. The user can still override any pre-populated values.

**If no cached ticket is found:** tell the user:
> No cached ticket found for `<KEY>`. Run `/linear` or `/jira` to look it up first, then try again.

Then stop.

### 3. Interview the User

If the user provided a task description in their message, use it. Otherwise, ask:
- "What's the task?"

Then, present the active work streams and ask:
- Does this task fit into an existing work stream? Present the best match(es) based on the task description.
- If no good match: "This doesn't seem to fit an existing work stream. Should I create a new one?" Ask for the work stream name and description. **Do not create the work stream without explicit confirmation.**
- What's the priority? (infer from context if possible, confirm with user)
- Are there any immediate action items beyond the task itself?

Use structured questions where appropriate.

### 4. Create/Update Files

Follow the conventions in `vault-conventions.md`, `workstream-format.md`, and `daily-log-format.md`.

#### If a new work stream is needed (and user confirmed):
1. Create `notes/workstreams/<work-stream-name>.md` using the template from `notes/templates/workstream.md`
2. Create `notes/todos/<work-stream-name>.md` using the template from `notes/templates/todo.md`

#### Add the todo entry:
1. Open or create `notes/todos/<work-stream-name>.md`
2. Add a checkbox item with the task description, wikilinks to related notes, and today's date:
   ```
   - [ ] Task description [[related-note]] — added YYYY-MM-DD
   ```

#### Update the daily log:
1. Open or create `notes/daily/YYYY-MM-DD.md` (use today's date, create from template if needed)
2. Append to the Activity Log section:
   ```
   - **HH:MM** — [new-task] Created task "Task Name" in [[Work Stream Name]]
   ```

### 5. Summarize

Tell the user what was created:
- The todo entry and which work stream it's in
- Any new files created (work stream, todo file)
- The daily log entry

## Important Rules

- **NEVER create or modify work stream files without explicit user confirmation**
- Always use `[[wikilinks]]` when referencing other notes
- Always follow `vault-conventions.md` for frontmatter and formatting
- If the user mentions repos, Jira tickets, or PRs, add wikilinks to those too
