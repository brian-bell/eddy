#!/usr/bin/env bats

# Integration smoke for .claude/hooks/session-end.sh.
# Runs the hook in a temp task folder with a JOURNAL.md and a child
# repo, asserts a [session] entry lands in the journal.

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  HOOK="${REPO_ROOT}/.claude/hooks/session-end.sh"
  TEMPLATE="${REPO_ROOT}/notes/templates/journal.md"
  TASK="$(mktemp -d)"

  export GIT_AUTHOR_NAME="Test"
  export GIT_AUTHOR_EMAIL="test@example.com"
  export GIT_COMMITTER_NAME="Test"
  export GIT_COMMITTER_EMAIL="test@example.com"

  cp "$TEMPLATE" "${TASK}/JOURNAL.md"
}

teardown() {
  rm -rf "$TASK"
}

@test "session-end no-ops when JOURNAL.md is absent" {
  bare="$(mktemp -d)"
  (cd "$bare" && "$HOOK" < /dev/null)
  rmdir "$bare"
}

@test "session-end appends a [session] entry with git delta" {
  mkdir -p "${TASK}/foo"
  git -C "${TASK}/foo" init -q -b main
  echo "hello" > "${TASK}/foo/README.md"
  git -C "${TASK}/foo" add README.md
  git -C "${TASK}/foo" commit -q -m "initial"

  # First run: baselines the repo (new_repo=true, no commits reported).
  (cd "$TASK" && "$HOOK" < /dev/null)

  # Make a commit, run again — this time we should see the commit.
  echo "change" >> "${TASK}/foo/README.md"
  git -C "${TASK}/foo" commit -q -am "add change line"

  (cd "$TASK" && "$HOOK" < /dev/null)

  grep -qF "[session]" "${TASK}/JOURNAL.md"
  grep -qF "add change line" "${TASK}/JOURNAL.md"
  grep -qF "foo" "${TASK}/JOURNAL.md"
}

@test "session-end tolerates JSON on stdin without crashing" {
  mkdir -p "${TASK}/foo"
  git -C "${TASK}/foo" init -q -b main
  echo "hello" > "${TASK}/foo/README.md"
  git -C "${TASK}/foo" add README.md
  git -C "${TASK}/foo" commit -q -m "initial"

  payload='{"session_id":"abc","transcript_path":"/tmp/t.jsonl"}'
  (cd "$TASK" && printf '%s' "$payload" | "$HOOK")

  grep -qF "[session]" "${TASK}/JOURNAL.md"
}

@test "session-end falls back to delta-only entry when summary is unavailable" {
  # No `claude` CLI on PATH in the test environment → summarize-transcript.sh
  # exits non-zero → hook should still produce a delta entry.
  mkdir -p "${TASK}/foo"
  git -C "${TASK}/foo" init -q -b main
  echo "hi" > "${TASK}/foo/README.md"
  git -C "${TASK}/foo" add README.md
  git -C "${TASK}/foo" commit -q -m "bootstrap"

  # Point at a real transcript so the hook tries the summary path.
  transcript="$(mktemp)"
  echo '{"role":"user","content":"hi"}' > "$transcript"

  payload='{"session_id":"abc","transcript_path":"'"$transcript"'"}'
  (cd "$TASK" && PATH=/usr/bin:/bin printf '%s' "$payload" | "$HOOK") || true

  grep -qF "[session]" "${TASK}/JOURNAL.md"
  grep -qF "foo" "${TASK}/JOURNAL.md"
  # No **Session summary** section (claude not available).
  ! grep -qF "**Session summary**" "${TASK}/JOURNAL.md"

  rm -f "$transcript"
}

