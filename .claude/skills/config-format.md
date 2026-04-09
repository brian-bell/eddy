# Config Format

User configuration lives at `config.md` in the repo root. It's a markdown file with sections.

## Parsing

Read `config.md` and extract values from the markdown list items. Each setting is a bold key followed by a value:

```
- **Key:** value
```

## Sections and Keys

### GitHub
- **Username** — GitHub username for PR queries

### Preferences
- **Dev Directory** — Base directory for task folders (default: `~/dev`)
- **Default Branch** — Default branch name (default: `main`)

### Optional Integrations

#### Jira
- **Username** — Jira username for ticket queries
- **Default Project** — Default Jira project key (e.g., BACK)
- **Instance** — Jira instance URL (e.g., mycompany.atlassian.net)

These values are only needed if using the `/jira` skill. Other skills that surface ticket data (`/daily-plan`, `/whats-next`, `/recap`) read from cached vault notes in `notes/tickets/` and work fine without Jira configured.

## Usage in Skills

When a skill needs a config value:
1. Read `config.md`
2. Find the relevant section
3. Extract the value after `**Key:**`
4. If the value is a comment placeholder (`<!-- ... -->`), treat it as unconfigured and ask the user to set it up

## GitHub Username Resolution

When a skill needs the GitHub username, follow this fallback chain in order:

### Step 1: Read config.md

Read the GitHub → Username value from `config.md`. If it contains a real value (not a `<!-- ... -->` placeholder), use it. Done.

### Step 2: Detect via `gh api user`

Run `gh api user` and extract the `.login` field. This is the GitHub login, not the display name.

If successful:
- Use the detected username
- Write it back to `config.md`, replacing the placeholder on the `- **Username:**` line in the GitHub section
- Proceed with the skill

If `gh` is not installed, not authenticated, or the call fails for any reason (network error, rate limit, etc.), silently fall through to Step 3. Do not show an error about `gh`.

> **Note:** This is the one exception to the "always use the GitHub MCP plugin tools, not the `gh` CLI" rule. The `gh` CLI is used here only for username detection — never for PR queries or other GitHub API calls.

### Step 3: Ask the user

Prompt the user for their GitHub username. To help them, check `git config user.name` and include it as a hint — but since this returns a display name (e.g., "Brian Bell"), not a login (e.g., "brianbell"), never auto-accept it. The user must confirm or type their actual login.

If the user provides a username:
- Use it
- Write it back to `config.md`, replacing the placeholder
- Proceed with the skill
