#!/usr/bin/env bash
# Claude Code SessionEnd hook for eddy task folders.
#
# On session end, if the CWD has a JOURNAL.md:
#   1. Collect a git delta across child repos (Module B).
#   2. Unless the `journal_session_summary` config knob is off, generate
#      a 2–3 sentence LLM summary from the session transcript (Module C).
#   3. Render a [session] markdown entry (Module B render).
#   4. Append it to JOURNAL.md (Module A).
#
# Reads the hook payload (JSON) from stdin to extract `transcript_path`
# for the summary step. Everything but step 1 is best-effort; failures
# fall back to a git-delta-only entry.

set -u

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_REPO="$(cd "${HOOK_DIR}/../.." && pwd)"
TASK_FOLDER="$PWD"
JOURNAL="${TASK_FOLDER}/JOURNAL.md"
CONFIG="${WORKFLOW_REPO}/config.md"

if [ ! -f "$JOURNAL" ]; then
  exit 0
fi

# Read hook payload JSON (may be empty if invoked manually).
PAYLOAD=""
if [ ! -t 0 ]; then
  PAYLOAD="$(cat)"
fi

# Resolve the journal_session_summary config knob. Default: on.
# Parses a line like "- **Session Summary:** on" under "## Task Journal".
summary_enabled="on"
if [ -f "$CONFIG" ]; then
  line="$(grep -iE '^- \*\*Session Summary:\*\*' "$CONFIG" 2>/dev/null | head -1 || true)"
  if [ -n "$line" ]; then
    val="$(printf '%s' "$line" | sed -E 's/^- \*\*Session Summary:\*\*[[:space:]]*//; s/[[:space:]]*<!--.*-->.*$//; s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')"
    case "$val" in
      off|false|no|0) summary_enabled="off" ;;
    esac
  fi
fi

DELTA_JSON="$("${HOOK_DIR}/git-delta.py" collect "$TASK_FOLDER")"

SUMMARY_FILE=""
if [ "$summary_enabled" = "on" ] && [ -n "$PAYLOAD" ]; then
  TRANSCRIPT_PATH="$(
    printf '%s' "$PAYLOAD" \
      | python3 -c 'import json,sys
try:
  d=json.load(sys.stdin)
  print(d.get("transcript_path",""))
except Exception:
  pass' 2>/dev/null
  )"
  if [ -n "$TRANSCRIPT_PATH" ] && [ -r "$TRANSCRIPT_PATH" ]; then
    SUMMARY_FILE="$(mktemp)"
    if ! "${HOOK_DIR}/summarize-transcript.sh" "$TRANSCRIPT_PATH" > "$SUMMARY_FILE" 2>/dev/null; then
      rm -f "$SUMMARY_FILE"
      SUMMARY_FILE=""
    fi
  fi
fi

if [ -n "$SUMMARY_FILE" ]; then
  ENTRY="$(printf '%s' "$DELTA_JSON" | "${HOOK_DIR}/git-delta.py" render --summary-file "$SUMMARY_FILE")"
  rm -f "$SUMMARY_FILE"
else
  ENTRY="$(printf '%s' "$DELTA_JSON" | "${HOOK_DIR}/git-delta.py" render)"
fi

printf '%s' "$ENTRY" | "${HOOK_DIR}/journal-ops.py" append-log "$JOURNAL"
