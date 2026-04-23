# Eddy

*Your daily undercurrent of knowledge.*

A second memory that combines an Obsidian knowledge vault with workflow skills for Claude Code or Codex to manage tasks, PRs, and incoming information.

## Skills

| Command | Description |
|---------|-------------|
| `/new-task` | Start a task against a work stream — scaffolds a coding folder (clones repos + CLAUDE.md/AGENTS.md + JOURNAL.md) by default; non-coding captures the output type |
| `/checkpoint` | Rewrite the task folder's `JOURNAL.md` state header and append a log entry after significant decisions, pivots, or blockers; `--promote` also notes it in the work stream |
| `/ingest` | Categorize pasted Slack/email/info into vault notes |
| `/my-prs` | Manage your authored PRs with review feedback todos |
| `/review-prs` | List PRs awaiting your review action |
| `/jira` | Query, create, track, comment on, and update Jira tickets via acli |
| `/linear` | Query, create, track, comment on, and update Linear tickets via linearis or MCP |
| `/daily-plan` | Create today's plan from calendar + priorities |
| `/recap` | Daily or weekly summary of all activity |
| `/whats-next` | Signal-based prioritized next actions |
| `/idea` | Capture an idea for passive tracking with auto-inferred metadata |
| `/eddy-setup` | Interactive onboarding wizard for vault configuration |
| `/architecture` | Interview-based ARCHITECTURE.md creation/update |

## Key Files

- `config.md` — GitHub username (auto-detected), preferences, optional integrations
- `repos.md` — Registry of all git repositories with descriptions and tags
- `ARCHITECTURE.md` — System architecture overview (maintained via `/architecture`)

## Vault Structure

The `notes/` directory is an Obsidian vault with these subdirectories:

| Directory | Purpose |
|-----------|---------|
| `notes/daily/` | Daily logs (`YYYY-MM-DD.md`) — the spine of each day |
| `notes/todos/` | Single running todo list at `running.md` with per-item inline fields (`workstream`, `source`, `added`, `due`, `stakeholder`) |
| `notes/prs/` | PR tracking notes with review feedback todos |
| `notes/tickets/` | Cached ticket notes (Jira, Linear) |
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
- `.claude/skills/ticket-format.md` — Unified ticket schema (Jira, Linear)
- `.claude/skills/config-format.md` — How to parse config.md
