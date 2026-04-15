# Eddy Roadmap

Plan for aligning eddy with the daily operating guide — a workflow built around time-blocked days, a single curated running todo list, workstreams as doc-of-docs, and weekly Review → Reflect → Refine.

## Principles we're aligning to

- **Single running todo list**, curated daily, categorized by source (help-request, followup, meeting-action, self).
- **Help the right people more** — team + key stakeholders' requests rank first.
- **Workstreams are doc-of-docs**, not progress trackers.
- **Time budget is reported, not enforced** — 5 named blocks (Admin / PR / Meetings / Hands On / Slack), weekly targets of 10h hands-on and 7.5h support.
- **Friday Ritual** — Review → Reflect → Refine closes the week.
- **P1 interrupts subtract in order** — Slack → Meetings → Hands On (last resort).

## Out of scope (for now)

- On-call mode.
- Any hard enforcement of the time budget — reporting only.
- WIP / multitasking signals (deferred to D3).

## Phases

Each phase lists t-shirt effort (S/M/L) and an ICE score (Impact × Confidence × Ease, each 1–10).

### Phase A — Schema foundations

| ID | Item | Effort | ICE |
|---|---|---|---|
| A1 | Collapse todos to a single running list | M | 360 |
| A2 | Tighten workstream format to doc-of-docs | S | 360 |

**A1 — Collapse todos to a single running list.**
Move to `notes/todos/running.md` with per-item inline fields (workstream, source, added, stakeholder). Retire per-stream todo files; migrate existing items.
Touches: `todo` template, `vault-conventions.md`, `workstream-format.md`, `/new-task`, `/daily-plan`, `/whats-next`, `/recap`.

**A2 — Tighten workstream format to doc-of-docs.**
Drop `## Tasks` from `workstream-format.md` and the workstream template. Rename to `## Links & Context` (notes, screenshots, decisions). Update `/new-task` to stop linking tasks into workstream files.

### Phase B — Classification (enables "right people first")

| ID | Item | Effort | ICE |
|---|---|---|---|
| B1 | Source-type axis on todos | M | 378 |
| B2 | Key-stakeholders in `config.md` | S | 504 |

**B1 — Source-type axis on todos.**
Add `source: help-request | followup | meeting-action | self` per item, plus optional `from: @person`. Propagate through `/new-task`, `/ingest`, and the `/my-prs` review-feedback flow.

**B2 — Key-stakeholders in `config.md`.**
New `stakeholders:` list (team + key stakeholders). `/whats-next` and `/daily-plan` boost help-requests from this set to the top, reifying North Star #1.
*Highest-leverage small change — do first.*

### Phase C — Rituals (use the data)

| ID | Item | Effort | ICE |
|---|---|---|---|
| C1 | Time-budget reporting | M | 240 |
| C2 | Friday Ritual — extend `/recap weekly` | S | 392 |
| C3 | `/replan` for P1 interrupts | M | 343 |

**C1 — Time-budget reporting.**
`/daily-plan`: classify each item into one of the 5 blocks and show estimated hours per block next to the guide's budget. `/recap daily`: tally completed hours by block. `/recap weekly`: roll up vs 10h hands-on / 7.5h support. Report-only.

**C2 — Friday Ritual — extend `/recap weekly`.**
Add Review → Reflect → Refine structure:
- **Review** — hours vs target, shipped work, help given.
- **Reflect** — prompts tied to the three north stars.
- **Refine** — interactive prune of stale workstreams and running-list items.

**C3 — `/replan` for P1 interrupts.**
Takes a P1 description, re-draws today's plan subtracting in guide order (Slack → Meetings where possible → Hands On last), and logs the trade-off to the daily log.

### Phase D — Nice-to-have

| ID | Item | Effort | ICE |
|---|---|---|---|
| D1 | `/ingest` meeting mode | S | 294 |
| D2 | Metrics cue in `/daily-plan` admin block | XS | 288 |
| D3 | WIP-count warning in `/whats-next` | S | 210 |

**D1 — `/ingest` meeting mode.** Read the last-ended calendar event, prompt for decisions + action items, route actions into the running list with `source: meeting-action`.

**D2 — Metrics cue in `/daily-plan` admin block.** Surface dashboard links from a new `metrics_dashboards:` config field and ask "reviewed?". No tracking.

**D3 — WIP-count warning in `/whats-next`.** Count simultaneous in-progress items; warn if >1, tied to North Star #2 ("stop doing multiple things at once").

## Recommended build order

B2 → A1 → A2 → B1 → C2 → C3 → C1 → D1 → D2 → D3.

- **B2** is a one-line config change with the highest ICE — ship today.
- **A1 / A2** unblock everything downstream; do them before behavior changes.
- **B1** is the largest-impact behavior change; precede the rituals that use it.
- **C2** comes before **C1** because it's self-contained and gives the Friday loop immediately; C1 adds hours data that C2 can fold in later.
