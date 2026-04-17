# Running-Todos Migration Guide

If you started using Eddy before this change, your vault has per-work-stream todo files and `## Tasks` sections inside work stream notes. This migration collapses those into a single running list and reshapes the work stream template. This guide walks you through converting an existing vault.

## What changed

- **Todos:** every per-stream file (`notes/todos/<stream>.md`) is replaced by one running list at `notes/todos/running.md`. Each item carries its workstream (and other context) inline.
- **Work streams:** the `## Tasks` section is removed from the work stream template. `## Notes` stays. A new `## Links & Context` section is added for screenshots, decision docs, and external pointers.
- **Skills:** `/start-coding` no longer creates todos or writes into the work stream body. `/ingest` now proposes todo items interactively instead of silently writing them.
- **Due dates + snooze:** items now take an optional `due: YYYY-MM-DD` field. `/daily-plan` includes items due today, overdue items, and undated items; items due in the next 2 days appear in a "Coming Up" section; items due further out are hidden until their window arrives. Snooze by editing `due` to a later date — there is no separate snooze state. You do not need to backfill `due` during migration; leaving it off means the item stays eligible every day.

See [ROADMAP.md](../../ROADMAP.md) for the rationale.

## Before you start

1. **Commit your vault.** `git add -A && git commit -m "pre running-todos snapshot"` in the vault repo so you can roll back if needed.
2. **Pull the latest Eddy skills.** `git pull` in whichever directory hosts the Eddy `.claude/` skills, so the updated templates and skill docs are available.
3. Have `notes/todos/` and `notes/workstreams/` open for reference.

## Step 1 — create `running.md`

Seed the new file from the updated template:

```sh
cp notes/templates/todo.md notes/todos/running.md
```

Open `notes/todos/running.md` and delete the example-comment block if you prefer a clean file. The frontmatter and H1 should stay.

## Step 2 — migrate each per-stream todo file

For each `notes/todos/<stream>.md` (other than `running.md`), rewrite every checkbox line into the new pipe-separated format and append it to `running.md`.

### Item format

```
- [ ] <description> [[optional-link]] — workstream: <stream> | added: YYYY-MM-DD [ | source: <type>] [ | stakeholder: @person]
```

Completed items keep their `[x]` and gain a trailing `| completed: YYYY-MM-DD`.

### Mapping fields

| Old form | New field |
|---|---|
| Filename `<stream>.md` | `workstream: <stream>` |
| `— added YYYY-MM-DD` trailer | `added: YYYY-MM-DD` |
| `— completed YYYY-MM-DD` trailer | `completed: YYYY-MM-DD` |
| No date present | Use the file's `git log -1 --format=%cs -- <file>` first-commit date, or today as a last resort |
| Nothing in the old format | Leave `source` and `stakeholder` unset — they'll be populated going forward (Phase B1/B2) |

### Example

**Before** — `notes/todos/error-handling-overhaul.md`:

```markdown
---
work_stream: error-handling-overhaul
---

# error-handling-overhaul — Todos

- [ ] Audit timeout paths in backflow [[backflow-142]] — added 2026-03-28
- [x] Document retry policy — completed 2026-04-02
```

**After** — appended to `notes/todos/running.md`:

```markdown
- [ ] Audit timeout paths in backflow [[backflow-142]] — workstream: error-handling-overhaul | added: 2026-03-28
- [x] Document retry policy — workstream: error-handling-overhaul | added: 2026-03-28 | completed: 2026-04-02
```

### Semi-automated conversion

For each old todo file, this `awk` one-liner gets you most of the way. Review its output before appending — it handles the common `— added YYYY-MM-DD` / `— completed YYYY-MM-DD` trailers and drops the frontmatter and H1.

```sh
stream=$(basename notes/todos/error-handling-overhaul.md .md)
awk -v ws="$stream" '
  /^---$/ { fm = !fm; next }
  fm || /^#/ || /^<!--/ || NF == 0 { next }
  /^- \[[ x]\]/ {
    line = $0
    sub(/ — added /, " — workstream: " ws " | added: ", line)
    sub(/ — completed /, " — workstream: " ws " | added: UNKNOWN | completed: ", line)
    if (line !~ /workstream:/) line = line " — workstream: " ws " | added: UNKNOWN"
    print line
  }
' notes/todos/error-handling-overhaul.md >> notes/todos/running.md
```

Hand-fix any `added: UNKNOWN` markers with the real date (or today's).

### Delete the old files

Once everything is migrated and `running.md` looks right:

```sh
git rm notes/todos/<stream>.md
```

Do this per stream; keep `notes/todos/.gitkeep` if it exists.

## Step 3 — reshape each work stream

For every `notes/workstreams/<stream>.md`:

1. Delete the `## Tasks` section. If it contained links to task folders that you still care about, move those lines into a new `## Links & Context` section at the bottom of the file (same bullet shape — they're pointers, not prose).
2. Keep `## Description`, `## Related`, and `## Notes` exactly as they are.
3. Add `## Links & Context` if it isn't already there, even if empty — future ingests and decision docs will land there.

**Before:**

```markdown
## Related
- Repos: [[backflow]]

## Tasks
- fix-auth-timeout: patch retry backoff — started 2026-03-28
- audit-error-paths: survey across services — started 2026-04-02

## Notes
Decided at the 03-27 sync to prioritize backflow first.
```

**After:**

```markdown
## Related
- Repos: [[backflow]]

## Notes
Decided at the 03-27 sync to prioritize backflow first.

## Links & Context
- fix-auth-timeout task folder
- audit-error-paths task folder
```

## Step 4 — verify

1. `git grep -n "notes/todos/<" .claude` — should return nothing (no skill still references a per-stream todo file).
2. `git grep -n "^## Tasks$" notes/workstreams` — should return nothing.
3. Run `/whats-next`. It should read `running.md`, parse inline fields, and group by workstream without errors.
4. Run `/daily-plan`. Same expectation — items come from `running.md`.
5. Check an item off in `running.md`, add `| completed: YYYY-MM-DD`, then run `/recap daily` — the completion should appear.
6. Run `/new-task` with a throwaway task. Confirm it appends one line to `running.md` and does not create a per-stream file or edit a work stream.

If any of those fail, `git diff` the migration and look for items that still carry an old trailer (`— added …` without a pipe) or stray per-stream todo files.

## Rollback

Everything is in git. If anything goes sideways:

```sh
git reset --hard <pre-migration commit>
```

Then pin the Eddy skill repo to a pre-migration commit until you're ready to retry.
