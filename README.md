# Productivity Workflow Hub

A personal command center powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Obsidian](https://obsidian.md). Manage tasks, PRs, Jira tickets, and incoming information from a single repo with 10 slash-command skills.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with the **GitHub plugin** enabled
- [Obsidian](https://obsidian.md) (for browsing the knowledge graph)
- [acli](https://bobswift.atlassian.net/wiki/spaces/ACLI/overview) (optional, for Jira integration)

## Getting Started

1. **Clone and enter the repo:**
   ```sh
   git clone <repo-url> ~/dev/new-primary-workflow
   cd ~/dev/new-primary-workflow
   ```

2. **Fill in your config** — edit `config.md` with your GitHub username, Jira credentials, and preferences.

3. **Add your repositories** — edit `repos.md` with the repos you work on (name, URL, description, tags). Or run `/architecture` to do this interactively.

4. **Open the vault in Obsidian** — open the `notes/` folder as an Obsidian vault to browse the knowledge graph.

5. **Start Claude Code** in the repo folder and you're ready to go:
   ```sh
   claude
   ```

## Skills

| Command | What it does |
|---------|-------------|
| `/new-task` | Create a task, categorize it into a work stream, add todos |
| `/start-coding` | Clone repos into a fresh task folder with full context |
| `/ingest` | Paste Slack/email/etc. to capture, categorize, and extract action items |
| `/my-prs` | See your open PRs with status, review feedback as todos |
| `/review-prs` | See PRs waiting for your review |
| `/jira` | Find, create, or check status of Jira tickets |
| `/daily-plan` | Plan your day from calendar + open work |
| `/recap` | Daily or weekly summary of what happened |
| `/whats-next` | Prioritized list of what to work on next |
| `/architecture` | Build/update the system architecture doc via interview |

## How It Works

- **Obsidian vault** (`notes/`) stores everything as markdown with YAML frontmatter, `[[wikilinks]]`, and `#tags`
- **Skills** read and write vault notes following shared conventions in `.claude/skills/`
- **Daily log** (`notes/daily/`) is the spine — every skill appends activity entries
- **Work streams** (`notes/workstreams/`) organize tasks into coherent bodies of work
- **Squawk** (`notes/squawk/`) captures ingested info from any source

All vault data is plain markdown files in git — portable, searchable, and version-controlled.
