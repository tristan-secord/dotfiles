---
name: execute
description: Dispatch the tickets from /to-tickets as parallel background agents in isolated git worktrees, each producing its own draft PR, stacked in dependency order and titled "[Part N] ...".
disable-model-invocation: true
---

# Execute

Take the ticket set `/to-tickets` produced (the `.scratch/<feature-slug>/issues/*.md` files) and drive it to PRs — dispatching independent tickets in parallel as separate background agents, each in its own isolated git worktree, stacking dependent ones on top of each other's branches.

This skill runs in the **orchestrating** session. It dispatches worktree agents and waits for their completion notifications; it does not implement anything itself.

**Dispatch is per ticket, never per sub-ticket.** `/to-tickets` defines a **ticket** as a new PR and a **sub-ticket** as an internal task breakdown that lands inside a ticket's single PR. One background agent, one worktree, one branch, one PR per ticket — its sub-tickets (if it has any) are just the checklist that agent works through sequentially inside that one dispatch, not separate dispatches. If a ticket file has no "Sub-tickets" section, it's a single task; treat it the same way either way.

## Prerequisites

- The ticket set already exists — run `/to-tickets` first if not.
- You're inside the git repo the tickets apply to.
- Running this skill is the explicit go-ahead to commit, push, and open a draft PR on your behalf for every ticket it dispatches — that overrides the "never commit without being asked" default, for this run only, for the agents it spawns. State this plainly before dispatching anything and give the user a chance to stop you.

## 1. Read the tickets

Parse every ticket file under `.scratch/<feature-slug>/issues/`: number (`NN`), title, "Blocked by" (ticket numbers, or "None"), and the full body (what to build, its optional "Sub-tickets" checklist, and acceptance criteria). Build the dependency graph from "Blocked by" — sub-tickets are not part of this graph; they carry over into the seed prompt as-is (see template below).

## 2. Confirm the plan before dispatching anything

Show the user:

- The full ticket list in dependency order.
- Which tickets have no blockers in common — i.e. which ones can run in the same wave, in parallel.
- The resulting PR chain, e.g. `[Part 1]` ← `[Part 2]` (stacked on Part 1) ← `[Part 3]` (stacked on Part 1, independent of Part 2) — draw the actual shape, not just a flat list.
- The branch names you'll use: `<feature-slug>-part-<NN>`.

This is a real dispatch of background agents that will commit, push, and open real draft PRs on your behalf — get explicit confirmation before step 3.

## 3. Determine each ticket's base branch

- **No blockers** → the repo's default branch.
- **One blocker** → that blocker's reported branch (see step 5), even before its PR merges — stack on it directly. Note in the dispatched ticket's PR body that it must merge after its blocker.
- **Multiple blockers** → stacking isn't well-defined (there's no single branch to start from). Exception to the above: wait until *all* of that ticket's blockers have actually **merged** to the default branch, then branch from there like an unblocked ticket. This is the one case where "stack on an unmerged branch" doesn't apply.

## 4. Dispatch, wave by wave

For every ticket whose base branch is now known (no blockers, or its blocker(s) already reported/merged per step 3), dispatch it — **one ticket at a time, in this order**, so each worktree branches from the right point:

1. `git fetch origin`, then `git checkout <base-branch>` in the main working directory (create it locally first if it only exists on the remote so far). The Agent tool's `isolation: "worktree"` creates the new worktree from whatever's currently checked out here — that's why this has to happen immediately before dispatch, not batched ahead of time.
2. Write the seed prompt (template below) to a scratch file with the Write tool — don't inline a multi-paragraph prompt into a shell command.
3. Call the Agent tool with `isolation: "worktree"`, `subagent_type: "general-purpose"`, the seed prompt (read back from the scratch file), and leave it running in the background (the default — do not pass `run_in_background: false`).
4. Record the agent's id/name → ticket number mapping.

The checkout-then-dispatch steps happen sequentially, but they're just local git commands (seconds each) — the actual multi-minute implementation work happens in parallel across the background agents afterward. That's where the real parallelism is. A dependent ticket only becomes ready once its blocker's agent reports a branch (step 5), so a chain of blockers is inherently sequential; independent tickets are not.

## 5. Wait for completions

Don't poll — background agents notify you when they finish; never sleep or proactively check on them. For each completion notification:

- Parse the `BRANCH:` / `PR:` / `STATUS:` lines from the agent's final report (the seed prompt asks for this exact format so it's parseable, not free text).
- On `STATUS: done` — mark the ticket done and its branch known; dispatch (step 4) anything that was solely waiting on it.
- On `STATUS: blocked` or `STATUS: failed` — surface this to the user immediately. Do **not** silently dispatch its dependents on a branch that may not exist or may be wrong.

## 6. Report

Once every ticket has a draft PR, give the user the full chain: PR links in merge order, and an explicit note on merge order — this project's stacking convention means merging out of order will show unrelated diffs in the later PRs, so `[Part 1]` must merge before `[Part 2]`'s base is valid, and so on.

## Seed prompt template

```
You are implementing one ticket from a larger, pre-approved plan, in an
isolated git worktree dispatched by /execute. That dispatch is your explicit
authorization to commit, push, and open a draft PR when done. Do not wait for
further confirmation.

# Base branch

First, create your branch from the right base:
  git checkout -b [branch-name] [base-ref]

Branch from `[base-branch]` — not the default branch — because this ticket
is stacked on ticket [blocker NN], which has not merged yet.
(Omit this section — branch from the repo's default branch instead — if this
ticket has no blocker, or if its blocker(s) have already merged.)

# Ticket [NN]: [title]

[full ticket body: what to build, acceptance criteria]

# Sub-tickets

[the ticket's "Sub-tickets" checklist, verbatim, if it has one — otherwise
omit this section entirely]

These are internal sequencing, not separate PRs: work through them in order,
inside this one worktree and branch, and land ALL of them in the single PR
you open at the end. Do not open a PR per sub-ticket.

# Working rules

- Before every commit, run `/canals:review-local-changes` against your
  pending changes and address what it flags — don't commit past an
  unaddressed finding. This applies to every commit, including one per
  sub-ticket if you're committing as you go.
- Run this repo's tests/typecheck for whatever you touched.

# Before finishing

Once the implementation itself is done, in order:

1. `/simplify` — reuse, simplification, efficiency, altitude cleanups. Apply
   its fixes.
2. `/comment-review` — strip comments down to WHY-only, per that skill's
   bar. Apply its fixes.
3. Commit anything those two steps changed (still subject to the
   `/canals:review-local-changes` rule above).
4. `/canals:review-pr` — the final gate. Address what it flags.
5. Push your branch and open a **draft** PR titled exactly: `[Part [NN]] [title]`
   - Base the PR on `[base-branch]` (see above).
   - In the body, note: "Stacked on #<blocker's PR number> — merge that first."
     (omit if no blocker)
   - Follow this project's usual PR-body convention (link back to this
     agent's worktree/task if relevant).
6. Report back, as your final message, exactly these three lines so the
   orchestrator can parse them — nothing else on those lines:
   BRANCH: <branch name>
   PR: <PR URL>
   STATUS: done
   (STATUS: blocked or STATUS: failed, with a one-line reason after it, if
   you could not complete the ticket.)
```
