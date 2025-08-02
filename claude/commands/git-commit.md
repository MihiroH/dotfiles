---
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git commit:*)
description: Create a git commit
---

## Context

- Current git diff (staged changes): !`git diff --cached`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.

## Guideline
- Generate a one-liner commit message.
    - ONLY generate the TITLE; no additional description and author is needed.
- Provide an expression in line with previous commit messages.
### example messages:
- feat: Add new feature
- fix: Fix bug
- docs: Update documentation
- refactor: Refactor code
- style: Update code style
- test: Add tests
- chore: Update build process
