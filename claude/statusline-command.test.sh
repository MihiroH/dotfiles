#!/bin/bash
# Tests for statusline-command.sh
# Usage: bash claude/statusline-command.test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$SCRIPT_DIR/statusline-command.sh"
TEST_DIR=$(mktemp -d)
PASS=0 FAIL=0

cleanup() { rm -rf "$TEST_DIR"; }
trap cleanup EXIT

# Disable gh pr view in tests (no network)
export GH_TOKEN=disabled

run_statusline() {
    local dir="$1"
    echo "{\"workspace\":{\"current_dir\":\"$dir\"}}" | bash "$SCRIPT"
}

# Strip ANSI escape codes for comparison
strip_ansi() {
    sed $'s/\x1b\\[[0-9;]*m//g'
}

assert_match() {
    local desc="$1" actual="$2" pattern="$3"
    if echo "$actual" | grep -qE "$pattern"; then
        PASS=$((PASS + 1))
        printf "  \033[32mPASS\033[0m %s\n" "$desc"
    else
        FAIL=$((FAIL + 1))
        printf "  \033[31mFAIL\033[0m %s\n" "$desc"
        printf "    expected pattern: %s\n" "$pattern"
        printf "    actual: %s\n" "$actual"
    fi
}

assert_no_match() {
    local desc="$1" actual="$2" pattern="$3"
    if echo "$actual" | grep -qE "$pattern"; then
        FAIL=$((FAIL + 1))
        printf "  \033[31mFAIL\033[0m %s\n" "$desc"
        printf "    should NOT match: %s\n" "$pattern"
        printf "    actual: %s\n" "$actual"
    else
        PASS=$((PASS + 1))
        printf "  \033[32mPASS\033[0m %s\n" "$desc"
    fi
}

# ── Helper: create a test repo ──────────────────────────────────────
#   master ── notice-dialog ── common-components ── password-reset
#                                └── initial-password-setup (no commits)
setup_repo() {
    local repo="$TEST_DIR/repo-$1"
    mkdir -p "$repo" && cd "$repo"
    git init -q
    echo "base" > f.txt && git add . && git commit -q -m "init"

    git checkout -q -b notice-dialog
    echo "notice" >> f.txt && git add . && git commit -q -m "notice"

    git checkout -q -b common-components
    echo "common1" >> f.txt && git add . && git commit -q -m "common1"
    echo "common2" >> f.txt && git add . && git commit -q -m "common2"

    git checkout -q -b password-reset
    echo "pw" >> f.txt && git add . && git commit -q -m "pw"

    git checkout -q common-components
    git checkout -q -b initial-password-setup
    # no commits on this branch

    echo "$repo"
}

# ── Helper: create a repo with remote tracking ──────────────────────
setup_repo_with_remote() {
    local repo="$TEST_DIR/repo-$1"
    local remote="$TEST_DIR/remote-$1"
    mkdir -p "$remote" && cd "$remote"
    git init -q --bare

    git clone -q "$remote" "$repo" && cd "$repo"
    echo "base" > f.txt && git add . && git commit -q -m "init"
    git push -q origin master 2>/dev/null || git push -q origin main 2>/dev/null

    echo "$repo"
}

# ═══════════════════════════════════════════════════════════════════
echo "=== Base branch detection ==="
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "--- Feature branch with commits: finds parent ---"
repo=$(setup_repo "base-detection")

git -C "$repo" checkout -q common-components
out=$(run_statusline "$repo" | strip_ansi)
assert_match "common-components base is notice-dialog (+2)" "$out" '\+2 -0'

git -C "$repo" checkout -q password-reset
out=$(run_statusline "$repo" | strip_ansi)
assert_match "password-reset base is common-components (+1)" "$out" '\+1 -0'

echo ""
echo "--- Nested branches: children are skipped ---"
git -C "$repo" checkout -q common-components
expected_diff=$(git -C "$repo" diff notice-dialog...HEAD --shortstat | awk '{print $4}')
out=$(run_statusline "$repo" | strip_ansi)
assert_match "common-components diff matches notice-dialog" "$out" "\\+${expected_diff} "

echo ""
echo "--- Branch with no commits, parent NOT advanced: uses parent as base ---"
git -C "$repo" checkout -q initial-password-setup
echo "wip" >> "$repo/f.txt"
out=$(run_statusline "$repo" | strip_ansi)
# common-components is at the same commit as initial-password-setup HEAD
# diff should only show working tree changes (1 line added)
assert_match "initial-password-setup with no commits diffs against common-components" "$out" '\+1 -0'

echo ""
echo "--- Branch with no commits, parent advanced (with PR uses gh, without falls back to grandparent) ---"
repo_adv=$(setup_repo "advanced-parent")
git -C "$repo_adv" checkout -q common-components
echo "advance" >> "$repo_adv/f.txt" && git -C "$repo_adv" add . && git -C "$repo_adv" commit -q -m "advance"
git -C "$repo_adv" checkout -q initial-password-setup
echo "setup" >> "$repo_adv/f.txt"
out=$(run_statusline "$repo_adv" | strip_ansi)
# Without gh/PR, falls back to notice-dialog (grandparent). Shows some diff.
assert_match "initial-password-setup shows diff stats" "$out" "\\+[0-9]+ -[0-9]+"

