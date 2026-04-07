---
name: idea
description: Capture an idea into the vault with auto-inferred metadata and related idea linking
---

# Idea

Capture an idea — a feature, tool, process, or anything else — into the vault for passive tracking.

Ideas are NOT action items. They are seeds that get stored, linked, and surfaced later when relevant.

## Process

### 1. Accept Inline Text

The user provides the idea inline with the command (e.g., `/idea Build a CLI dashboard for vault stats`).

If no text was provided, ask: "What's the idea?"

Do not interview or ask follow-up questions. Capture immediately, the user can elaborate in follow-up messages.

### 2. Infer Metadata

Read the following for context:
- All `.md` files in `notes/workstreams/` — to infer related streams
- Recent files in `notes/ideas/` — to understand existing tags and categories

From the idea text, infer:
- **Category**: The kind of idea — `feature`, `tool`, `process`, `integration`, `improvement`, or whatever fits. Freely inferred, no fixed list.
- **Tags**: Lowercase, hyphenated topic tags. Include repo names, technologies, domains.
- **Related streams**: Match against active work streams by comparing the idea text against stream descriptions, repos, and epics. An idea can relate to multiple streams or none.
- **Title**: A concise title summarizing the idea.
- **Slug**: A short, lowercase, hyphenated slug for the filename (2-4 words).

### 3. Create Idea Note

Follow `vault-conventions.md` for all formatting.

Create a note at `notes/ideas/YYYY-MM-DD-<short-slug>.md` using the template from `notes/templates/idea.md`:

```markdown
---
date: YYYY-MM-DD
tags: [tag1, tag2]
category: <inferred category>
related_streams: [Stream Name 1, Stream Name 2]
status: captured
---

# <Title>

## Spark
<The idea text, lightly expanded into 1-3 sentences describing what it is and why it's interesting.>

## Connections
- Related to [[Work Stream Name]]
<!-- Add wikilinks to related streams, repos, other notes -->

## Open Questions
<!-- Leave empty if none are obvious -->
```

Add `[[wikilinks]]` in the Connections section to all related streams and repos.
Add `#tags` in the Spark section body for visual filtering in Obsidian.

### 4. Find Related Ideas

Scan all existing files in `notes/ideas/`:
1. Parse each idea's frontmatter for `tags` and `related_streams`
2. Compare against the new idea's `tags` and `related_streams`
3. Score by number of overlapping tags + overlapping related streams
4. Take the top 3 matches (only include ideas with at least 1 overlap)

For each related idea found, add a wikilink in the Connections section:
```markdown
- Related idea: [[YYYY-MM-DD-slug]] <!-- auto-linked: shared tags [tag1, tag2], stream [Stream Name] -->
```

If no related ideas are found, leave the Connections section with only the work stream links.

### 5. Update Daily Log

Open or create `notes/daily/YYYY-MM-DD.md` (create from template if needed).
Append to the Activity Log section:
```
- **HH:MM** — [idea] Captured "<Title>" → [[YYYY-MM-DD-short-slug]]
```

### 6. Display Result

Show the user:
- Where the note was saved
- The inferred category and tags
- Which work streams were linked (if any)
- Which related ideas were found (if any)
- The idea title

Keep it concise — this should feel lightweight.

## Important Rules

- **Ideas are NOT action items.** Never create todos, checkboxes, or action items from an idea.
- **No interview.** Take inline text, infer everything, create immediately.
- **Auto-infer without confirmation.** Category, tags, related streams, and related ideas are all written without asking the user. Show what was inferred, but don't gate on approval.
- **Work stream sovereignty is preserved.** `related_streams` is a one-directional soft link FROM the idea. Never modify work stream files.
- **Status defaults to `captured`.** All status transitions (to `explored`, `promoted`, `parked`) are manual — the user edits the file directly.
- **Related idea links are capped at 3.** Only include ideas with at least 1 overlapping tag or stream.
- Use `[[wikilinks]]` to build the knowledge graph.
- Use `#tags` in the note body for Obsidian filtering.