@test "session-end includes LLM summary when knob is on and claude is available" {
  # Stub `claude` on PATH so the test doesn't need the real CLI.
  BIN="$(mktemp -d)"
  cat > "${BIN}/claude" <<'SH'
#!/usr/bin/env bash
cat > /dev/null
echo "STUB_SUMMARY_LINE decided to stop after probing the race."
SH
  chmod +x "${BIN}/claude"

  mkdir -p "${TASK}/foo"
  git -C "${TASK}/foo" init -q -b main
  echo "hi" > "${TASK}/foo/README.md"
  git -C "${TASK}/foo" add README.md
  git -C "${TASK}/foo" commit -q -m "bootstrap"

  transcript="$(mktemp)"
  echo '{"role":"user","content":"hi"}' > "$transcript"
  payload='{"transcript_path":"'"$transcript"'"}'

  (cd "$TASK" && export PATH="${BIN}:$PATH" && printf '%s' "$payload" | "$HOOK")

  grep -qF "STUB_SUMMARY_LINE" "${TASK}/JOURNAL.md"
  grep -qF "**Session summary**" "${TASK}/JOURNAL.md"

  rm -rf "$BIN" "$transcript"
}

@test "session-end honors Session Summary: off in config.md" {
  BIN="$(mktemp -d)"
  cat > "${BIN}/claude" <<'SH'
#!/usr/bin/env bash
cat > /dev/null
echo "STUB_SUMMARY_LINE should not appear"
SH
  chmod +x "${BIN}/claude"

  # Point at a repo-shaped config with the knob off.
  CFG_ROOT="$(mktemp -d)"
  mkdir -p "${CFG_ROOT}/.claude"
  cp "${REPO_ROOT}/.claude/hooks/journal-ops.py" "${CFG_ROOT}/.claude/"
  cp "${REPO_ROOT}/.claude/hooks/git-delta.py" "${CFG_ROOT}/.claude/"
  cp "${REPO_ROOT}/.claude/hooks/summarize-transcript.sh" "${CFG_ROOT}/.claude/"
  cp "${REPO_ROOT}/.claude/hooks/session-end.sh" "${CFG_ROOT}/.claude/"
  mkdir -p "${CFG_ROOT}/.claude/hooks"
  mv "${CFG_ROOT}/.claude/journal-ops.py" "${CFG_ROOT}/.claude/hooks/"
  mv "${CFG_ROOT}/.claude/git-delta.py" "${CFG_ROOT}/.claude/hooks/"
  mv "${CFG_ROOT}/.claude/summarize-transcript.sh" "${CFG_ROOT}/.claude/hooks/"
  mv "${CFG_ROOT}/.claude/session-end.sh" "${CFG_ROOT}/.claude/hooks/"
  chmod +x "${CFG_ROOT}/.claude/hooks/"*
  cat > "${CFG_ROOT}/config.md" <<'CFG'
# Configuration

## Task Journal
- **Session Summary:** off
CFG
  TASK2="${CFG_ROOT}/task"
  mkdir -p "$TASK2"
  cp "${REPO_ROOT}/notes/templates/journal.md" "${TASK2}/JOURNAL.md"
  mkdir -p "${TASK2}/foo"
  git -C "${TASK2}/foo" init -q -b main
  echo "hi" > "${TASK2}/foo/README.md"
  git -C "${TASK2}/foo" add README.md
  git -C "${TASK2}/foo" commit -q -m "bootstrap"

  transcript="$(mktemp)"
  echo '{"role":"user","content":"hi"}' > "$transcript"
  payload='{"transcript_path":"'"$transcript"'"}'

  (cd "$TASK2" && export PATH="${BIN}:$PATH" && printf '%s' "$payload" | "${CFG_ROOT}/.claude/hooks/session-end.sh")

  grep -qF "[session]" "${TASK2}/JOURNAL.md"
  ! grep -qF "STUB_SUMMARY_LINE" "${TASK2}/JOURNAL.md"
  ! grep -qF "**Session summary**" "${TASK2}/JOURNAL.md"

  rm -rf "$BIN" "$CFG_ROOT" "$transcript"
}
