# Task Journal Migration Guide

Eddy now adds a per-task `JOURNAL.md` to every coding task folder, plus Claude Code `SessionStart` / `SessionEnd` hooks that auto-resume and auto-capture work across sessions. `/checkpoint` lets you mark state explicitly, and the task-completion workflow can synthesize a retrospective into the work stream.

New task folders created via `/new-task` get all of this automatically. This guide covers adopting it in task folders that existed before the change.

## What changed

- **`notes/templates/journal.md`** — new per-task journal template (frontmatter + state header + append-only `## Log`).
- **`.claude/hooks/`** — new directory with `journal-ops.py` (state/log ops), `git-delta.py` (delta collector + entry renderer), `session-start.sh` (resume brief), `session-end.sh` (auto-capture), and `summarize-transcript.sh` (optional LLM session summary).
- **`/checkpoint`** — new skill that rewrites `JOURNAL.md` state and appends `[checkpoint]` log entries. `--promote` additionally drafts a dated line into the work stream's `## Notes` section (user approval required).
- **`/new-task`** — coding mode now scaffolds `JOURNAL.md` and installs both hooks in the task folder's `.claude/settings.json`.
- **Task completion** — coding tasks with a populated `JOURNAL.md` can synthesize a retrospective into the work stream's `## Notes` (approval gated). Non-coding tasks and journal-less folders fall through unchanged.
- **`config.md`** — new Task Journal section with a `Session Summary: on | off` knob (default `on`).

`running.md` is never touched by the journal; work streams are never modified without explicit user approval (matching eddy's existing rule).

## Adopting in existing task folders

Inside each pre-existing task folder, run `/checkpoint`. If no `JOURNAL.md` is found, the skill will offer to initialize one and install the hooks — one shot, no manual editing needed. Say yes and you're done.

If you skip that step, each folder continues to work exactly as before: the hooks only run where they're installed, and all other skills behave as they did pre-migration.

## Disabling the LLM summary

The only variable-cost piece is the 2–3 sentence transcript summary in each `SessionEnd` entry. Flip it off by editing `config.md`:

```markdown
## Task Journal
- **Session Summary:** off
```

With the knob off, `SessionEnd` still writes the git-delta portion of each `[session]` entry — no summary, no `claude -p` invocation.

## Codex

Codex sessions continue to work through the existing `AGENTS.md → CLAUDE.md` symlink. They do not run Claude Code hooks, so they do not write to `JOURNAL.md`. Parity with the pre-journal flow is preserved.
