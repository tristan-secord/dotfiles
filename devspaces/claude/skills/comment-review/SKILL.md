---
name: comment-review
description: A strict pass over every comment your diff touches — delete anything that restates the code; keep only comments that explain a non-obvious WHY.
disable-model-invocation: true
---

# Comment review

Go through every comment your diff adds or touches and hold each one to a single bar: **if this comment were deleted, would the code get harder to understand?** If not, delete it. Default to deleting — a comment has to earn its place, not the other way around.

## Remove

- Any comment describing WHAT the code does, when the code already says that. Well-named functions and variables make these redundant by construction — if you're writing a comment to make up for a bad name, rename instead of commenting.
- Restating the obvious.
- Comments on tests that describe what the test does — the test name should already do that job. If a test needs a comment to be understood, the name is wrong; fix the name instead of commenting around it.
- Multi-line or multi-paragraph comment blocks. If an explanation needs that much space, it belongs in the PR description, not the source.
- Stale or narrative markers: "added for X", "removed Y", "see PR #123", references to the current task/fix/caller. These rot as the codebase evolves.
- Commented-out code.

## Keep

A comment earns its place only if it explains **WHY**, and that WHY is something a future developer genuinely needs and cannot get from reading the code:

- A non-obvious constraint or invariant.
- A workaround for a specific external bug or limitation (name it if you can).
- Something that would genuinely surprise a careful reader.

If it clears that bar, keep it — but only as long as the WHY actually requires, not longer.

## Process

1. `git diff <base-branch>...HEAD` (or `git diff` for uncommitted work) to see every comment the change adds or touches. Only review comments you touched — don't go rewrite unrelated parts of the file.
2. Apply the bar above to each one.
3. Be strict, not generous. A diff with many comments is very likely over-commented — the norm is zero or very few comments outside the WHY exceptions above. When in doubt, cut it.
4. Apply the edits directly — delete or trim comments in place. Don't just report findings.
