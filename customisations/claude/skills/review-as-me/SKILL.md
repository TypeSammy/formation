---
name: review-as-me
description: Review a GitHub PR and post inline review comments on the user's behalf, challenged by a second reviewer, with per-comment approval before anything is posted; or review a local branch before a PR exists and output the findings as one block to paste into the session that wrote the code. Use when the user asks to review a PR as them, post PR feedback on their behalf, asks for a pre-PR review of a branch, or invokes /review-as-me with a PR URL, PR number, or branch name.
---

# Review as Me

Review a change, have a second reviewer challenge the findings, then hand them to the user. The input picks one of two modes:

- **PR mode**: a PR URL or number. Walk the user through each finding one at a time, and post each comment to GitHub only after they approve it.
- **Branch mode**: a branch name. A pre-PR review where nothing is posted anywhere. The findings come out as one block the user pastes into the session that implemented the branch, so that agent fixes them before the PR is opened.

Steps 1–4 are shared and note where branch mode differs. Step 5 has one section per mode.

## Hard rules

- **Nothing is posted to GitHub without the user's explicit approval of that specific comment.** No exceptions, including "obvious" nits.
- **Branch mode never touches GitHub.** No comments, no reviews, no PR creation. Its only outputs are text to the user and the files under `~/.claude/reviews/`.
- Every comment posted to GitHub **starts** with this italic preface on its own line, followed by a blank line. `<login>` is the user's GitHub username (`gh api user -q .login`). The branch-mode paste block carries no preface.

  ```
  *Posted by Claude on behalf of @<login>.*
  ```

- Comments are **inline and specific**: anchored to the exact file and line(s), through the pull request comments API in PR mode and as `path:line` references in branch mode. A top-level comment is a last resort, only for a finding that can't be tied to any line, and it still needs approval.
- **Never** submit a GitHub review with an `APPROVE` or `REQUEST_CHANGES` verdict. Individual comments only.
- The verdict (see Step 4) is for the user only. It never appears in anything posted to GitHub or in the paste block.
- If the review has no findings: post nothing, tell the user it's clean, and still give the verdict.
- **The Step 4 summary is always output, in both modes, before Step 5 begins.** It is plain text in the reply, with the verdict box in it. The first picker (PR mode) or the paste block (branch mode) comes after it and never replaces it.
- Every comment must follow **Comment style** below. A draft that breaks those rules isn't ready for the walkthrough, however good the finding.

## Comment style: short, kind, actionable

Long comments don't get read. Every comment meets this bar before the user sees it:

- **At most 4 sentences of prose** (aim for 2–3), plus at most one code block. The preface line doesn't count. If the point can't be made in that space, split the finding or drop it.
- **Shape**: what's wrong (one sentence), then why it matters only if that isn't obvious (at most one sentence), then the fix.
- **Every comment ends with a concrete suggestion.** Use a GitHub ` ```suggestion ` block whenever the fix directly replaces the commented line(s), so the author can apply it in one click, and anchor the comment to exactly the lines it replaces. Otherwise give a short code snippet or name the specific alternative. A comment that only objects doesn't get posted. In branch mode, ` ```suggestion ` means nothing, so use an ordinary fenced code block with a language tag and say which lines it replaces.
- **Don't build a case.** Don't restate what the code does, quote docs at length, pre-empt counterarguments, or add hedges like "feel free to ignore". Link a source instead of quoting it. If the author pushes back, make the fuller argument in the thread reply.
- **One issue per comment.** A second point is a separate finding.
- **Plain, friendly, direct**: address the author, use concrete words and no jargon, and phrase genuine uncertainty as one short question rather than a hedge.

## Input

One argument, which selects the mode:

- A PR URL (e.g. `https://github.com/owner/repo/pull/123`) or a bare PR number → **PR mode**. A bare number is resolved against the current directory's repository.
- Anything else is a branch name → **Branch mode**, in the current directory's repository. `.` or `HEAD` means the checked-out branch (`git branch --show-current`). An optional second argument names the base branch. Otherwise the base is the repository's default branch (`gh repo view --json defaultBranchRef`).

If no argument was given, ask for one (one plain-text question) and stop until answered.

## Step 1: Fetch the change and build context

1. If the URL is for a repository other than the current one and there's no obvious local clone, shallow-clone it into the session scratchpad and work from there.
2. Run `git status --short`. If the working tree has uncommitted changes, stop and ask the user how to proceed before checking anything out.
3. Note the current branch so it can be restored at the end, then:

   ```bash
   gh pr view <number> --json title,body,baseRefName,headRefName,headRefOid,author,url
   gh pr checkout <number>
   gh pr diff <number>
   ```

