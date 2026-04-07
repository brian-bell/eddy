---
name: review-prs
description: List PRs awaiting your review action - requested reviews and mentions
---

# Review PRs

Show PRs that need your review attention — requested reviews and mentions.

## Process

### 1. Get GitHub Username

Resolve the GitHub username using the fallback chain defined in `config-format.md` (GitHub Username Resolution).

### 2. Fetch PRs Awaiting Review

Use the GitHub access available in the environment. Prefer GitHub MCP/plugin tools when available, otherwise use `gh`.

**Requested reviews:**
- Search for open PRs with `review-requested:<username>`

**Mentions:**
- Search for open PRs with `mentions:<username> -author:<username>`

For each PR, fetch basic details:
- Title, repo, author
- Age (when was review requested / when was user mentioned)
- Number of files changed
- Number of other reviewers and their status

### 3. Display Grouped by Urgency

Print a terminal summary:

```
## PRs Awaiting Your Action

### Needs Review (requested)
1. **repo#155** — PR title (@author)
   Requested 3 days ago | 12 files changed | 0/2 reviewed

2. **repo#160** — PR title (@author)
   Requested today | 3 files changed | 1/2 reviewed

### Mentioned
3. **repo#148** — PR title (@author)
   Mentioned 1 day ago — "@you what do you think about this approach?"
```

Sort within each group by age (oldest first — most urgent).

### 4. Engage with a PR

If the user wants to dig into a specific PR:
1. Fetch full PR details using GitHub MCP/plugin tools or `gh pr view`
2. Show: description, key files changed, existing review comments
3. Create a lightweight vault note at `notes/prs/<repo>-<number>.md` with frontmatter
4. Ask if the user wants to start reviewing (open in browser, add comments, etc.)

Only create vault notes when the user explicitly engages — not for every PR in the list.

### 5. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
```
- **HH:MM** — [review-prs] N PRs awaiting review — X requested, Y mentioned
```

## Important Rules

- Prefer GitHub MCP/plugin tools when available, but fall back to `gh` when needed
- Don't create vault notes for every listed PR — only when the user engages
- Exclude the user's own PRs from the mentions list (filter `-author:<username>`)
- Sort by urgency: oldest review requests first
