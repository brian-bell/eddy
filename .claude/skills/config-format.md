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

### Jira
- **Username** — Jira username for ticket queries
- **Default Project** — Default Jira project key (e.g., BACK)
- **Instance** — Jira instance URL (e.g., mycompany.atlassian.net)

### Preferences
- **Dev Directory** — Base directory for task folders (default: `~/dev`)
- **Default Branch** — Default branch name (default: `main`)

## Usage in Skills

When a skill needs a config value:
1. Read `config.md`
2. Find the relevant section
3. Extract the value after `**Key:**`
4. If the value is a comment placeholder (`<!-- ... -->`), treat it as unconfigured and ask the user to set it up