echo ""
echo "--- Default branch: uses upstream ---"
repo2=$(setup_repo_with_remote "default-branch")
default_branch=$(git -C "$repo2" symbolic-ref --short HEAD)

echo "local change" >> "$repo2/f.txt"
out=$(run_statusline "$repo2" | strip_ansi)
assert_match "$default_branch with local changes shows diff" "$out" '\+1 -0'

git -C "$repo2" checkout -- .
out=$(run_statusline "$repo2" | strip_ansi)
assert_no_match "$default_branch clean shows no diff" "$out" '\+[0-9]'

echo ""
echo "--- Non-git directory: no crash ---"
nogit="$TEST_DIR/nogit"
mkdir -p "$nogit"
out=$(run_statusline "$nogit" | strip_ansi)
assert_match "non-git dir shows dir name only" "$out" "^nogit$"

# ═══════════════════════════════════════════════════════════════════
echo ""
echo "=== Diff includes uncommitted changes ==="
# ═══════════════════════════════════════════════════════════════════

repo3=$(setup_repo "uncommitted")
git -C "$repo3" checkout -q password-reset

echo "unstaged" >> "$repo3/f.txt"
out=$(run_statusline "$repo3" | strip_ansi)
assert_match "includes unstaged changes" "$out" '\+2 -0'

echo "staged" >> "$repo3/f.txt"
git -C "$repo3" add f.txt
out=$(run_statusline "$repo3" | strip_ansi)
assert_match "includes staged changes" "$out" '\+3 -0'

# ═══════════════════════════════════════════════════════════════════
echo ""
echo "=== Untracked files count as insertions ==="
# ═══════════════════════════════════════════════════════════════════

repo4=$(setup_repo "untracked")
git -C "$repo4" checkout -q password-reset

printf "line1\nline2\nline3\n" > "$repo4/new-file.txt"
out=$(run_statusline "$repo4" | strip_ansi)
assert_match "untracked file lines counted as insertions" "$out" '\+4 -0'

# ═══════════════════════════════════════════════════════════════════
echo ""
echo "=== Substantive vs total filtering ==="
# ═══════════════════════════════════════════════════════════════════

repo5=$(setup_repo "filtering")
git -C "$repo5" checkout -q password-reset

printf "test1\ntest2\n" > "$repo5/foo.test.ts"
printf "spec1\nspec2\nspec3\n" > "$repo5/bar.spec.js"
printf "real1\n" > "$repo5/real.ts"
git -C "$repo5" add . && git -C "$repo5" commit -q -m "with tests"
out=$(run_statusline "$repo5" | strip_ansi)
# substantive: pw(1) + real.ts(1) = +2, total: pw(1) + test(2) + spec(3) + real(1) = +7
assert_match "substantive count excludes test files" "$out" '\+2 -0'
assert_match "total count shown in parens" "$out" '\(\+7 -0\)'

echo ""
echo "--- Lock files excluded from substantive ---"
repo6=$(setup_repo "lockfiles")
git -C "$repo6" checkout -q password-reset
printf "dep1\ndep2\n" > "$repo6/package-lock.json"
git -C "$repo6" add . && git -C "$repo6" commit -q -m "with lock"
out=$(run_statusline "$repo6" | strip_ansi)
assert_match "substantive excludes lock files" "$out" '\+1 -0'
assert_match "total includes lock files" "$out" '\(\+3 -0\)'

echo ""
echo "--- All changes substantive: no parens ---"
repo7=$(setup_repo "all-substantive")
git -C "$repo7" checkout -q password-reset
printf "code\n" > "$repo7/app.ts"
git -C "$repo7" add . && git -C "$repo7" commit -q -m "real code"
out=$(run_statusline "$repo7" | strip_ansi)
assert_match "shows single stat" "$out" '\+2 -0'
# Match parens with digits inside (diff parens), not branch name parens
assert_no_match "no parens when all substantive" "$out" '\(\+[0-9]'

# ═══════════════════════════════════════════════════════════════════
echo ""
echo "=== Color thresholds ==="
# ═══════════════════════════════════════════════════════════════════

repo8=$(setup_repo "colors")
git -C "$repo8" checkout -q password-reset

# Small change (<=100): green (ANSI code 32)
out_raw=$(run_statusline "$repo8")
assert_match "small diff is green" "$out_raw" $'\x1b\\[32m'

# Medium change (<=500): generate ~200 substantive lines
for i in $(seq 1 200); do echo "line$i" >> "$repo8/big.ts"; done
git -C "$repo8" add . && git -C "$repo8" commit -q -m "medium"
out_raw=$(run_statusline "$repo8")
assert_match "medium diff is yellow" "$out_raw" $'\x1b\\[33m'

# Large change (>500): generate ~500 more lines
for i in $(seq 1 400); do echo "more$i" >> "$repo8/big.ts"; done
git -C "$repo8" add . && git -C "$repo8" commit -q -m "large"
out_raw=$(run_statusline "$repo8")
assert_match "large diff is red" "$out_raw" $'\x1b\\[31m'

# ═══════════════════════════════════════════════════════════════════
echo ""
echo "=== Results ==="
echo "  $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
