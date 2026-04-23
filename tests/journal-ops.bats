#!/usr/bin/env bats

# Tests for Module A: journal file operations.
# Exercises .claude/hooks/journal-ops.py via its CLI.
#
# Note: bats does NOT bail on `[[ ... ]]` returning false. Use `grep -q`
# or `[ ... ]` for assertions that must fail the test.

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  OPS="${REPO_ROOT}/.claude/hooks/journal-ops.py"
  FIXTURES="${REPO_ROOT}/tests/fixtures"
  WORK="$(mktemp -d)"
}

teardown() {
  rm -rf "$WORK"
}

contains() {
  # contains <file> <substring>
  grep -qF -- "$2" "$1"
}

not_contains() {
  ! grep -qF -- "$2" "$1"
}

@test "read-state on populated journal returns the four state sections" {
  run "$OPS" read-state "${FIXTURES}/journal-populated.md"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qF "## Current State"
  echo "$output" | grep -qF "Investigating the token-refresh race condition."
  echo "$output" | grep -qF "## Next Steps"
  echo "$output" | grep -qF "## Open Questions"
  echo "$output" | grep -qF "## Blockers"
  # Must not leak the ## Log section or its entries.
  ! echo "$output" | grep -qF "## Log"
  ! echo "$output" | grep -qF "initial exploration"
}

@test "read-state on frontmatter-only journal returns empty output" {
  run "$OPS" read-state "${FIXTURES}/journal-frontmatter-only.md"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "write-state rewrites state sections in place, preserving frontmatter and log" {
  cp "${FIXTURES}/journal-populated.md" "${WORK}/j.md"
  printf '## Current State\nRewritten — now in green-path.\n\n## Next Steps\n- Ship it.\n\n## Open Questions\n\n## Blockers\n' \
    | "$OPS" write-state "${WORK}/j.md"

  # Frontmatter preserved.
  contains "${WORK}/j.md" "type: task-journal"
  contains "${WORK}/j.md" "task: fix-auth-timeout"
  contains "${WORK}/j.md" "created: 2026-04-20"
  # Intro prose preserved.
  contains "${WORK}/j.md" "# Journal: fix-auth-timeout"
  contains "${WORK}/j.md" "Intro prose is preserved."
  # Old state content replaced.
  not_contains "${WORK}/j.md" "token-refresh race condition"
  # New state content landed.
  contains "${WORK}/j.md" "Rewritten — now in green-path."
  contains "${WORK}/j.md" "- Ship it."
  # Log section preserved verbatim (including its entries).
  contains "${WORK}/j.md" "## Log"
  contains "${WORK}/j.md" "initial exploration"
  contains "${WORK}/j.md" "narrowed to token-refresh"
}

@test "write-state on frontmatter-only journal inserts state and log sections" {
  cp "${FIXTURES}/journal-frontmatter-only.md" "${WORK}/j.md"
  printf '## Current State\nHello.\n\n## Next Steps\n\n## Open Questions\n\n## Blockers\n' \
    | "$OPS" write-state "${WORK}/j.md"

  contains "${WORK}/j.md" "type: task-journal"
  contains "${WORK}/j.md" "## Current State"
  contains "${WORK}/j.md" "Hello."
  contains "${WORK}/j.md" "## Log"
}

@test "write-state is idempotent — same input produces same output" {
  cp "${FIXTURES}/journal-populated.md" "${WORK}/j.md"
  printf '## Current State\nIdempotent.\n\n## Next Steps\n\n## Open Questions\n\n## Blockers\n' \
    | "$OPS" write-state "${WORK}/j.md"
  cp "${WORK}/j.md" "${WORK}/after-first.md"
  printf '## Current State\nIdempotent.\n\n## Next Steps\n\n## Open Questions\n\n## Blockers\n' \
    | "$OPS" write-state "${WORK}/j.md"
  diff "${WORK}/after-first.md" "${WORK}/j.md"
}

@test "append-log appends a new entry to existing Log section" {
  cp "${FIXTURES}/journal-populated.md" "${WORK}/j.md"
  printf '### [checkpoint] 2026-04-22T11:00:00Z — new entry\n\nThis is the body.\n' \
    | "$OPS" append-log "${WORK}/j.md"

  # Prior entries preserved.
  contains "${WORK}/j.md" "initial exploration"
  contains "${WORK}/j.md" "narrowed to token-refresh"
  # New entry appended.
  contains "${WORK}/j.md" "new entry"
  contains "${WORK}/j.md" "This is the body."
  # Newest entry is at the bottom.
  tail -c 300 "${WORK}/j.md" | grep -qF "This is the body."
}

@test "append-log on empty Log section appends without doubling the header" {
  cp "${FIXTURES}/journal-empty-log.md" "${WORK}/j.md"
  printf '### [checkpoint] 2026-04-22T11:00:00Z — first\n\nBody.\n' \
    | "$OPS" append-log "${WORK}/j.md"

  # Exactly one ## Log heading.
  log_count=$(grep -c '^## Log' "${WORK}/j.md")
  [ "$log_count" -eq 1 ]
  contains "${WORK}/j.md" "[checkpoint] 2026-04-22T11:00:00Z — first"
}

@test "append-log creates Log section if missing" {
  cp "${FIXTURES}/journal-no-log-section.md" "${WORK}/j.md"
  printf '### [session] 2026-04-22T11:00:00Z — first session\n\nCaptured.\n' \
    | "$OPS" append-log "${WORK}/j.md"

  log_count=$(grep -c '^## Log' "${WORK}/j.md")
  [ "$log_count" -eq 1 ]
  contains "${WORK}/j.md" "first session"
  contains "${WORK}/j.md" "Captured."
}

@test "append-log does not touch frontmatter or other sections" {
  cp "${FIXTURES}/journal-populated.md" "${WORK}/j.md"
  before_head="$(head -n 6 "${WORK}/j.md")"
  printf '### [session] 2026-04-22T12:00:00Z — later\n\nMore.\n' \
    | "$OPS" append-log "${WORK}/j.md"
  after_head="$(head -n 6 "${WORK}/j.md")"
  [ "$before_head" = "$after_head" ]

  contains "${WORK}/j.md" "token-refresh race condition"
  contains "${WORK}/j.md" "Reproduce with the repro script"
}

@test "append-log on frontmatter-only file creates Log section and writes entry" {
  cp "${FIXTURES}/journal-frontmatter-only.md" "${WORK}/j.md"
  printf '### [session] 2026-04-22T12:00:00Z — first\n\nEntry.\n' \
    | "$OPS" append-log "${WORK}/j.md"

  contains "${WORK}/j.md" "type: task-journal"
  contains "${WORK}/j.md" "## Log"
  contains "${WORK}/j.md" "Entry."
}

@test "last-log returns the last N entries including their body" {
  run "$OPS" last-log "${FIXTURES}/journal-populated.md" 1
  [ "$status" -eq 0 ]
  echo "$output" | grep -qF "narrowed to token-refresh"
  echo "$output" | grep -qF "Confirmed the race is in refresh"
  # Earlier entry must NOT be in the output.
  ! echo "$output" | grep -qF "initial exploration"
}

@test "last-log with N greater than entry count returns all entries" {
  run "$OPS" last-log "${FIXTURES}/journal-populated.md" 10
  [ "$status" -eq 0 ]
  echo "$output" | grep -qF "initial exploration"
  echo "$output" | grep -qF "narrowed to token-refresh"
}

@test "last-log on journal with no entries returns empty output" {
  run "$OPS" last-log "${FIXTURES}/journal-empty-log.md" 3
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
