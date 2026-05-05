---
name: execute-tickets
description: Fetch open Trello tickets, write a rapid per-ticket plan, create isolated git worktrees with branches, and dispatch parallel agents to implement and PR each ticket. Use when the user says "execute tickets", "start working on tickets", "implement the issues", or wants to pick up Trello work after a PRD and issue-creation phase.
---

# Execute Tickets

You have already done grill-me → PRD → issues. The plan is reviewed. Move fast.

## Steps

### 0. Setup (ask once, before any work)

**Ticket source** — if not already clear from context, ask:
> "Should I pull tickets from Trello or GitHub Issues?"

**Trello** — also ask:
> "Which list(s) should I work from — e.g. 'Todo', a specific label, or everything not in 'Done'?"

**PRD location** — ask or infer:
> "Is there a PRD file I should reference? (local path, GitHub issue/URL, or Trello card with the spec)"

Store the PRD location — it goes into every agent's prompt as a pointer, not as pasted content.

---

### 1. Fetch tickets

**Trello:** Use the Trello MCP to get cards from the identified list(s). For each card, capture:
- Card ID, title, full description (verbatim — do not summarize)
- Checklist items (acceptance criteria)
- Labels indicating dependencies or type

**GitHub Issues:** Use `gh issue list` filtered to the relevant milestone/label. For each issue, capture:
- Issue number, title, full body (verbatim)
- Labels

---

### 2. Group into waves

- **Wave 1**: Cards with no blockers — run in parallel
- **Wave N**: Cards that depend on wave N-1 — run after merge

If dependencies are unclear from labels/descriptions, ask before proceeding.

---

### 3. For each ticket in the current wave

**a) Quick plan (5 bullets max)**
Write inline — no file, no headers. Cover: what changes, which files, edge cases, test strategy, done criteria. This is a reminder, not a spec.

**b) Create worktree + branch**
Invoke `superpowers:using-git-worktrees` to create an isolated worktree. Branch name: `ticket/<card-id>-<slug>`.

**c) Dispatch agent**
Spawn an agent per ticket using `superpowers:dispatching-parallel-agents`. The agent's prompt must include:

- The **quick plan** (5 bullets)
- The **full card title and description** (verbatim, not compressed)
- The **checklist / acceptance criteria** verbatim
- The **worktree path**
- The **PRD location** (file path or URL) with instruction: "Read this if you need domain context or are unsure about scope — don't load it upfront, use it when you hit ambiguity"
- Instructions to follow `superpowers:test-driven-development`
- Instructions to run `superpowers:verification-before-completion` before declaring done
- Instructions to run `superpowers:finishing-a-development-branch` and open a PR when complete — PR title = card title, body links the Trello card / GitHub issue

---

### 4. Move card

After each PR is opened, use Trello MCP to move the card to "In Review" (or equivalent list). For GitHub, add the `in-review` label or move to the appropriate project column.

---

### 5. Next wave

Once wave 1 PRs are open, repeat from step 3 for wave 2 tickets.

---

## Rules
- Never commit directly to main/master
- One worktree per ticket — agents must not share a worktree
- Pass the full card description verbatim — never summarize it before putting it in the agent prompt
- Quick plan supplements the card description; it does not replace it
- Pass the PRD as a pointer (path/URL), not as pasted content — agents have tools to read it
- If a ticket is ambiguous, post a comment on the Trello card (or GitHub issue) asking for clarification instead of guessing
