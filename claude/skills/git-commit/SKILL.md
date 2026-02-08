---
name: git-commit
description: Create git commits with conventional commit messages. Handles both staged and unstaged changes.
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git status:*)
---

## Context

- Current git status: !`git status`
- Unstaged changes: !`git diff`
- Staged changes: !`git diff --cached`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Task

1. If there are unstaged changes, break them down by role and stage using `git add` or `git add -p`
2. Commit the staged changes

## Rules

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
