#!/usr/bin/env bash
# Module C — session transcript summarizer.
#
# Wraps `claude -p` to turn a Claude Code session transcript into a 2–3
# sentence summary focused on decisions, attempts, and next steps. Used
# by session-end.sh to fill the **Session summary** block of [session]
# journal entries.
#
# Usage:
#   summarize-transcript.sh <transcript-path>
#
# Exits 0 and prints the summary to stdout on success. Exits non-zero
# with an empty stdout on any failure (missing file, missing claude CLI,
# non-zero exit from claude -p, timeout). session-end.sh treats a
# failure here as "no summary available" and still writes the git-delta
# portion of the entry.

TRANSCRIPT="${1:-}"

if [ -z "$TRANSCRIPT" ] || [ ! -r "$TRANSCRIPT" ]; then
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  exit 1
fi

PROMPT='Summarize this Claude Code session transcript in 2-3 sentences. Focus on: (1) what was attempted or decided, (2) any dead ends or pivots, (3) what is explicitly left for next session. Do not recap file names or commands. Write plainly; no preamble like "In this session".'

# Pipe the transcript (JSONL) as stdin to `claude -p`. Guard against
# unbounded latency with a timeout — if the summarizer takes more than
# 60s the hook should still finish writing the delta portion.
if command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT=(gtimeout 60)
elif command -v timeout >/dev/null 2>&1; then
  TIMEOUT=(timeout 60)
else
  TIMEOUT=()
fi

"${TIMEOUT[@]}" claude -p "$PROMPT" < "$TRANSCRIPT"
