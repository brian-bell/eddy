#!/usr/bin/env bats

# Integration tests for .claude/hooks/session-start.sh.

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  HOOK="${REPO_ROOT}/.claude/hooks/session-start.sh"
  TEMPLATE="${REPO_ROOT}/notes/templates/journal.md"
  TASK="$(mktemp -d)"
}

teardown() {
  rm -rf "$TASK"
}

make_journal() {
  # make_journal <workstream>
  cp "$TEMPLATE" "${TASK}/JOURNAL.md"
  # Substitute workstream placeholder.
  python3 - "${TASK}/JOURNAL.md" "$1" <<'PY'
import sys
path, ws = sys.argv[1], sys.argv[2]
text = open(path).read().replace("{{workstream}}", ws)
open(path, "w").write(text)
PY
}

@test "session-start no-ops when JOURNAL.md is absent" {
  bare="$(mktemp -d)"
  run bash -c "(cd '$bare' && '$HOOK' < /dev/null)"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  rmdir "$bare"
}

@test "session-start emits a JSON payload with journal state when present" {
  make_journal "platform-auth"

  # Write in a real state section so read-state returns content.
  new_state=$(cat <<'EOF'
## Current State
Hacking on the refresh token path.

## Next Steps
- Repro the race

## Open Questions

## Blockers
EOF
)
  printf '%s\n' "$new_state" | "${REPO_ROOT}/.claude/hooks/journal-ops.py" write-state "${TASK}/JOURNAL.md"

  # Append a log entry so recent-log output is non-empty.
  printf '### [checkpoint] 2026-04-22T10:00:00Z — set up repro harness\n\nBuilt a script.\n' \
    | "${REPO_ROOT}/.claude/hooks/journal-ops.py" append-log "${TASK}/JOURNAL.md"

  run bash -c "(cd '$TASK' && '$HOOK' < /dev/null)"
  [ "$status" -eq 0 ]
  # Output must be parseable JSON with additionalContext.
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
assert d['hookSpecificOutput']['hookEventName'] == 'SessionStart', d
ctx = d['hookSpecificOutput']['additionalContext']
assert 'Hacking on the refresh token path.' in ctx, ctx
assert 'set up repro harness' in ctx, ctx
assert 'platform-auth' in ctx, ctx
"
}

@test "session-start filters running.md by the journal's workstream" {
  make_journal "platform-auth"

  # Stage a fake workflow repo layout for RUNNING=.../notes/todos/running.md.
  # Hook resolves WORKFLOW_REPO from its own path, so running.md must live
  # in this repo's actual notes/ for the hook to find it. We add entries
  # then remove them in teardown.
  running="${REPO_ROOT}/notes/todos/running.md"
  mkdir -p "$(dirname "$running")"
  cat > "$running" <<'RM'
- [ ] Match me — workstream: platform-auth | added: 2026-04-20
- [ ] Not me — workstream: other-stream | added: 2026-04-20
- [x] Completed irrelevant — workstream: platform-auth | added: 2026-04-15
RM

  run bash -c "(cd '$TASK' && '$HOOK' < /dev/null)"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ctx = d['hookSpecificOutput']['additionalContext']
assert 'Match me' in ctx, ctx
assert 'Not me' not in ctx, ctx
assert 'Completed irrelevant' not in ctx, ctx
"

  rm -f "$running"
}

@test "session-start tolerates JSON payload on stdin" {
  make_journal "demo"
  payload='{"session_id":"abc","source":"startup"}'
  run bash -c "(cd '$TASK' && printf '%s' '$payload' | '$HOOK')"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
assert d['hookSpecificOutput']['hookEventName'] == 'SessionStart'
"
}
