# Tests

Shell-level tests for eddy's helper scripts under `.claude/hooks/`.

## Setup

Install [bats-core](https://github.com/bats-core/bats-core) 1.x:

```sh
brew install bats-core           # macOS
npm install -g bats              # cross-platform alternative
```

Python 3 (stdlib only) is required for the scripts under test. No other
dependencies.

## Run

From the repo root:

```sh
bats tests/                      # all test files
bats tests/journal-ops.bats      # one file
```

Add `--print-output-on-failure` to see stdout/stderr from failing cases.

## Layout

| Path                          | What it covers                                         |
|-------------------------------|--------------------------------------------------------|
| `tests/journal-ops.bats`      | Module A — state rewrite + log append + last-log       |
| `tests/git-delta.bats`        | Module B — git delta collect + render                  |
| `tests/session-end.bats`      | Integration — SessionEnd hook end-to-end               |
| `tests/session-start.bats`    | Integration — SessionStart hook end-to-end             |
| `tests/fixtures/`             | Sample `JOURNAL.md` files used by the tests            |

## Writing tests

`bats` does NOT bail on `[[ ... ]]` conditional failures — use `grep -q`,
`diff`, or `[ ... ]` for assertions that must fail the test. The
`contains` / `not_contains` helpers in `journal-ops.bats` are safe
patterns to copy.
