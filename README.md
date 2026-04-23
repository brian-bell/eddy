# Eddy

*Your daily undercurrent of knowledge.*

[![Use this template](https://img.shields.io/badge/Use%20this%20template-238636?logo=github&logoColor=white)](https://github.com/brian-bell/eddy/generate)

Manage tasks, PRs, and incoming information from a single repo with reusable workflow skills.

Powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code) or [Codex](https://chatgpt.com/codex) and [Obsidian](https://obsidian.md).

## Quick Start

1. **Create your repo** — click [**Use this template**](https://github.com/brian-bell/eddy/generate) above, then clone it:
   ```sh
   git clone <your-new-repo-url> ~/dev/eddy
   cd ~/dev/eddy
   ```
2. **Run the setup wizard** — start Claude Code (or Codex) and run `/eddy-setup`. It auto-detects your GitHub username, scans for repos, and configures everything interactively:
   ```sh
   claude
   # then type: /eddy-setup
   ```

3. **Start using it** — try `/my-prs` to see your open PRs or `/daily-plan` to plan your day.

### Start the Day
- **`/daily-plan`** — Build today's plan from calendar + open todos + priorities
- **`/whats-next`** — Prioritized next actions across all sources

### Capture
- **`/new-task`** — Start a task against a work stream — scaffolds a coding folder (clones repos + CLAUDE.md/AGENTS.md + JOURNAL.md) by default; non-coding captures the output type
- **`/ingest`** — Drop Slack/email/meeting notes into the vault
- **`/idea`** — Quick idea capture with auto-metadata

### Code & Ship
- **`/commit`** / **`/ship`** — Commit / push + open PR
- **`/rebase`** — Rebase on main, resolve conflicts
- **`/my-prs`** — Your PRs: status, review feedback, conflicts
- **`/review-prs`** — PRs awaiting your review

### Tickets
- **`/jira`** — Query/create/update via acli
- **`/linear`** — Query/create/update via linearis/MCP

### Reflect & Maintain
- **`/checkpoint`** — Capture task state in `JOURNAL.md`; `--promote` also drops a note into the work stream
- **`/recap`** — Daily or weekly summary
- **`/architecture`** — Interview-driven ARCHITECTURE.md
- **`/docs`** — Refresh CLAUDE.md + README.md
- **`/eddy-setup`** — Onboarding / reconfigure vault

### Vault Map (`notes/`)
| Dir | What lives here |
|---|---|
| `daily/` | `YYYY-MM-DD.md` — spine of each day |
| `todos/` | Single `running.md` with inline fields per item |
| `prs/` | PR notes + review feedback todos |
| `tickets/` | Cached Jira/Linear tickets |
| `squawk/` | Ingested Slack/email/meeting notes |
| `ideas/` | Passively tracked ideas |
| `workstreams/` | Explicit work stream registry |
| `recaps/` | Daily + weekly summaries |
| `templates/` | Note templates |

### Rules of the Road
- YAML frontmatter on every note
- `[[wikilinks]]` between notes, `#tags` in body
- Every skill appends to the daily log
- Work streams are **never** auto-created or auto-modified — always confirm

### Auto-capture (Claude Code only)
Each coding task folder gets a `JOURNAL.md` plus `SessionStart` / `SessionEnd` hooks installed by `/new-task`. The `SessionEnd` hook appends a `[session]` entry with a git delta (and, by default, a 2–3 sentence LLM summary) to the journal. The `SessionStart` hook replays the journal state + filtered todos into the agent's first turn so you pick up where you left off. `/checkpoint` lets you mark state between sessions. See [`docs/migrations/task-journal.md`](docs/migrations/task-journal.md) to adopt it in existing task folders.

### Key Files
- `config.md` — GitHub user, prefs, integrations
- `repos.md` — Repo registry
- `ARCHITECTURE.md` — System overview

### Upgrading an existing vault
See [docs/migrations/](docs/migrations/) for guides covering schema changes. Most recent: [task-journal](docs/migrations/task-journal.md) — per-task `JOURNAL.md` + `SessionStart`/`SessionEnd` hooks + `/checkpoint`.
