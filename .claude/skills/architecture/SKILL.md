---
name: architecture
description: Interview-based creation and update of ARCHITECTURE.md and repos.md
---

# Architecture Interview

Build and maintain the system architecture document through interactive interview.

## Process

### 1. Load Current State

Read:
- `ARCHITECTURE.md` — current architecture doc (may be empty/placeholder)
- `repos.md` — current repo registry
- `notes/workstreams/` — active work streams for context

### 2. Determine Mode

- **If ARCHITECTURE.md is empty/placeholder**: Full interview mode — build from scratch
- **If ARCHITECTURE.md has content**: Update mode — identify gaps, ask targeted questions

### 3. Interview

Conduct a multi-turn interview using AskUserQuestion. Ask questions one at a time, building on previous answers.

#### For a new architecture doc:

**Round 1 — Repo inventory:**
- "Let's start with your repositories. Tell me about each one — what it does, what language/framework it uses, and how it fits into the bigger picture."
- For each repo mentioned, note: name, purpose, tech stack, role in the system

**Round 2 — Interactions:**
- "How do these repos interact? Which services call which? Are there shared libraries, message queues, or databases?"
- Map out: API calls (REST, GraphQL, gRPC), shared data stores, event flows, shared packages

**Round 3 — Shared patterns:**
- "Are there patterns or conventions shared across repos? Error handling, authentication, logging, deployment?"
- Document: cross-cutting concerns, shared conventions, common libraries

**Round 4 — Fill gaps:**
- Review what you've learned and ask follow-up questions about anything unclear
- "You mentioned X calls Y — is that synchronous or async? What's the data format?"
- Probe for: edge cases, planned changes, pain points

#### For an update:
- Read existing ARCHITECTURE.md
- Identify sections that might be outdated or incomplete
- Ask targeted questions about changes since the last update
- "Has the relationship between X and Y changed? Any new services?"

### 4. Update repos.md

During the interview, if the user mentions repos not in `repos.md`:
- "I noticed you mentioned <repo> which isn't in repos.md. Should I add it?"
- Only add with confirmation
- Use the format from repos.md:
  ```markdown
  ## repo-name
  - **URL:** <ask if not provided>
  - **Description:** <from interview>
  - **Tags:** <inferred from tech stack and role>
  ```

### 5. Draft ARCHITECTURE.md

Generate the architecture doc with these sections:

```markdown
# System Architecture

## Overview
<2-3 paragraph high-level description of the system>

## Service Map
<Text-based diagram showing how repos/services interact>
<Use arrows: A -> B (REST), A -> C (GraphQL), etc.>

## Repo Roles
### repo-name
- **Purpose:** <what it does>
- **Tech Stack:** <language, framework, key libraries>
- **Owns:** <what data/functionality it's responsible for>
- **Depends On:** <other repos/services it calls>
- **Depended On By:** <repos/services that call it>

## Shared Patterns
### Pattern Name
<Description of the cross-cutting pattern>
```

### 6. Present for Approval

Show the draft to the user:
- "Here's the architecture doc I've drafted. Review it and let me know what to change before I save it."
- Iterate on feedback
- Only write to `ARCHITECTURE.md` after the user approves

### 7. Update Daily Log

Append to `notes/daily/YYYY-MM-DD.md`:
```
- **HH:MM** — [architecture] Updated ARCHITECTURE.md — <brief summary of changes>
```

## Important Rules

- **Present the draft for user approval before writing to ARCHITECTURE.md**
- When updating, preserve existing content and modify/extend — don't replace wholesale
- Add repos to `repos.md` only with user confirmation
- Ask one question at a time — don't overwhelm with a wall of questions
- Use follow-up questions to fill gaps — don't accept vague answers
