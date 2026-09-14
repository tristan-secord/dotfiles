---
name: code-review-assist
description: Given a GitHub PR link, explain what it does, propose a review order and where to focus, and surface the top comments you'd expect from a reviewer and from a /simplify pass — a briefing to read before writing your own review.
disable-model-invocation: true
---

# Code Review Assist

Given a PR link, produce a short pre-review briefing: what the PR does, how to approach reviewing it, and the comments you'd expect to land. This runs before you write your own review — it's a lens to read the PR through, not a substitute for reading it, and it never posts anything to the PR itself.

## Process

### 1. Fetch the PR

- `gh pr view <url> --json title,body,baseRefName,headRefName,additions,deletions,files,comments,reviews`
- `gh pr diff <url>` for the full diff.
- If `gh` can't reach the repo (no auth, wrong org), fall back to WebFetch on the PR URL for the title/description, and ask the user to paste the diff.

### 2. Explain the PR

Briefly describe what problem it solves, the approach taken, and the actual scope, why we are making these changes — grounded in the diff itself, not just the title/description, since the two can drift on a large PR.

### 3. Propose a review order and where to focus

Group the changed files by module/layer (schema/migrations, core logic, call sites/integration points, API/RPC surface, tests, UI/formatting). Propose an order to read them in — contracts and schemas first, since everything else assumes their shape, core logic next, then call sites, with tests and formatting last. Name the 1-2 modules that deserve the most attention: favor the ones with a high ratio of actual logic change to line count over whichever module is just largest.

### 4. Top review comments

Read the diff like a reviewer. Surface the top 1-3 comments you'd expect to leave, or expect from another reviewer — correctness bugs, missed edge cases, data/security concerns, architectural fit. Each one names a concrete failure scenario (input/state → wrong output or crash), not a vague "consider...". Rank most important first. If the PR is genuinely clean, say so — don't manufacture comments to fill the slots.

### 5. Simplify-pass comments

Apply the same bar as `/simplify` — reuse, simplification, efficiency, minimizing the diff, reusing existing code instead of reintroducing it — to surface the top 1-3 readability/cleanliness comments. Rank most valuable first, and skip this section if the diff is already lean.

### 6. Present as one report

Structure the output under the four headings above (explanation, review order & focus, top review comments, simplify comments) so the user can skim it before their own pass, or paste pieces of it into review comments. This is advisory only — never post to the PR or its comment threads unless the user explicitly asks. Save the file in a /tmp/ location

Once the report is delivered, the user takes over: they'll review the PR themselves and ask questions as they go. For the rest of the conversation, keep answers brief by default — expand only when they actually ask for more detail.
