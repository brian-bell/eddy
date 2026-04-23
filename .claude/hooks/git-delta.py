#!/usr/bin/env python3
"""Module B — git delta collector.

Walks the immediate child directories of a task folder, detects git
repositories, and emits a structured delta per repo: commits since the
last run, files changed, current branch. Baseline state lives under
`<task-folder>/.claude/journal-state/<repo>.last-ref`.

Subcommands:

  git-delta.py collect <task-folder>      # emits JSON to stdout
  git-delta.py render                     # JSON on stdin → markdown entry

Edge cases handled (per PRD #28):
  - No commits since last run  → empty commits + files arrays.
  - Newly cloned repo          → new_repo=True, no commits reported,
                                 baseline written so next run sees delta.
  - Detached HEAD              → branch reported as '(detached)'.
  - Repo with no upstream      → unaffected (local refs only).
  - Repo added mid-task        → same as newly cloned repo.
  - Non-git child directories  → skipped silently.
"""

from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


STATE_DIR_NAME = ".claude/journal-state"


def run_git(repo: Path, *args: str) -> tuple[int, str, str]:
    proc = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True,
        text=True,
    )
    return proc.returncode, proc.stdout, proc.stderr


def current_branch(repo: Path) -> str:
    code, out, _ = run_git(repo, "rev-parse", "--abbrev-ref", "HEAD")
    if code != 0:
        return "(unknown)"
    name = out.strip()
    if name == "HEAD":
        return "(detached)"
    return name


def current_head(repo: Path) -> str | None:
    code, out, _ = run_git(repo, "rev-parse", "HEAD")
    if code != 0:
        return None
    return out.strip() or None


def commits_between(repo: Path, since: str, until: str) -> list[dict]:
    # Format: <sha>\x1f<subject>, one per line. Avoids issues with tabs in subjects.
    code, out, _ = run_git(
        repo,
        "log",
        "--format=%H%x1f%s",
        f"{since}..{until}",
    )
    if code != 0 or not out.strip():
        return []
    rows = []
    for line in out.strip().splitlines():
        if "\x1f" in line:
            sha, subject = line.split("\x1f", 1)
            rows.append({"sha": sha, "subject": subject})
    return rows


def files_between(repo: Path, since: str, until: str) -> list[str]:
    code, out, _ = run_git(repo, "diff", "--name-only", f"{since}..{until}")
    if code != 0:
        return []
    return [line for line in out.splitlines() if line]


def collect(task_folder: Path) -> dict:
    state_dir = task_folder / STATE_DIR_NAME
    state_dir.mkdir(parents=True, exist_ok=True)

    repos: list[dict] = []
    for child in sorted(task_folder.iterdir()):
        if not child.is_dir():
            continue
        if not (child / ".git").exists():
            continue

        name = child.name
        branch = current_branch(child)
        head = current_head(child)
        state_file = state_dir / f"{name}.last-ref"

        if head is None:
            # Empty repo (no commits yet).
            repos.append(
                {
                    "name": name,
                    "branch": branch,
                    "head": None,
                    "new_repo": not state_file.exists(),
                    "commits_since_last": [],
                    "files_changed": [],
                    "file_change_count": 0,
                }
            )
            continue

        if not state_file.exists():
            # First time we've seen this repo under this task folder.
            state_file.write_text(head + "\n")
            repos.append(
                {
                    "name": name,
                    "branch": branch,
                    "head": head,
                    "new_repo": True,
                    "commits_since_last": [],
                    "files_changed": [],
                    "file_change_count": 0,
                }
            )
            continue

        last_ref = state_file.read_text().strip()
        commits = commits_between(child, last_ref, head) if last_ref else []
        files = files_between(child, last_ref, head) if last_ref else []

        # Update baseline for next run.
        state_file.write_text(head + "\n")

        repos.append(
            {
                "name": name,
                "branch": branch,
                "head": head,
                "new_repo": False,
                "commits_since_last": commits,
                "files_changed": files,
                "file_change_count": len(files),
            }
        )

    return {
        "task_folder": str(task_folder),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "repos": repos,
    }


def render(data: dict, summary: str = "") -> str:
    ts = data.get("generated_at", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    repos = data.get("repos", [])

    # One-line reason: summarize across repos.
    total_commits = sum(len(r.get("commits_since_last", [])) for r in repos)
    total_files = sum(r.get("file_change_count", 0) for r in repos)
    if total_commits == 0 and total_files == 0:
        reason = "session ended — no new commits"
    else:
        reason = f"session ended — {total_commits} commit(s), {total_files} file(s) changed"

    lines = [f"### [session] {ts} — {reason}", ""]

    summary = (summary or "").strip()
    if summary:
        lines.append("**Session summary**")
        lines.append("")
        lines.append(summary)
        lines.append("")
        if repos:
            lines.append("**Repo changes**")
            lines.append("")

    if not repos:
        lines.append("_No child repositories detected._")
        return "\n".join(lines) + "\n"

    for r in repos:
        name = r.get("name", "?")
        branch = r.get("branch", "?")
        head = r.get("head") or "(no commits)"
        head_short = head[:8] if len(head) >= 8 else head
        flag = " _(new repo baselined)_" if r.get("new_repo") else ""
        lines.append(f"**{name}** — branch `{branch}` @ `{head_short}`{flag}")
        commits = r.get("commits_since_last", [])
        if commits:
            lines.append("")
            lines.append("Commits:")
            for c in commits:
                short = c["sha"][:8]
                lines.append(f"- `{short}` {c['subject']}")
        files = r.get("files_changed", [])
        if files:
            lines.append("")
            lines.append(f"Files changed ({len(files)}):")
            for f in files:
                lines.append(f"- `{f}`")
        lines.append("")

    return "\n".join(lines) + "\n"


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: git-delta.py {collect|render} [<task-folder>]", file=sys.stderr)
        return 2

    cmd = argv[1]

    if cmd == "collect":
        if len(argv) < 3:
            print("usage: git-delta.py collect <task-folder>", file=sys.stderr)
            return 2
        task_folder = Path(argv[2]).resolve()
        if not task_folder.is_dir():
            print(f"git-delta: not a directory: {task_folder}", file=sys.stderr)
            return 1
        data = collect(task_folder)
        json.dump(data, sys.stdout)
        sys.stdout.write("\n")
        return 0

    if cmd == "render":
        summary = ""
        # Parse optional --summary-file <path>.
        rest = argv[2:]
        i = 0
        while i < len(rest):
            if rest[i] == "--summary-file" and i + 1 < len(rest):
                summary_path = Path(rest[i + 1])
                if summary_path.is_file():
                    summary = summary_path.read_text()
                i += 2
            else:
                print(f"git-delta: unexpected arg: {rest[i]}", file=sys.stderr)
                return 2
        try:
            data = json.load(sys.stdin)
        except json.JSONDecodeError as exc:
            print(f"git-delta: invalid JSON on stdin: {exc}", file=sys.stderr)
            return 1
        sys.stdout.write(render(data, summary=summary))
        return 0

    print(f"git-delta: unknown subcommand: {cmd}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
