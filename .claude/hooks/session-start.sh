#!/usr/bin/env bash
# Claude Code SessionStart hook for eddy task folders.
#
# On session start, if the CWD has a JOURNAL.md, emit a resume brief as
# the hook's additional context: current journal state + last 3 log
# entries + open todos from the workflow repo's running.md filtered to
# this task's workstream.
#
# The hook writes a JSON object to stdout using Claude Code's
# `hookSpecificOutput.additionalContext` contract. Exits 0 with no
# output when there's nothing useful to say.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_REPO="$(cd "${HOOK_DIR}/../.." && pwd)"
TASK_FOLDER="$PWD"
JOURNAL="${TASK_FOLDER}/JOURNAL.md"
RUNNING="${WORKFLOW_REPO}/notes/todos/running.md"

if [ ! -f "$JOURNAL" ]; then
  exit 0
fi

# Drain any stdin payload — Claude Code may send JSON here.
if [ ! -t 0 ]; then
  cat > /dev/null
fi

# Workstream from the journal's frontmatter.
workstream="$(
  awk '
    BEGIN { in_fm = 0 }
    /^---[[:space:]]*$/ {
      if (in_fm == 0) { in_fm = 1; next }
      else { exit }
    }
    in_fm == 1 && /^workstream:/ {
      sub(/^workstream:[[:space:]]*/, "", $0)
      print $0
      exit
    }
  ' "$JOURNAL"
)"

STATE="$("${HOOK_DIR}/journal-ops.py" read-state "$JOURNAL")"
RECENT="$("${HOOK_DIR}/journal-ops.py" last-log "$JOURNAL" 3)"

TODOS=""
if [ -n "$workstream" ] && [ -f "$RUNNING" ]; then
  # Match unchecked items whose inline `workstream: <ws>` field equals
  # the journal's workstream. Case-sensitive substring is sufficient
  # given eddy's kebab-case workstream convention.
  TODOS="$(
    grep -E '^- \[ \]' "$RUNNING" 2>/dev/null \
      | grep -F "workstream: ${workstream}" \
      || true
  )"
fi

# Compose the brief as markdown.
brief=""
brief+="## Resume: $(basename "$TASK_FOLDER")"$'\n'
if [ -n "$workstream" ]; then
  brief+="Workstream: **${workstream}**"$'\n'
fi
brief+=$'\n'

if [ -n "$STATE" ]; then
  brief+="### Journal state"$'\n'$'\n'
  brief+="${STATE}"$'\n'
fi

if [ -n "$RECENT" ]; then
  brief+=$'\n'"### Recent journal log (last 3)"$'\n'$'\n'
  brief+="${RECENT}"$'\n'
fi

if [ -n "$TODOS" ]; then
  brief+=$'\n'"### Open todos for this workstream"$'\n'$'\n'
  brief+="${TODOS}"$'\n'
fi

# Emit the Claude Code SessionStart hook contract.
python3 - "$brief" <<'PY'
import json, sys
brief = sys.argv[1]
payload = {
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": brief,
    }
}
json.dump(payload, sys.stdout)
sys.stdout.write("\n")
PY
