#!/usr/bin/env python3
"""Module A — journal file operations.

Deterministic parse/rewrite of a task-folder JOURNAL.md. Three subcommands:

  journal-ops.py read-state <path>
  journal-ops.py write-state <path>   # reads new state from stdin
  journal-ops.py append-log <path>    # reads log entry from stdin

Contract (see notes/templates/journal.md and PRD #28):
  - The state region is the text from the first `## Current State` heading
    up to (but not including) the `## Log` heading. read-state and
    write-state operate on that region.
  - The `## Log` section is append-only. append-log adds an entry at the
    end. If `## Log` is missing, it is created at the end of the file.
  - Frontmatter and any intro prose before the state region are always
    preserved.
"""

from __future__ import annotations

import sys
from pathlib import Path


STATE_HEADINGS = (
    "## Current State",
    "## Next Steps",
    "## Open Questions",
    "## Blockers",
)
LOG_HEADING = "## Log"


def split_file(text: str) -> tuple[str, str, str]:
    """Return (prefix, state, log) parts of the journal text.

    - prefix: everything before the first state heading (frontmatter + intro).
    - state:  from the first state heading up to (but not including) `## Log`,
              or end-of-file if `## Log` is absent.
    - log:    from `## Log` to end of file, or empty string if absent.

    If no state heading is present, state is empty and prefix covers the
    pre-log text.
    """
    lines = text.splitlines(keepends=True)

    state_start = None
    log_start = None
    for i, line in enumerate(lines):
        stripped = line.rstrip("\n")
        if state_start is None and stripped in STATE_HEADINGS:
            state_start = i
        if stripped == LOG_HEADING:
            log_start = i
            break

    if state_start is None:
        # No state region. Split prefix/log at log_start if present.
        if log_start is None:
            return "".join(lines), "", ""
        return "".join(lines[:log_start]), "", "".join(lines[log_start:])

    end = log_start if log_start is not None else len(lines)
    prefix = "".join(lines[:state_start])
    state = "".join(lines[state_start:end])
    log = "".join(lines[end:]) if log_start is not None else ""
    return prefix, state, log


def read_state(path: Path) -> str:
    _, state, _ = split_file(path.read_text())
    return state


def write_state(path: Path, new_state: str) -> None:
    prefix, _, log = split_file(path.read_text())

    # Normalize new_state so we control the trailing separator between
    # the state region and the log section.
    new_state = new_state.rstrip("\n")
    if new_state:
        new_state += "\n\n"

    if not log:
        # No existing Log section — create one at the end.
        log = LOG_HEADING + "\n<!-- Append-only. Newest entries at the bottom. -->\n"

    # Ensure prefix ends with exactly one trailing newline before state.
    if prefix and not prefix.endswith("\n"):
        prefix += "\n"
    if prefix and not prefix.endswith("\n\n") and new_state:
        prefix += "\n"

    path.write_text(prefix + new_state + log)


def append_log(path: Path, entry: str) -> None:
    text = path.read_text()
    entry = entry.rstrip("\n") + "\n"

    if LOG_HEADING not in text:
        # Create the Log section at the end.
        if not text.endswith("\n"):
            text += "\n"
        if not text.endswith("\n\n"):
            text += "\n"
        text += LOG_HEADING + "\n<!-- Append-only. Newest entries at the bottom. -->\n\n"
        text += entry
        path.write_text(text)
        return

    # Log section exists — append entry at the end of the file, separated
    # from whatever came before by a blank line.
    if not text.endswith("\n"):
        text += "\n"
    if not text.endswith("\n\n"):
        text += "\n"
    text += entry
    path.write_text(text)


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        print(
            "usage: journal-ops.py {read-state|write-state|append-log} <path>",
            file=sys.stderr,
        )
        return 2

    cmd, raw_path = argv[1], argv[2]
    path = Path(raw_path)

    if cmd == "read-state":
        if not path.exists():
            print(f"journal-ops: no such file: {path}", file=sys.stderr)
            return 1
        sys.stdout.write(read_state(path))
        return 0

    if cmd == "write-state":
        if not path.exists():
            print(f"journal-ops: no such file: {path}", file=sys.stderr)
            return 1
        write_state(path, sys.stdin.read())
        return 0

    if cmd == "append-log":
        if not path.exists():
            print(f"journal-ops: no such file: {path}", file=sys.stderr)
            return 1
        append_log(path, sys.stdin.read())
        return 0

    print(f"journal-ops: unknown subcommand: {cmd}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