4. Read the PR description, the full diff, and enough surrounding code to judge each change in context, not just the changed lines.
5. Follow the links. The PR and its ticket point at what the change was built from, and the review checks the code against that, not only against the PR's own account of itself.
   - Read the ticket(s) the PR names in its title, body or branch, using whatever issue-tracker tools are available. Read a parent ticket only when the ticket alone doesn't explain the intent.
   - Open every link in the PR body and the ticket: documents through any available docs tools, other GitHub repositories by shallow-cloning into the scratchpad (`gh repo clone <owner>/<repo> <dir> -- --depth 1`), anything else with WebFetch.
   - When the PR claims to reproduce, port or match a source (a spec, a prototype, a documented rule), read that source closely enough to check the claim. A difference between the source and the code is a finding (`correctness`, or `tests` when a fixture drifted).
   - Record every source read (URL or clone path, and the files consulted) in the state file, so a re-review can start from them.
   - If a link can't be opened with the available tools, note it in the state file and move on.
6. Fetch existing review feedback (`gh api repos/{owner}/{repo}/pulls/<number>/comments`, `gh pr view <number> --comments`, `gh api repos/{owner}/{repo}/pulls/<number>/reviews`) and use it as input:
   - Don't repeat a point someone already made, including ones the author has addressed, rebutted or resolved.
   - If an existing thread supports, contradicts or leaves open one of your findings, factor that in and mention it during the walkthrough.
7. Check for a previous run of this skill: a state file at `~/.claude/reviews/<repository>-pr-<number>.md` (see **Review state file**), or PR comments starting with the preface. If either exists, switch to **Re-review mode** once context is built.

### Branch mode

Items 4 and 5 apply unchanged. Replace items 1–3 and 6–7 with:

1. `git fetch origin <base> <branch>`. If the branch isn't checked out, `git status --short` must be clean (otherwise stop and ask), note the current branch, then `git checkout <branch>`. If it is checked out and the tree has uncommitted changes, ask (one plain-text question) whether the review covers them or only the commits.
2. Record the head SHA (`git rev-parse HEAD`), then build the commit list and diff against the merge base:

   ```bash
   git log --oneline origin/<base>..<branch>
   git diff origin/<base>...<branch>   # `git diff origin/<base>` when uncommitted changes are in scope
   ```

3. The commit messages stand in for the PR description. Follow links as in item 5, starting from any ticket key in the branch name or commit messages.
4. There's no existing feedback to fetch. If `gh pr list --head <branch>` shows an open PR, say so in one line and carry on in branch mode. The user can re-run with the PR number to post comments.
5. The state file is `~/.claude/reviews/<repository>-branch-<branch>.md` (slashes in the branch name replaced with `-`). If it exists, switch to **Re-review mode** once context is built.

## Step 2: Draft the review

Review the whole change across these categories, tagging every finding with one:

`correctness` · `tests` · `design` · `security` · `performance` · `style`

All categories count, nits included. The user filters at approval time, not you.

For each finding record: category, file and line(s) (lines that are in the diff), a one-line summary, and the full comment text exactly as it will be delivered (PR mode with the preface, branch mode without it), following **Comment style**. Apply the 4-sentence limit and attach the suggestion while drafting, not as a later trim.

### Names should say what things are for

Check every name the change adds or renames: classes, modules, methods, variables, files, database tables and columns, feature flags, config keys, metrics, background jobs. The test: would someone who hasn't seen this change guess what it's for from the name alone? Raise a finding when a name is:

- **misleading**: says one thing and does another (e.g. `fetch_user` that also changes state). Tag `design`, or `correctness` if it will cause real misuse.
- **vague**: says nothing about intent (`data`, `handle`, `process_items`, `FooManager`). Tag `design`.
- **about the mechanism instead of the purpose** (e.g. `redis_hash_writer` instead of `session_store`). Tag `design`, or `style` when minor.

Every naming comment proposes a specific better name.

### Large changes: split across subagents

Review in a single context by default. Only when the change is too big to review well in one go (as a guide, more than about 30 changed files or 2,000 changed lines; check with `gh pr diff <number> | wc -l` and `gh pr view <number> --json files`, or `git diff origin/<base>...<branch> --stat` in branch mode):

1. Split the diff into units by subsystem or commit, **never one per file**, because the real problems are usually in how files interact.
2. Start one subagent per unit, in parallel. Give each the PR description (branch mode: the commit messages), a one-paragraph overview of the whole diff, the context from Step 1 that's relevant to its unit (clone paths and file names, not a summary), any relevant existing feedback, and its slice of the diff to review in depth against the same categories. Each returns findings in the Step 2 format.
3. Merge the findings: remove duplicates, resolve conflicts, then do one pass across the whole diff for things no single unit could see, such as changed interfaces and their callers, migrations and the code that uses them, and tests and the behaviour they should cover.

