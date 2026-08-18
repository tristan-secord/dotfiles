---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it — splitting further into **sub-tickets** only where work needs sequencing inside a single ticket, not a second PR.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Terminology

- **Ticket** — a unit of work that becomes its own branch and its own PR. Tickets declare blocking edges against each other, and `/execute` dispatches each one to its own isolated agent.
- **Sub-ticket** — a task *inside* one ticket. Sub-tickets share the ticket's branch and land in that ticket's single PR — they're a checklist for sequencing work inside one PR, not a request for a second one. A sub-ticket never gets its own blocking edges against other tickets; only the parent ticket does, and `/execute` never dispatches a sub-ticket on its own.

If you're breaking work up and unsure which one you're creating, ask: "does this need its own review and its own merge, separate from the rest?" Yes → ticket. No, it just needs to happen in a particular order → sub-ticket.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

**API-contract changes (fields, enums, RPC/REST schemas) get the same two-step treatment.** Adding or removing a field or enum value across independently-deployed services isn't safe in one shot: sequence it as two tickets. First the additive/backward-compatible step — add the field as optional, or stop using an enum value while it's still in the schema — confirmed deployed everywhere via `pnpm cli commit-check <commit>`. Then the follow-up — make the field required, or remove the value from the schema — as a separate ticket blocked by the first. Exception: when the RPC server and all its callers live in the same deployment unit (e.g. the API monolith), there's no window where one side is ahead, so it can stay one ticket.

### 3.5 Granularity: default to one ticket, split only when you can say why

A **ticket** is a new PR — its own branch, its own review, its own merge, and, if anything stacks on it, a merge-order dependency for every ticket after it. That's real overhead, so more tickets than the work needs is not a free choice; it's a cost you're imposing on the person reviewing and merging this.

**If the work can land and be reviewed as one coherent diff, it's one ticket** — use sub-tickets (see Terminology) to sequence the work inside it, not a split. Before proposing a second ticket instead of a sub-ticket, you must be able to state a concrete reason it can't be reviewed and merged together. Valid reasons:

- **Independent deployability/reviewability** — the two halves genuinely need to land and be reviewed separately (e.g. the user wants to ship one piece before the rest is ready).
- **A real blocking edge** — later work literally cannot start (not merely "would be tidier to start separately") until this piece has landed, e.g. a schema migration the rest of the slice depends on.
- **Context-window size** — the combined work is too large for one agent, one context window, one coherent diff, per the "sized to fit in a single fresh context window" rule above.
- **Wide-refactor or API-contract sequencing** — the expand–contract and additive/breaking sequencing described above are inherently multi-PR by nature.

**Not valid reasons**: "it touches a different layer" (schema vs API vs UI is exactly what one vertical slice is supposed to cross), "it's a different file or module," "it felt like a natural place to break," or splitting for its own sake / for tidiness. Those are sub-ticket territory — break the work up for clarity and ordering without paying for a second PR and a second review.

When unsure, default to a sub-ticket and raise the question with the user in step 4 rather than defaulting to a split.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work
- **Sub-tickets**, if any: the internal task breakdown, so the user can see this is sequencing inside one PR, not a hidden extra ticket
- **Why it's a separate ticket** (only for tickets that have a sibling they could plausibly have been merged with): the concrete reason from the granularity rule above — not asserted, stated

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- For each ticket split, does the stated reason actually hold — or should it be a sub-ticket instead?
- Should any tickets be merged, split further, or converted between ticket and sub-ticket?

Iterate until the user approves the breakdown.

### 5. Publish the tickets to the configured tracker

Publish the approved tickets. **How** depends on the tracker `/setup-matt-pocock-skills` configured — the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below — one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise — the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

**Sub-tickets** (optional — an internal task breakdown for sequencing work inside this one PR; omit entirely if the ticket doesn't need one):
- [ ] Sub-ticket 1: ...
- [ ] Sub-ticket 2: ...

**Acceptance criteria:**
- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Sub-tickets

An internal task breakdown for sequencing work inside this one PR (optional — omit entirely if the ticket doesn't need one). These are **not** separate issues on the tracker and never get their own blocking edges — just a checklist.

- [ ] Sub-ticket 1
- [ ] Sub-ticket 2

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

</issue-template>

In either form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.
