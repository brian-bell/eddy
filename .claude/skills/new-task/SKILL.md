---
name: new-task
description: Create a new task against a work stream. By default, scaffolds a coding task folder with cloned repos; non-coding tasks capture the expected output type. Appends a bullet to the work stream's ## Tasks section.
---

# New Task

Create a new task, categorize it into a work stream, and (by default) scaffold a coding task folder with fresh repo clones.

## Process

### 1. Gather Context

Read:
- All `.md` files in `notes/workstreams/` — parse frontmatter for `status`, `repos`, `jira_epic`, `description`
- `repos.md` — available repositories
- `ARCHITECTURE.md` — system context and repo relationships
- `config.md` — dev directory preference (parse per `config-format.md`); only needed for the coding path but load it up front

### 2. Check for Ticket Reference

If the user's message contains what looks like a ticket number (e.g., "BACK-123", "ENG-456"), check `notes/tickets/` for a cached note matching that key (any file matching `*-<KEY>.md`, e.g., `linear-BACK-123.md`, `jira-BACK-123.md`).

**If a cached ticket is found:** read its frontmatter and use the ticket's `title`, `project`, and `work_stream` to pre-populate the task context. The user can still override any pre-populated values.

**If no cached ticket is found:** warn and offer to continue:
> No cached ticket found for `<KEY>`. You can run `/linear` or `/jira` to look it up and pre-populate context, or I can continue without it.

If the user chooses to continue, proceed to the interview with no pre-populated values. If they want to look it up first, stop and let them run the lookup skill.

### 3. Interview — Shared Questions

If the user provided a task description in their message, use it. Otherwise, ask:
- "What's the task?"

Then match the task to a work stream:
- Does this task fit an existing active work stream? Present the best match(es) based on the description.
- If no good match: "This doesn't seem to fit an existing work stream. Should I create a new one?" Ask for a name and description. **Do not create the work stream without explicit confirmation.**

### 4. Branch — Coding Mode (default) or Non-Coding Mode

**Coding mode is the default.** Proceed to 4a unless the user has already indicated (in their initial message or during the interview) that this isn't a coding task — in which case go to 4b. The user can also opt out during 4a by saying "this isn't coding" when asked to confirm the folder name and repos.

#### 4a. Coding Mode

1. Infer a kebab-case task name from the description (e.g., `fix-auth-timeout`). This is both the folder name and the identifier used in the work stream's `## Tasks` bullet.
2. Infer which repos are needed based on the description, `repos.md`, and `ARCHITECTURE.md`. Consider repo tags, descriptions, and architecture relationships.
3. Present both in one message so the user can confirm, adjust, or opt out:
   > "I'll set up a coding task folder `<dev-dir>/<task-name>/` with repos: **repo-a**, **repo-b**. Want to change the folder name or repo list — or is this not a coding task?"
4. Once confirmed:
   - If `<dev-dir>/<task-name>/` already exists, ask before proceeding rather than re-cloning silently.
   - Create the folder: `<dev-dir>/<task-name>/`.
   - Clone each selected repo:
     ```
     git clone <repo-url> <dev-dir>/<task-name>/<repo-name>
     ```
   - If a repo URL is missing from `repos.md`, ask the user for it.
5. Create `<dev-dir>/<task-name>/CLAUDE.md` with the context Claude needs when working in the folder:

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
   - Task journal: `./JOURNAL.md` (per-task log; `/checkpoint` rewrites the state header and appends log entries)
   - Work stream: `<workflow-repo>/notes/workstreams/<stream>.md`
   - Running todos: `<workflow-repo>/notes/todos/running.md` (filter by `workstream: <stream>`)
   - Daily log: `<workflow-repo>/notes/daily/`
   ```

6. Create a symlink so Codex sees the same task context:

   ```sh
   ln -s CLAUDE.md <dev-dir>/<task-name>/AGENTS.md
   ```

   If `AGENTS.md` already exists and is not already that symlink, ask the user before replacing it.

7. Create `<dev-dir>/<task-name>/JOURNAL.md` from `notes/templates/journal.md`, substituting `{{task}}` with the kebab-case task name, `{{workstream}}` with the matched work stream name, and `{{created}}` with today's date (`YYYY-MM-DD`). The rest of the template (state header, empty `## Log`) is written through unchanged. The journal stays local to the task folder — it is not copied into the vault. If `JOURNAL.md` already exists in the folder, leave it alone rather than overwriting.