The merged findings go into Step 3 as normal.

## Step 3: Have a second reviewer challenge the draft

A second reviewer tries to find holes in the draft before the user sees it. Use Codex if its Claude Code plugin is installed, and a separate Claude subagent otherwise.

1. Write the current draft to `draft-review.md` in the session scratchpad: one entry per finding with category, `file:line` and the full comment text.
2. Look for the Codex plugin's companion script (pick the highest version if there are several):

   ```bash
   ls ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null
   ```

3. Run the challenge, using this brief:

   > A PR review has been drafted; the findings are in `<absolute path to draft-review.md>`. Try to prove each finding wrong against this diff: flag false positives, wrong categories or severity, unclear wording, comments that break the style rules (more than 4 sentences of prose, more than one code block, or no concrete suggestion), and any important issue the draft missed. Say exactly which findings you dispute and why.

   - **Codex found:** run it in the foreground from the checkout, against the base (`baseRefName` in PR mode, the base branch in branch mode):

     ```bash
     node <companion script> adversarial-review "--wait --base origin/<base> <the brief>"
     ```

   - **No Codex:** start a fresh subagent that hasn't seen your reasoning. Give it the brief, the diff command, and the paths to the checkout and the draft.

4. Reconcile: drop findings the reviewer convincingly disproves, fix wording or severity it rightly challenges, and add issues it found that you agree are real. Don't adopt a point you think is wrong; argue it in the next round instead. Rewording never loosens **Comment style**: if the reviewer wants a firmer case, sharpen the existing sentences instead of adding more.
5. Repeat steps 1–4 with the revised draft until there are no real objections left. **Stop after 3 rounds.** If you still disagree after that, keep the disputed findings, mark each *disputed* with one line for each side, and let the user decide in the walkthrough.

## Step 4: Summary and verdict

Output one short **summary** in plain text in the reply (never inside a picker), containing in this order:

1. The number of findings and any other context. In re-review mode, the addressed / partly addressed / not addressed report goes here.
2. The **verdict**, **directly before the findings list** with nothing between them, in a box so it can't be missed, with at most one sentence of reasoning under it. It's for the user only and is never posted. Render the box as a fenced code block:

   ```
   ╔═══════════════════════════╗
   ║  VERDICT: APPROVE         ║
   ╚═══════════════════════════╝
   ```

   or `VERDICT: REQUEST CHANGES`. In branch mode the verdict says whether the branch is ready to become a PR: `VERDICT: READY FOR PR` or `VERDICT: NOT READY`.
3. The numbered findings, straight after the box. One short line each: category, `file:line`, and the fewest words that identify the issue. Mark disputed findings.

Once that summary is out, start the walkthrough at finding 1 in PR mode, or output the paste block in branch mode.

## Step 5 (PR mode): Walk through one finding at a time

Starts only after the Step 4 summary. For each finding:

1. Output a short plain-text explanation of why it matters: a sentence or two covering the category, file and line(s), and the reasoning. Say if it was disputed.
2. Show a picker with `AskUserQuestion`: question "Finding N of M: category, file:line, one-line summary", header "Finding N/M", single-select. Put the exact comment text (preface included) as the `preview` on **every** option so it stays visible whichever option is focused. Options, in this order:
   - **Post**: post this comment inline exactly as shown.
   - **Skip**: don't post. Record it as skipped in the state file, with their reason if they give one (don't ask for one).
   - **Edit**: they describe the change; revise the comment and show the picker again with the new text.
   - **Explain**: explain the issue in plain language, then show the picker again. The comment is written for the PR author, but the explanation is for the user, so it can be longer and assume less. Cover, in order: what the code does now, what goes wrong (a concrete input or situation), why that matters, and how the suggested change fixes it. Define any technical term the first time you use it, and don't reuse the comment's wording.
   - **Discuss**: through the picker's built-in free-text "Other" field (the picker allows at most four labelled options). A question, doubt or pushback typed there is a discussion: answer in plain text, then show the picker again. Free text that reads like a wording change is an **Edit**. If it's unclear which they meant, ask (one plain-text question).

   The preview disappears once an option is chosen. So whenever **Explain** or **Discuss** moves into plain text, start by quoting the current comment text in full (preface included) in a fenced code block. During a **Discuss** exchange, quote it again only if the text has changed since it was last shown.

Only on **Post**, post that one comment straight away:

```bash
gh api repos/{owner}/{repo}/pulls/<number>/comments \
  -f body='<comment text with preface>' \
  -f commit_id='<headRefOid>' \
  -f path='<file>' \
  -F line=<line> \
  -f side=RIGHT
```

