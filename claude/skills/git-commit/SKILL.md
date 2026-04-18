---
name: git-commit
description: Create git commits with conventional commit messages. Handles both staged and unstaged changes.
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git add -p:*), Bash(git add:*), Bash(git status:*)
---

## Context

- Current git status: !`git status`
- Unstaged changes: !`git diff`
- Staged changes: !`git diff --cached`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Task

Don’t use a sub-agent.

1. If there are unstaged changes, break them down by role and stage using `git add` or `git add -p`
2. Commit the staged changes

## Rules

- ALWAYS ask for user approval with `Bash(git commit:*)` before running `git commit`. Never auto-commit.
- One-liner commit message only (title, no body/author)
- Match the style of recent commits
- Use conventional commit format:
  - `feat:` new feature
  - `fix:` bug fix
  - `docs:` documentation
  - `refactor:` refactoring
  - `style:` formatting
  - `test:` tests
  - `chore:` build/tooling
