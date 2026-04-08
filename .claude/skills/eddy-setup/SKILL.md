---
name: eddy-setup
description: Interactive onboarding wizard — configure vault, scan repos, and set up work streams
---

# Eddy Setup Wizard

Walk the user through onboarding: configure `config.md`, scan for repositories, and optionally set up Jira and work streams.

## Process

### 1. Detect Existing State

Read these files to determine whether this is a first run or a re-run:

- `config.md` — check each value; if it's a `<!-- ... -->` placeholder, treat it as unconfigured
- `repos.md` — if it exists, parse the existing repo entries so the wizard can diff against them later

If all config values are already set and repos.md exists, this is a re-run. Adjust prompts accordingly (see Re-run Behavior below).

### 2. Resolve GitHub Username

Follow the fallback chain in `config-format.md`:

#### Step 1: Read config.md

If the GitHub Username value is already a real value (not a placeholder), show it to the user:
- "Your GitHub username is currently set to **{username}**. Keep it, or enter a new one?"
- If the user confirms, keep it and move on.

#### Step 2: Detect via `gh api user`

Run `gh api user` and extract the `.login` field.

If successful, show the detected username:
- "Detected your GitHub username as **{login}** from the `gh` CLI. Is that correct?"
- If the user confirms, use it. If not, let them type a different one.

If `gh` is not installed or the call fails for any reason, silently fall through to Step 3.

#### Step 3: Ask the user

Run `git config user.name` and use it as a hint:
- "I couldn't auto-detect your GitHub username. Your git display name is **{name}** — what's your GitHub login?"
- Mention: "Installing the [GitHub CLI](https://cli.github.com/) (`gh`) would enable auto-detection in the future."
- The user must type their actual GitHub login — never auto-accept the display name.

### 3. Collect Dev Directory

Prompt for the base directory where the user keeps their repositories:

- On first run: "Where do you keep your git repos? (default: `~/dev`)"
- On re-run (value already set): "Dev directory is currently **{path}**. Keep it, or enter a new one?"

If the user accepts the default or presses enter, use `~/dev`.

### 4. Set Default Branch

Silently set the default branch to `main`. Do not prompt for this.

### 5. Collect Jira Configuration (Optional)

Ask: "Do you use Jira for ticket tracking?"

- **If no** (or skip): Leave Jira values as placeholders (first run) or preserve existing values (re-run). Move on.
- **If yes**: Collect three values:
  - "What's your Jira username?"
  - "What's your default Jira project key? (e.g., BACK)"
  - "What's your Jira instance URL? (e.g., mycompany.atlassian.net)"

On re-run with existing Jira values, show each current value with the option to keep or change.

### 6. Scan Dev Directory for Repositories

List the immediate children of the dev directory that contain a `.git` directory:

```sh
ls -d {dev_directory}/*/.git 2>/dev/null
```

For each discovered repo:

1. **Detect remote URL**: Run `git remote get-url origin` inside the repo. If it has no remote, use the local path as the URL.
2. **Enrich with GitHub metadata** (when `gh` is available): Run `gh repo view --json description,repositoryTopics` using the remote URL. If this fails for any reason (not a GitHub repo, private without auth, `gh` not installed), skip enrichment gracefully — the repo still gets registered with just a name and URL.

Parse existing `repos.md` entries if the file exists. Only present **new** repos (those not already in `repos.md`) as candidates.

Present all new repos as **selected by default** (opt-out model):

```
Found 5 new repos in ~/dev:

  [x] backflow — REST API service (go, backend)
  [x] wtui — Terminal UI framework (rust, cli)
  [x] docs-site — Documentation site (typescript, docs)
  [x] experiments — (no description)
  [ ] dotfiles — (no description)    ← example of user deselecting

Deselect any you don't want to register, or confirm to proceed.
```

If no new repos are found, report that and move on.

### 7. Offer Work Stream Creation (Optional)

Briefly explain what work streams are:
- "Work streams organize your tasks into coherent bodies of work — like an epic or initiative. Each gets its own todo list and can be linked to repos and Jira epics."

Then ask: "Would you like to create a work stream now? (You can always create them later with `/new-task`.)"

- **If no**: Move on.
- **If yes**: Collect:
  - "What's the work stream name?" (convert to kebab-case for the filename)
  - "Brief description?"