For a comment spanning several lines, add `-F start_line=<first line> -f start_side=RIGHT`. Lines must be in the diff, so move to the nearest diff line if needed. A ` ```suggestion ` block replaces exactly the anchored lines, so set `line` and `start_line` to precisely the lines it rewrites.

Confirm it posted, then move to the next finding. After every decision (posted, edited then posted, or skipped), update the state file before moving on.

## Step 5 (branch mode): Paste block

There's no per-finding approval here: nothing is published, and the user edits the block before pasting it. Output every finding from Step 4 in one block written for the agent that implemented the branch, not for the user.

1. Write the block to `~/.claude/reviews/<repository>-branch-<branch>.paste.md` and print it in the reply inside a single four-backtick fence, so the code blocks inside survive.
2. Use this shape, keeping the Step 4 numbering (including gaps after a dropped finding) so the user can refer to findings by number:

   ````
   Review of branch `<branch>` against `<base>` at `<short SHA>`. Address each finding in order. Where you disagree with one, leave the code alone and say why.

   ## 1. [correctness] src/models/user.rb:42 — one-line summary

   <comment text: what's wrong, why it matters, the fix, with a fenced code block when the fix is code, naming the lines it replaces>

   ## 2. [tests] spec/models/user_spec.rb:10-18 — one-line summary

   ...
   ````

   Each entry must stand on its own: the agent has the working tree but not this conversation, so the `path:line`, the problem and the fix all go in the entry. Line numbers refer to the reviewed head (the working tree, if uncommitted changes were included). End a disputed entry with `Disputed: <one line for each side>` so the agent checks before changing anything.
3. After the block, add one line naming the file (`pbcopy < <path>` copies it). Record every finding as `emitted` in the state file.
4. The user may then drop, edit or ask about a finding in conversation. Handle a question like PR mode's **Explain**. On a drop or edit, update the state file (`dropped` with their reason, or the new text) and print the whole block again, so what they paste is always current.

## Step 6: Wrap up

- Check out the branch that was checked out before Step 1.
- Finish the state file: mark the run complete, and make sure every finding's outcome and the user's preferences are recorded.
- Report how many comments were posted and skipped, with a link to the PR. In branch mode, report how many findings are in the block, how many were dropped, and the paste file path.

## Review state file

Every run keeps `~/.claude/reviews/<repository>-pr-<number>.md` (repository name without the owner, e.g. `my-app-pr-123.md`), or `<repository>-branch-<branch>.md` in branch mode. Run `mkdir -p ~/.claude/reviews` first. This file is the review's memory: it must hold everything needed to resume in a new session without re-deriving anything. Record:

- **What was reviewed**: URL, repository, number, title, base branch, and the head commit SHA reviewed. In branch mode: repository, branch, base, head SHA, and whether uncommitted changes were included.
- **Sources read**: the ticket(s) and every linked document or repository from Step 1 (URL or scratchpad clone path, and the files read), so a re-review can reopen them directly.
- **Progress**: how far the run got (context built / draft done / challenge round N / walkthrough at finding N / block emitted / complete), the date, and the verdict given.
- **Every finding**: number, category, `file:line`, one-line summary, final comment text, the second reviewer's position if disputed, and the outcome: `posted` (with the comment URL), `skipped` (with the reason), or `pending`. In branch mode: `emitted` or `dropped` (with the reason).
- **The user's preferences** from the walkthrough: wording edits, kinds of findings they waved off, and anything that should steer the next run on this change.

Update the file at every key point (after building context, after the challenge rounds, and after each walkthrough decision), not just at the end, so an interrupted session loses nothing.

## Re-review mode

Triggered in Step 1 when the state file exists or the PR already has comments starting with the preface.

1. Read the state file and all GitHub threads. If the last run didn't finish its walkthrough, tell the user and offer to resume from the first `pending` finding instead of starting over.
2. Work out what changed since the last review: `git diff <last reviewed SHA>...<current head>` plus the commit list from `gh pr view <number> --json commits` (branch mode: `git log <last reviewed SHA>..<branch>`). If nothing changed, say so and stop.
3. Check earlier feedback. For each previously posted comment (branch mode: each emitted finding), check the new commits and, in PR mode, the thread replies, then mark it **addressed**, **partly addressed** or **not addressed**. Don't raise findings the user skipped or dropped again unless the new commits make them clearly worse, and if one comes back, say that's why.
4. Review the new changes in depth against all the Step 2 categories, with a lighter pass over the rest of the diff. An unaddressed earlier comment can become a follow-up finding where a nudge is needed.
5. Everything after that is the same: the challenge rounds, then the Step 4 summary (leading with the addressed / partly / not addressed report, then the verdict box directly before the new findings), then the Step 5 for the mode in use. In branch mode, the new paste block also includes the **partly addressed** and **not addressed** findings, each ending with `Carried over from the previous review`, so the agent gets one complete list.
