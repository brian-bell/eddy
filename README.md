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

## What You'll See

After `/eddy-setup`:
```
✓ Detected GitHub username: yourname
✓ Found 12 repos in ~/dev
✓ Config saved to config.md
✓ Repos registered in repos.md
```

After `/my-prs`:
```
## Your Open PRs

| Repo | PR | Status | Reviews |
|------|----|--------|---------|
| api  | #42 Fix auth timeout | ✓ Approved | 2/2 |
| web  | #108 Add dashboard | ● Changes requested | 1/2 |

Created 2 review feedback todos in notes/todos/
```

## Skills

| Command | What it does |
|---------|-------------|
| `/daily-plan` | Plan your day from calendar + open work |
| `/my-prs` | See your open PRs with status, review feedback as todos |
| `/whats-next` | Prioritized list of what to work on next |
| `/new-task` | Create a task, categorize it into a work stream, add todos |
| `/start-coding` | Clone repos into a fresh task folder with full context |
| `/ingest` | Paste Slack/email/etc. to capture, categorize, and extract action items |
| `/idea` | Capture an idea for passive tracking with auto-inferred metadata |
| `/review-prs` | See PRs waiting for your review |
| `/recap` | Daily or weekly summary of what happened |
| `/eddy-setup` | Interactive onboarding wizard for vault configuration |
| `/architecture` | Build/update the system architecture doc via interview |
| `/jira` | Find, create, or check status of Jira tickets ([setup required](#jira)) |

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) or [Codex](https://chatgpt.com/codex)
- GitHub access through MCP/plugin integration if available, or the `gh` CLI as a fallback for PR workflows
- [Obsidian](https://obsidian.md) (for browsing the knowledge graph)

## How It Works

- **Obsidian vault** (`notes/`) stores everything as markdown with YAML frontmatter, `[[wikilinks]]`, and `#tags`
- **Skills** are authored in `.claude/skills/`; for Codex, install them into `~/.agents/skills` with `./scripts/install-codex-skills.sh`
- **Daily log** (`notes/daily/`) is the spine — every skill appends activity entries
- **Work streams** (`notes/workstreams/`) organize tasks into coherent bodies of work
- **Squawk** (`notes/squawk/`) captures ingested info from any source

All vault data is plain markdown files in git — portable, searchable, and version-controlled.

## Codex Skills Installation

Codex discovers installed skills from `~/.agents/skills`, not from this repo directly. The source of truth for these skills lives in `.claude/skills/`.

Install or refresh the Codex skill links with:

```sh
./scripts/install-codex-skills.sh
```

If you need to replace conflicting symlinks in `~/.agents/skills`, run:

```sh
./scripts/install-codex-skills.sh --force
```

Start a fresh Codex session after installing or updating these links.

## Optional Integrations

### Jira

The `/jira` skill lets you find, create, and track Jira tickets from within Eddy. Other skills (`/daily-plan`, `/whats-next`, `/recap`) will include Jira data when available but work fine without it.

To enable Jira integration:
1. Install [acli](https://bobswift.atlassian.net/wiki/spaces/ACLI/overview) (Atlassian CLI) and configure authentication
2. Fill in the Jira section under "Optional Integrations" in `config.md`
