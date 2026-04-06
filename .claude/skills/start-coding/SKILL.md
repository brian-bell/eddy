---
name: start-coding
description: Clone repos into a task folder with full scaffolding - CLAUDE.md, AGENTS.md symlink, todos, daily log, work stream links
---

# Start Coding

Set up a new coding task folder with fresh repo clones and full context.

## Process

### 1. Gather Context

Read:
- `repos.md` — all available repositories with descriptions and tags
- `ARCHITECTURE.md` — system architecture for understanding repo relationships
- `config.md` — dev directory preference (parse per `config-format.md`)
- `notes/workstreams/` — active work streams

### 2. Understand the Task

The user should provide a task description in their message. If not, ask:
- "What coding task are you starting?"

Also determine:
- **Task name**: Infer a short, kebab-case folder name from the description (e.g., "fix-auth-timeout"). Confirm with the user.
- **Work stream**: Match to an existing work stream. If unclear, ask. If none fits, offer to create one (following work stream sovereignty rules).

### 3. Infer Repos

Based on the task description, repos.md, and ARCHITECTURE.md:
1. Identify which repos are needed for this task
2. Consider repo tags, descriptions, and architecture relationships
3. Present the list to the user:
   - "Based on your task, I'd clone these repos: **repo-a**, **repo-b**. Want to add or remove any?"
4. Let the user adjust before proceeding

### 4. Create Task Folder

Read the dev directory from `config.md` (default: `~/dev`).

1. Create the task folder: `<dev-dir>/<task-name>/`
2. For each selected repo, clone it:
   ```
   git clone <repo-url> <dev-dir>/<task-name>/<repo-name>
   ```

### 5. Create Task Context Files

Create `<dev-dir>/<task-name>/CLAUDE.md` with content that gives Claude full context when working in this folder:

```markdown
# Task: <task name>

## Workflow Repo
This task is tracked in the productivity workflow repo at:
`<absolute path to workflow repo>`

## Work Stream
Part of: <work stream name>

## Architecture Context
<Relevant excerpt from ARCHITECTURE.md — the repos involved and their relationships>

## Repos in this task
<List of cloned repos with their roles>

## References
- Work stream: `<workflow-repo>/notes/workstreams/<stream>.md`
- Todos: `<workflow-repo>/notes/todos/<stream>.md`
- Daily log: `<workflow-repo>/notes/daily/`
```

Then create a symlink so Codex sees the same task context:

```sh
ln -s CLAUDE.md <dev-dir>/<task-name>/AGENTS.md
```

If `AGENTS.md` already exists and is not a symlink to `CLAUDE.md`, ask the user before replacing it.

### 6. Update Vault

Follow `vault-conventions.md`, `workstream-format.md`, and `daily-log-format.md`.

#### Update work stream todo:
Add to `notes/todos/<work-stream>.md`:
```
- [ ] <task description> (task folder: <task-name>) — added YYYY-MM-DD
```

#### Update work stream note:
Add to the Tasks section of `notes/workstreams/<stream>.md`:
```
- <task-name>: <brief description> — started YYYY-MM-DD
```

#### Update daily log:
Append to `notes/daily/YYYY-MM-DD.md`:
```
- **HH:MM** — [start-coding] Started task "<task-name>" with repos: <repo1>, <repo2> → [[<work-stream>]]
```

### 7. Summarize

Tell the user:
- Task folder location and what was cloned
- The `CLAUDE.md` created with context and the `AGENTS.md` symlink pointing to it
- Vault updates (todo, work stream, daily log)
- How to start working: `cd <task-folder>` and launch Claude Code or Codex

## Important Rules

- **Always confirm repo selection with the user before cloning**
- **Always confirm the task folder name before creating it**
- Follow work stream sovereignty — never create work streams without confirmation
- Use absolute paths in the task CLAUDE.md so it works regardless of where Claude Code is launched
- Create `AGENTS.md` as a symlink to `CLAUDE.md` so Claude Code and Codex share one source of truth
- If a repo URL is missing from repos.md, ask the user for it
