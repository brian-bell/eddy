# Completed-Todos Migration Guide

If you adopted the running-todos layout (see [`running-todos.md`](./running-todos.md)) before this change, your `notes/todos/running.md` likely contains both open `- [ ]` and completed `- [x]` items mixed together. This change splits completions into a dated archive at `notes/todos/completed.md`. This guide walks you through the one-time migration.

## What changed

- **New file:** `notes/todos/completed.md` is the durable archive of completed todos. Items are grouped by `## YYYY-MM-DD` headings (newest day first). Each day's section contains the `- [x]` lines that finished on that date.
- **Immediate move on completion:** when the user says "I finished X", the agent now flips the box, appends `| completed: YYYY-MM-DD`, removes the line from `running.md`, and prepends it to today's heading in `completed.md`. Completed items NEVER linger in `running.md`.
- **`/recap` daily** reads only today's heading in `completed.md`. **`/recap` weekly** reads every heading from this week's Monday through today.
- **`/whats-next`** appends a tiny "Today's Wins" footer driven by today's heading in `completed.md` (count + top 3) for momentum context. It does NOT use earlier days.

See [`vault-conventions.md`](../../.claude/skills/vault-conventions.md) for the full spec, including the "Completing items" and "Completed Todos Archive" sections.

## Before you start

1. **Commit your vault.** `git add -A && git commit -m "pre completed-todos snapshot"` so you can roll back if needed.
2. **Pull the latest Eddy skills.** `git pull` in whichever directory hosts the Eddy `.claude/` skills, so the updated templates and skill docs are available.

## Step 1 — create `completed.md`

Seed the file from the template:

```sh
cp notes/templates/completed.md notes/todos/completed.md
```

Open it and delete the example-comment block if you prefer a clean file. The frontmatter and H1 should stay.

## Step 2 — move existing `[x]` items out of `running.md`

For every `- [x] …` line in `notes/todos/running.md`:

1. Read the line's `completed: YYYY-MM-DD` field. If the line lacks `completed:`, set it to today (or the date you finished it, if you remember).
2. In `completed.md`, ensure a `## YYYY-MM-DD` heading exists for that date. If not, insert it in the correct chronological position (newest at top).
3. Move the `- [x]` line under that heading. Remove it from `running.md`.

### Semi-automated split

This `awk` one-liner partitions an existing `running.md` into "open lines stay" and "completed lines route by date." Review its output before overwriting either file.

```sh
awk '
  /^- \[x\]/ {
    if (match($0, /completed: ([0-9]{4}-[0-9]{2}-[0-9]{2})/, m)) {
      print $0 > "completed-by-date/" m[1] ".tmp"
    } else {
      print $0 > "completed-by-date/UNKNOWN.tmp"
    }
    next
  }
  { print }   # everything else (including frontmatter, header, comments, open items) stays
' notes/todos/running.md > notes/todos/running.new.md
```

Then assemble `completed.md` by concatenating the date-bucket files in reverse chronological order, prepending each with `## <date>` and a blank line. Hand-fix any items that landed in `UNKNOWN.tmp` (they had no `completed:` field).

When the result looks right:

```sh
mv notes/todos/running.new.md notes/todos/running.md
```

## Step 3 — verify

1. `notes/todos/running.md` should contain ZERO `- [x]` lines:
   ```sh
   grep -c '^- \[x\]' notes/todos/running.md   # expect: 0
   ```
2. `notes/todos/completed.md` should have one `## YYYY-MM-DD` heading per distinct completion date, and the lines under each heading should all carry that exact `completed:` value:
   ```sh
   grep -c '^- \[x\]' notes/todos/completed.md
   ```
3. Run `/recap daily`. The "Completed" section should show today's items pulled from `completed.md` (and nothing from earlier days).
4. Run `/recap weekly`. The "Completed" section should aggregate items from this week's Monday → today across `completed.md`'s headings.
5. Run `/whats-next`. If you completed anything today, you should see a small "Today's Wins" footer at the bottom; otherwise the footer should be absent.
6. Tell the agent "I finished `<an open todo from running.md>`". Confirm the line disappears from `running.md` and appears at the top of today's `## YYYY-MM-DD` section in `completed.md` (a new heading is created if today wasn't there yet).

## Rollback

Everything is in git:

```sh
git reset --hard <pre-migration commit>
```

Then pin the Eddy skill repo to a pre-migration commit until you're ready to retry.
