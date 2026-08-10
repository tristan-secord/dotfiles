# Personal instructions

> **Editing these instructions:** the source of truth is this file at `/mnt/personal/dotfiles/claude/CLAUDE.personal.md`. The `install.sh` in this dotfiles repo `cp`s it to `/mnt/personal/CLAUDE.personal.md` on every workspace start, so any edit to that generated copy is overwritten. When asked to change personal instructions / dotfiles config, edit THIS file (and the generated copy too if the change should take effect in the current session).

- My local machine is a **Mac (macOS)**. When giving me instructions to run on my own machine — shell commands, app launch paths, keyboard shortcuts, install steps — assume macOS, not Linux (the devspaces workspace itself is Linux; this is about *my laptop*).
- Never make a PR or commit unless explicitly asked to. Exception: you may commit and push minor changes to an existing PR when fixing a CI problem.
- Never commit or push on your own. After making fixes or changes, wait for me to explicitly tell you to commit/push — this applies to everything, including skills like `plan-from-pr-comments` and `plan-from-ci-failures` that might otherwise do it automatically.
- Never post a comment to any third-party service (GitHub, Notion, Figma, Slack, etc.) unless I specifically ask you to.
- Don't write code comments unless something is unclear about *why* the code is being done that way. Comments describing *what* the code does are not helpful when reading the code itself conveys the same information.
- When making a pull request, link back to the devspaces workspace that created it. Add this line to the PR body: `[open devspace](https://devspaces.int.canals.ai/workspaces/$DEVSPACES_WORKSPACE_NAME)` — substitute the value of the `$DEVSPACES_WORKSPACE_NAME` env var (e.g. `jolly-beaver-47uk`) in the URL. If `$DEVSPACES_WORKSPACE_NAME` is unset (not in a devspaces workspace), skip this.
- When creating a new devspaces workspace, first run `devspaces ws list` to see the existing workspaces and their groups. If one of the existing groups clearly fits the new workspace, file it there with `devspaces ws create --group <name>`. Do **not** invent or create a new group — if you can't confidently match an existing group, omit `--group` entirely and let it be ungrouped.
- When launching a new devspaces workspace, it must never commit or open a PR automatically. Include an explicit instruction in the seed prompt that the new workspace should make its changes and then wait for me to explicitly ask before committing or PR-ing — never do either on its own.

## PR size

- Default target: a PR should be reviewable in one sitting — roughly **≤400 lines of diff or ≤10 files**, excluding lockfiles/generated code.
- When work is naturally bigger, split along commit-able boundaries (e.g. schema/migration → backend → frontend, or foundational refactor → feature), not by file type.
- A change that's genuinely one atomic unit — can't be half-shipped without breaking something — stays in one PR even if it's large. Don't split just to hit the number.
- When scoping multi-PR work (e.g. via `/to-tickets`), each ticket should satisfy this size limit *in addition to* being a complete vertical slice — state the split up front, or say explicitly that it's staying as one PR, before starting implementation.

## PR descriptions

- Keep them brief. Nobody reads a long PR description; a wall of text gets skimmed or skipped, which defeats the point of writing one.
- Only include a body when there's real *why* to convey — motivation, a constraint, a decision made during the work, context the diff itself can't show. If you'd only be restating what the code does, use `--body ""` instead of padding it out.
- Never include: a file-by-file list of what changed, a section-by-section narration of the diff, or a restatement of the commit message in longer form. The diff already says what changed; the description's only job is *why*, when *why* isn't obvious.
