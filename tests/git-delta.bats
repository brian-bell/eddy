#!/usr/bin/env bats

# Tests for Module B: git delta collector.
# Exercises .claude/hooks/git-delta.py collect via its CLI.

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  DELTA="${REPO_ROOT}/.claude/hooks/git-delta.py"
  TASK="$(mktemp -d)"

  # Git config so commits don't warn in CI-like environments.
  export GIT_AUTHOR_NAME="Test"
  export GIT_AUTHOR_EMAIL="test@example.com"
  export GIT_COMMITTER_NAME="Test"
  export GIT_COMMITTER_EMAIL="test@example.com"
}

teardown() {
  rm -rf "$TASK"
}

mkrepo() {
  # mkrepo <name> — init a git repo with one initial commit
  local name="$1"
  local dir="${TASK}/${name}"
  mkdir -p "$dir"
  git -C "$dir" init -q -b main
  echo "initial" > "${dir}/README.md"
  git -C "$dir" add README.md
  git -C "$dir" commit -q -m "initial commit"
}

@test "collect on task folder with no repos emits empty repos array" {
  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['repos']==[], d"
}

@test "collect on new repo (no prior state) baselines and reports no commits" {
  mkrepo foo
  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
repos = {r['name']: r for r in d['repos']}
r = repos['foo']
assert r['new_repo'] is True, r
assert r['commits_since_last'] == [], r
assert r['files_changed'] == [], r
assert r['branch'] == 'main', r
"
  # A state file should now exist so the next run has a baseline.
  [ -f "${TASK}/.claude/journal-state/foo.last-ref" ]
}

@test "collect after new commit reports the commit + files changed" {
  mkrepo foo
  # Baseline.
  "$DELTA" collect "$TASK" > /dev/null

  echo "change" >> "${TASK}/foo/README.md"
  echo "new" > "${TASK}/foo/NOTES.md"
  git -C "${TASK}/foo" add -A
  git -C "${TASK}/foo" commit -q -m "add notes, update readme"

  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = {x['name']: x for x in d['repos']}['foo']
assert r['new_repo'] is False, r
assert len(r['commits_since_last']) == 1, r
assert r['commits_since_last'][0]['subject'] == 'add notes, update readme', r
assert set(r['files_changed']) == {'README.md', 'NOTES.md'}, r
assert r['file_change_count'] == 2, r
"
}

@test "collect with no commits since last run reports zero delta" {
  mkrepo foo
  "$DELTA" collect "$TASK" > /dev/null
  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = {x['name']: x for x in d['repos']}['foo']
assert r['new_repo'] is False, r
assert r['commits_since_last'] == [], r
assert r['files_changed'] == [], r
"
}

@test "collect handles detached HEAD" {
  mkrepo foo
  # Add a second commit, then detach to the first.
  echo "two" >> "${TASK}/foo/README.md"
  git -C "${TASK}/foo" commit -q -am "second"
  FIRST_SHA=$(git -C "${TASK}/foo" rev-list --max-parents=0 HEAD)
  git -C "${TASK}/foo" checkout -q "$FIRST_SHA"

  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = {x['name']: x for x in d['repos']}['foo']
assert r['branch'] in ('HEAD', '(detached)'), r
"
}

@test "collect handles repo added mid-task (new repo in second run)" {
  mkrepo foo
  "$DELTA" collect "$TASK" > /dev/null

  # Second run after adding a new repo.
  mkrepo bar
  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
repos = {r['name']: r for r in d['repos']}
assert repos['foo']['new_repo'] is False, repos
assert repos['bar']['new_repo'] is True, repos
"
}

@test "collect skips non-git directories" {
  mkrepo foo
  mkdir -p "${TASK}/notes"
  echo "text" > "${TASK}/notes/stuff.md"

  run "$DELTA" collect "$TASK"
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import sys, json
d = json.load(sys.stdin)
names = sorted(r['name'] for r in d['repos'])
assert names == ['foo'], names
"
}

@test "render takes delta JSON on stdin and produces a markdown entry" {
  mkrepo foo
  "$DELTA" collect "$TASK" > /dev/null
  echo "x" >> "${TASK}/foo/README.md"
  git -C "${TASK}/foo" commit -q -am "tweak readme"

  json="$("$DELTA" collect "$TASK")"
  run bash -c "echo '$json' | '$DELTA' render"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qF "[session]"
  echo "$output" | grep -qF "foo"
  echo "$output" | grep -qF "tweak readme"
  echo "$output" | grep -qF "README.md"
}

@test "render on empty repos list still produces a valid entry" {
  json='{"task_folder": "'"$TASK"'", "generated_at": "2026-04-22T00:00:00Z", "repos": []}'
  run bash -c "echo '$json' | '$DELTA' render"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qF "[session]"
}
