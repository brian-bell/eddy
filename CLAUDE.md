# Productivity Workflow Hub

This repo is a personal command center for daily work. It combines an Obsidian knowledge vault with Claude Code skills to manage tasks, PRs, Jira tickets, and incoming information.

## Skills

| Command | Description |
|---------|-------------|
| `/new-task` | Create and categorize a new task into work streams |
| `/start-coding` | Clone repos into a task folder with full scaffolding |
| `/ingest` | Categorize pasted Slack/email/info into vault notes |
| `/my-prs` | Manage your authored PRs with review feedback todos |
| `/review-prs` | List PRs awaiting your review action |
| `/jira` | Query, create, and track Jira tickets via acli |
| `/daily-plan` | Create today's plan from calendar + priorities |
| `/recap` | Daily or weekly summary of all activity |
| `/whats-next` | Signal-based prioritized next actions |
| `/idea` | Capture an idea for passive tracking with auto-inferred metadata |
| `/architecture` | Interview-based ARCHITECTURE.md creation/update |

## Key Files

- `config.md` — GitHub username (auto-detected), Jira settings, preferences
- `repos.md` — Registry of all git repositories with descriptions and tags
- `ARCHITECTURE.md` — System architecture overview (maintained via `/architecture`)

## Vault Structure

The `notes/` directory is an Obsidian vault with these subdirectories:

| Directory | Purpose |
|-----------|---------|
| `notes/daily/` | Daily logs (`YYYY-MM-DD.md`) — the spine of each day |
| `notes/todos/` | Per-work-stream todo files with checkbox items |
| `notes/prs/` | PR tracking notes with review feedback todos |
| `notes/jira/` | Cached Jira ticket notes |
| `notes/recaps/` | Daily and weekly recap summaries |
| `notes/workstreams/` | Work stream definitions (explicit registry) |
| `notes/squawk/` | Ingested items — Slack messages, emails, meeting notes |
| `notes/ideas/` | Idea notes — passively tracked feature/tool/process ideas |
| `notes/templates/` | Note templates used by skills |

## Vault Conventions

All skills MUST follow the conventions in `.claude/skills/vault-conventions.md` when creating or modifying vault notes. Key rules:

- Every note uses YAML frontmatter for structured metadata
- Use `[[wikilinks]]` to link between related notes
- Use `#tags` in note body for quick filtering
- Every skill that creates/modifies vault data appends a summary to the daily log
- Work streams are NEVER auto-created or auto-modified without explicit user confirmation

See also:
- `.claude/skills/daily-log-format.md` — Daily log conventions
- `.claude/skills/workstream-format.md` — Work stream conventions
- `.claude/skills/config-format.md` — How to parse config.md
