---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues using tracer-bullet vertical slices. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

## Process

### 1. Choose output target

Ask the user where to publish the issues:

1. **GitHub Issues** — creates GH issues with labels
2. **Trello** — creates Trello cards (requires Trello MCP)

If the user does not specify, ask before proceeding.

**If Trello is chosen:**
- Use the Trello MCP to list available boards (`trello_list_boards` or equivalent)
- Present the board list and ask the user to pick one
- Once a board is selected, list its lists/columns and ask which column new cards should land in (e.g. "Backlog", "To Do")
- Confirm the selection before continuing

### 2. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument:
- **GitHub**: fetch it with `gh issue view <number>`
- **Trello**: fetch it via the Trello MCP

Read the full body and any comments.

### 3. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

### 4. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 6. Publish

Publish issues in dependency order (blockers first) so you can reference real identifiers in the "Blocked by" field.

<issue-template>
## Parent

A reference to the parent issue/card (if the source was an existing issue, otherwise omit).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.
</issue-template>

#### GitHub Issues

For each slice, run:
```
gh issue create --title "<title>" --body "<body from template>" --label "needs-triage"
```

Do NOT close or modify any parent issue.

#### Trello

For each slice, create a card in the board and column the user selected in step 1. Include:
- **Card name**: the slice title
- **Card description**: the full issue body from the template above
- Add a link to the parent GH issue in the description if the source was a GH issue

Use the Trello MCP to create cards. Create in dependency order so you can reference real card URLs in the "Blocked by" field of subsequent cards.

---

## Adding new targets in future

To add Jira or another tracker: add a new option in step 1 and a corresponding publish section in step 6. The slice drafting process (steps 3–5) is target-agnostic and does not change.
