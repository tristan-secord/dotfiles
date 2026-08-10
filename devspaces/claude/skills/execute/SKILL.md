---
name: execute
description: Dispatch the tickets from /to-tickets as parallel devspaces task workspaces, each producing its own PR, stacked in dependency order and titled "[Part N] ...".
disable-model-invocation: true
---

# Execute

Take the ticket set `/to-tickets` produced (the `.scratch/<feature-slug>/issues/*.md` files) and drive it to PRs — dispatching independent tickets in parallel as separate devspaces task workspaces, stacking dependent ones on top of each other's branches.

This skill runs in the **orchestrating** session. It dispatches and polls task workspaces; it does not implement anything itself.

## Prerequisites

- The ticket set already exists — run `/to-tickets` first if not.
- You're in a devspaces workspace (`devspaces tasks` requires it).
- Running this skill is the explicit go-ahead to commit, push, and open a PR on your behalf for every ticket it dispatches — that overrides the "never commit without being asked" default, for this run only, for the tasks it spawns. State this plainly before dispatching anything and give the user a chance to stop you.

## 1. Read the tickets

Parse every ticket file under `.scratch/<feature-slug>/issues/`: number (`NN`), title, "Blocked by" (ticket numbers, or "None"), and the full body (what to build + acceptance criteria). Build the dependency graph from "Blocked by".

## 2. Confirm the plan before dispatching anything

Show the user:

- The full ticket list in dependency order.
- Which tickets have no blockers in common — i.e. which ones can run in the same wave, in parallel.
- The resulting PR chain, e.g. `[Part 1]` ← `[Part 2]` (stacked on Part 1) ← `[Part 3]` (stacked on Part 1, independent of Part 2) — draw the actual shape, not just a flat list.
- The task workspace names you'll use: `<feature-slug>-part-<NN>`.

This is a real dispatch of cloud workspaces and real PRs — get explicit confirmation before step 3.

## 3. Determine each ticket's base branch

- **No blockers** → the repo's default branch.
- **One blocker** → that blocker's reported branch (see step 5), even before its PR merges — stack on it directly. Note in the dispatched ticket's PR body that it must merge after its blocker.
- **Multiple blockers** → stacking isn't well-defined (there's no single branch to start from). Exception to the above: wait until *all* of that ticket's blockers have actually **merged** to the default branch, then branch from there like an unblocked ticket. This is the one case where "stack on an unmerged branch" doesn't apply.

## 4. Dispatch, wave by wave

For every ticket whose base branch is now known (no blockers, or its blocker(s) already reported/merged per step 3):

1. Write the seed prompt (template below) to a scratch file with the Write tool — don't inline a multi-paragraph prompt into a shell command.
2. Send it:
   ```
   devspaces tasks send <feature-slug>-part-<NN> --mode bot --prompt-stdin < <scratch-file>
   ```
3. Record the `task_id` → ticket number mapping.

Dispatch every ticket that's ready in the current wave before moving to polling — that's where the real parallelism happens. A dependent ticket only becomes ready once its blocker's task reports a branch (step 5), so a chain of blockers is inherently sequential; independent tickets are not.

## 5. Poll for completions

Poll `devspaces tasks responses` on an interval — a minute or two between checks is plenty; a task's boot + implement + PR cycle takes a while, and busy-polling wastes calls for no benefit. For each new response:

- Ack it: `devspaces tasks ack <id>`.
- Parse the `BRANCH:` / `PR:` / `STATUS:` lines from the task's final message (the seed prompt asks for this exact format so it's parseable, not free text).
- On `STATUS: done` — mark the ticket done and its branch known; dispatch (step 4) anything that was solely waiting on it.
- On `STATUS: blocked` or `STATUS: failed` — surface this to the user immediately. Do **not** silently dispatch its dependents on a branch that may not exist or may be wrong.

## 6. Report

Once every ticket has a PR, give the user the full chain: PR links in merge order, and an explicit note on merge order — this project's stacking convention means merging out of order will show unrelated diffs in the later PRs, so `[Part 1]` must merge before `[Part 2]`'s base is valid, and so on.

## Seed prompt template

```
You are implementing one ticket from a larger, pre-approved plan. This task
was dispatched by /execute — that dispatch is your explicit authorization to
commit, push, and open a PR when done. Do not wait for further confirmation.

# Ticket [NN]: [title]

[full ticket body: what to build, acceptance criteria]

# Base branch

Branch from `[base-branch]` — not the default branch — because this ticket
is stacked on ticket [blocker NN], which has not merged yet.
(Omit this section — branch from the repo's default branch instead — if this
ticket has no blocker, or if its blocker(s) have already merged.)

# When done

1. Run this repo's tests/typecheck for what you touched.
2. Commit and push your branch.
3. Open a PR titled exactly: `[Part [NN]] [title]`
   - Base the PR on `[base-branch]` (see above).
   - In the body, note: "Stacked on #<blocker's PR number> — merge that first."
     (omit if no blocker)
   - Follow this project's usual devspaces PR-body convention (link back to
     this task workspace).
4. Report back, as your final message, exactly these three lines so the
   orchestrator can parse them — nothing else on those lines:
   BRANCH: <branch name>
   PR: <PR URL>
   STATUS: done
   (STATUS: blocked or STATUS: failed, with a one-line reason after it, if
   you could not complete the ticket.)
```
