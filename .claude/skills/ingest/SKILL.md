---
name: ingest
description: Categorize pasted Slack messages, emails, and other info into vault notes with todos and daily log entries
---

# Ingest

Capture and categorize incoming information — Slack messages, emails, meeting notes, or any other pasted content.

## Process

### 1. Accept Content

The user will paste content in their message (or may have already done so). The content could be:
- A Slack message or thread
- An email
- Meeting notes
- A link with context
- Any other text

If no content was provided, ask: "Paste the content you'd like to capture."

### 2. Analyze and Categorize

Read the following for context:
- All `.md` files in `notes/workstreams/` — to match content to work streams
- Recent files in `notes/squawk/` — to understand existing categories and tags

From the pasted content, infer:
- **Source type**: slack, email, meeting, link, other (infer from formatting and context clues)
- **Category**: Infer freely — there is NO fixed list. Examples: decision, request, update, question, feedback, announcement, discussion, incident, idea. Use whatever fits.
- **Tags**: Lowercase, hyphenated. Include repo names, people, topics.
- **Work stream**: Match to an existing work stream if relevant. Content may span multiple streams or be general/miscellaneous.
- **Actionable**: Does this contain action items? (true/false)
- **Title**: A concise title summarizing the content

### 3. Create Squawk Note

Follow `vault-conventions.md` for all formatting.

Create a note at `notes/squawk/YYYY-MM-DD-<short-slug>.md`:

```markdown
---
source: <inferred source>
date: YYYY-MM-DD
category: <inferred category>
tags: [tag1, tag2, tag3]
actionable: true/false
work_stream: <matched work stream or empty>
---

# <Title>

<Reformatted content — clean up but preserve the meaning. Include attribution (who said what).>

## Action Items
<!-- Only if actionable -->
- [ ] Action item 1
- [ ] Action item 2
```

Add `[[wikilinks]]` throughout the note body to related work streams, repos, people, and other notes.
Add `#tags` in the note body for visual filtering.

### 4. Create Todos (if actionable)

If the content contains action items:
1. Identify the relevant work stream's todo file (`notes/todos/<work-stream>.md`)
2. Add checkbox entries with wikilinks back to the squawk note:
   ```
   - [ ] Action description [[YYYY-MM-DD-short-slug]] — added YYYY-MM-DD
   ```
3. If the content doesn't fit a specific work stream, add to a general todo file or ask the user which stream to assign it to.

### 5. Update Daily Log

Open or create `notes/daily/YYYY-MM-DD.md` (create from template if needed).
Append to the Activity Log section:
```
- **HH:MM** — [ingest] Captured <source> re: <brief description> → [[YYYY-MM-DD-short-slug]]
```

### 6. Summarize

Tell the user:
- Where the note was saved
- What category/tags were inferred
- Which work stream it was linked to (if any)
- Any todos created
- A brief summary of the content captured

## Important Rules

- **NEVER create or modify work streams without explicit user confirmation**
- Categories are ALWAYS inferred — there is no fixed list
- Non-actionable content is still valuable — always save it for context
- Use `[[wikilinks]]` liberally to build the knowledge graph
- Use `#tags` in the note body in addition to frontmatter tags
- If content relates to multiple work streams, link to all of them but pick the primary one for the frontmatter `work_stream` field
- Preserve attribution — who said what, when
