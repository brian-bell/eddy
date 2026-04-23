#!/usr/bin/env bash
# Claude Code SessionEnd hook for eddy task folders.
#
# On session end, if the CWD has a JOURNAL.md:
#   1. Collect a git delta across child repos (Module B).
#   2. Render it to markdown.
#   3. Append a [session] log entry via journal-ops (Module A).
#
# The hook payload on stdin is currently unused. Slice 4 of PRD #28 will
# read the transcript path from it to add an LLM summary.

set -e

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_FOLDER="$PWD"
JOURNAL="${TASK_FOLDER}/JOURNAL.md"

# No journal here → nothing to do. Exit cleanly so the hook is safe to
# scaffold into any folder (though /new-task only scaffolds it into
# folders that already have JOURNAL.md).
if [ ! -f "$JOURNAL" ]; then
  exit 0
fi

# Drain any stdin payload — Claude Code writes JSON here. We don't need
# it yet, but we must not leave it unread if the hook runner is strict.
if [ ! -t 0 ]; then
  cat > /dev/null
fi

DELTA_JSON="$("${HOOK_DIR}/git-delta.py" collect "$TASK_FOLDER")"
ENTRY="$(printf '%s' "$DELTA_JSON" | "${HOOK_DIR}/git-delta.py" render)"
printf '%s' "$ENTRY" | "${HOOK_DIR}/journal-ops.py" append-log "$JOURNAL"