8. Install the `SessionStart` and `SessionEnd` hooks into the task folder's `.claude/settings.json` so each Claude Code session auto-resumes from the journal on entry and auto-captures a `[session]` log entry on exit. Write (merging with any existing file):

   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-workflow-repo>/.claude/hooks/session-start.sh"
             }
           ]
         }
       ],
       "SessionEnd": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-workflow-repo>/.claude/hooks/session-end.sh"
             }
           ]
         }
       ]
     }
   }
   ```

   Substitute `<absolute-workflow-repo>` with the same absolute path used in the task `CLAUDE.md`'s Workflow Repo section. If `.claude/settings.json` already exists in the folder, merge the `hooks.SessionStart` / `hooks.SessionEnd` entries in rather than overwriting the file. If a hook entry already points elsewhere, ask the user before replacing.

#### 4b. Non-Coding Mode

The user has indicated this isn't a coding task. No filesystem scaffolding — just capture what kind of output is expected and an identifier for the task.

1. Ask (as a structured question) what kind of output they need. Offer: *Doc, Slides, Draft message, Email, Spec, Meeting notes, Review, Research summary, Other (free text)*. Capture the choice as the `output` type.
2. Infer a kebab-case task name (e.g., `draft-rollout-message`) and confirm it with the user. This is the identifier used in the work stream's `## Tasks` bullet.
3. The output file itself is **not** pre-created — `/new-task` just logs the intent. The user produces the deliverable separately.

### 5. Vault Updates

Follow `vault-conventions.md`, `workstream-format.md`, and `daily-log-format.md`.

**Append a bullet to the `## Tasks` section of `notes/workstreams/<stream>.md`** — in the open form from `notes/templates/task.md`:

- Coding mode:
  ```
  - <task-name>: <brief description> — started: YYYY-MM-DD
  ```
- Non-coding mode:
  ```
  - <task-name>: <brief description> (output: <artifact-type>) — started: YYYY-MM-DD
  ```

Create the `## Tasks` section just above `## Notes` if it's missing. No `ended:` field yet — completion appends `| ended: YYYY-MM-DD` later per the completion workflow in `notes/templates/task.md`. Do not touch any other section of the work stream file.

**Append a daily log entry** to `notes/daily/YYYY-MM-DD.md` under the Activity Log section (create the file from template if it doesn't exist):

- Coding mode:
  ```
  - **HH:MM** — [new-task] Started "<task-name>" with repos: <repo1>, <repo2> → [[<work-stream>]]
  ```
- Non-coding mode:
  ```
  - **HH:MM** — [new-task] Created "<task-name>" (output: <artifact-type>) → [[<work-stream>]]
  ```

**Do NOT write to `notes/todos/running.md`.** That file is for action-level todos added by `/ingest` or manually as work progresses. `/new-task` records a task kickoff; running-list items accumulate separately.

### 6. Summarize

Tell the user:

- **Coding mode:** task folder location, what was cloned, the `CLAUDE.md` + `AGENTS.md` symlink, the scaffolded `JOURNAL.md`, the `.claude/settings.json` with the `SessionStart` and `SessionEnd` hooks wired up, the work stream `## Tasks` bullet appended (quote the line), the daily log entry, and how to resume (`cd <folder>` and launch Claude Code or Codex).
- **Non-coding mode:** the captured task name, work stream, and output type; the work stream `## Tasks` bullet (quote the line); the daily log entry; and a reminder that the output file wasn't pre-created — the user is expected to produce it themselves.

## Important Rules

- **NEVER create or modify work stream files without explicit user confirmation** (except appending to the `## Tasks` section as described above, which is the defined contract).
- **Always confirm repo selection and task folder name with the user before cloning.**
- Use `[[wikilinks]]` when referencing other notes.
- Use absolute paths in the task `CLAUDE.md` so it works regardless of where Claude Code is launched.
- Create `AGENTS.md` as a symlink to `CLAUDE.md` so Claude Code and Codex share one source of truth.
- If the user mentions repos, Jira/Linear tickets, or PRs, add wikilinks to those too.
- If a repo URL is missing from `repos.md`, ask the user for it.
- Tasks land in the work stream's `## Tasks` section. `/new-task` does NOT write to `notes/todos/running.md` — that's for action-level todos added during execution (by `/ingest` or manually).