- On re-run: "Would you like to create an additional work stream?"

The wizard may offer to create multiple work streams by repeating the prompt.

### 8. Show Summary and Confirm

Display a complete summary of everything that will be written. Clearly distinguish between unchanged, updated, and new values:

```
Here's what I'll set up:

📋 config.md
  GitHub Username: brianbell (detected via gh)
  Dev Directory:   ~/dev
  Default Branch:  main
  Jira:            skipped

📦 repos.md — 3 new repos
  + backflow — REST API service (go, backend)
  + wtui — Terminal UI framework (rust, cli)
  + docs-site — Documentation site (typescript, docs)

🔧 Work stream: error-handling-overhaul
  + notes/workstreams/error-handling-overhaul.md
  + notes/todos/error-handling-overhaul.md

Confirm? (y/n)
```

On re-run, mark unchanged values:

```
📋 config.md
  GitHub Username: brianbell (unchanged)
  Dev Directory:   ~/dev (unchanged)
  Default Branch:  main (unchanged)
  Jira Username:   brian.bell (new)
  Jira Project:    BACK (new)
  Jira Instance:   mycompany.atlassian.net (new)
```

**Wait for a single confirmation before writing any files.**

If nothing changed (re-run with all values current and no new repos), report:
- "Everything is already up to date. No changes needed."
Skip the write entirely.

### 9. Write Files

After the user confirms, write all files:

#### config.md

Write the full config file with the collected values:

```markdown
# Configuration

## GitHub
- **Username:** {username}

## Preferences
- **Dev Directory:** {dev_directory}
- **Default Branch:** main

## Optional Integrations

### Jira
- **Username:** {jira_username or <!-- your Jira username -->}
- **Default Project:** {jira_project or <!-- e.g., BACK -->}
- **Instance:** {jira_instance or <!-- e.g., mycompany.atlassian.net -->}
```

#### repos.md

If new repos were selected, append them to `repos.md` (create the file if it doesn't exist). Use this format per repo:

```markdown
## {repo-name}
- **URL:** {remote_url or local_path}
- **Description:** {description from gh or "—"}
- **Tags:** {topics from gh as comma-separated list, or "—"}
```

Preserve all existing entries in `repos.md` — append new entries at the end. Never remove or modify existing entries.

#### Work stream files (if any)

For each work stream the user chose to create:

1. Create `notes/workstreams/{name}.md` from `notes/templates/workstream.md`, filling in the name and description. Leave repo and Jira epic fields as template placeholders.
2. Create `notes/todos/{name}.md` from `notes/templates/todo.md`, filling in the work stream name.

### 10. Update Daily Log

Open or create today's daily log at `notes/daily/YYYY-MM-DD.md`:
- If it doesn't exist, create it from `notes/templates/daily.md`, filling in today's date.

Append to the **Activity Log** section:

```markdown
- **HH:MM** — [setup] Ran /eddy-setup — configured vault{details}
```

Where `{details}` includes a brief summary of what was done, e.g.:
- `, registered 3 repos`
- `, created work stream [[error-handling-overhaul]]`
- `, updated Jira config`

### 11. Summarize

Tell the user what was written and suggest next steps:
- What files were created or updated
- Suggested next commands: `/daily-plan`, `/new-task`, `/whats-next`
- Remind them to open `notes/` as an Obsidian vault if they haven't yet

## Re-run Behavior

The wizard is **additive-only** on re-runs:

- **Config values**: Each prompt shows the current value with an option to keep or change. Placeholders are treated as unconfigured.
- **Repos**: Only new repos (not already in `repos.md`) are presented as candidates. Existing entries are never removed or modified.
- **Work streams**: The wizard offers to create an additional work stream, never modifies existing ones.
- **Summary**: Clearly labels values as "unchanged", "updated", or "new".
- **No-op**: If everything is already current and no new repos are found, the wizard reports that and exits without writing.

## Important Rules

- **Single confirmation gate** — collect all values first, show one summary, ask once before any writes
- **Never write files without user confirmation**
- **Never remove or modify existing `repos.md` entries**
- **Never create or modify work streams without explicit user input**
- **Default branch is always `main`** — do not prompt for it
- Follow `vault-conventions.md` for all vault note creation
- Follow `daily-log-format.md` for the daily log entry format
- Use `[setup]` as the action type prefix in daily log entries
