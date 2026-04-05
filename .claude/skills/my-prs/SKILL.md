---
name: my-prs
description: Manage your authored PRs - status, review feedback todos, merge conflicts, branch staleness
---

# My PRs

Fetch and display your authored PRs with compact status. Parse review feedback into vault todo items.

## Process

### 1. Get GitHub Username

Read `config.md` (per `config-format.md`) for the GitHub username.
If unconfigured, ask the user.

### 2. Fetch PRs

Use the GitHub MCP plugin tools to fetch open PRs authored by the user:
- Use `mcp__plugin_github_github__search_pull_requests` with query `is:open is:pr author:<username>`
- For each PR, use `mcp__plugin_github_github__pull_request_read` to get full details including:
  - Check/CI status
  - Review comments and review status
  - Merge conflict status
  - Branch staleness (commits behind base)

### 3. Display Compact Summary

Print a terminal summary grouped by status:

```
## My Open PRs

### Needs Attention
- **repo#123** — PR title
  Checks: failing | Conflicts: yes | Reviews: 2 approved, 1 changes_requested
  
### Waiting on Review
- **repo#456** — PR title  
  Checks: passing | Conflicts: none | Reviews: 0/2 approved

### Ready to Merge
- **repo#789** — PR title
  Checks: passing | Conflicts: none | Reviews: 2/2 approved
```

### 4. Parse Review Feedback

For PRs with review comments (especially `changes_requested`):

1. Extract individual review comments
2. Create or update `notes/prs/<repo>-<number>.md` following `vault-conventions.md`:

```markdown
---
repo: <repo-name>
pr: <number>
title: "<PR title>"
status: <review status>
reviewers: [reviewer1, reviewer2]
work_stream: <matched work stream if identifiable>
date: <today>
---

# PR #<number>: <title>

Part of [[<Work Stream>]]

#<repo-name>

## Review Feedback
- [ ] @reviewer: Comment summary (file: path/to/file)
- [ ] @reviewer: Another comment (file: path/to/file)
- [x] @reviewer: Already resolved comment

## Status
- **Checks:** passing/failing
- **Conflicts:** none/yes
- **Branch:** up to date / N commits behind
```

3. Match PRs to work streams by looking at repo names in `notes/workstreams/` frontmatter

### 5. Drill-Down Support

If the user asks about a specific PR (e.g., "tell me more about #123"):
- Fetch full PR details
- Show all review comments with file paths and line numbers
- Show the full diff summary
- Update the vault note with latest state

### 6. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
```
- **HH:MM** — [my-prs] Reviewed N open PRs — X need attention, Y waiting, Z ready to merge
```

## Important Rules

- Always use the GitHub MCP plugin tools, not the `gh` CLI
- Create vault notes only for PRs with review feedback (not every open PR)
- When updating existing PR vault notes, preserve manually added content — only update the Status section and add new review comments
- Match work streams by checking if the PR's repo appears in any work stream's `repos` frontmatter field
