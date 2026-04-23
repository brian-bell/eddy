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
