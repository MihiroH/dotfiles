#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Get basename of current directory (equivalent to zsh %c)
current_dir=$(basename "$cwd")

# Awk pattern for non-substantive files (tests, locks, generated, snapshots)
FILTER='/\.(lock|snap)$/ || /package-lock\.json/ || /pnpm-lock\.yaml/ || /yarn\.lock/ || /\.test\./ || /\.spec\./ || /_test\./ || /_spec\./ || /\/__snapshots__\// || /\.generated\./'

# Get git branch if in a git repo (equivalent to __git_ps1)
git_branch=""
diff_stats=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch=$(printf " \033[38;2;58;148;197m(%s)\033[0m" "$branch")

        # Detect base branch to diff against
        base=""
        is_default_branch=false
        for default in main master develop; do
            if [ "$branch" = "$default" ]; then
                is_default_branch=true
                break
            fi
        done

        if [ "$is_default_branch" = true ]; then
            # Default branches: diff against remote tracking branch
            upstream=$(git -C "$cwd" rev-parse --abbrev-ref "@{upstream}" 2>/dev/null)
            if [ -n "$upstream" ]; then
                base="$upstream"
            fi
        else
            # Feature branches: check explicit config, PR base (cached), or merge-base heuristic
            git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
            cache_file="$git_dir/.statusline-base-$(echo "$branch" | tr '/' '-')"

            # 1. Explicit git config: git config branch.<name>.base <parent-branch>
            base=$(git -C "$cwd" config "branch.$branch.base" 2>/dev/null)

            if [ -z "$base" ]; then
                # 2. Cached base (< 5 minutes) — covers both PR and heuristic results
                if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null))) -lt 300 ]; then
                    base=$(cat "$cache_file")
                else
                    # Try gh pr view for exact PR base
                    pr_base=$(cd "$cwd" && gh pr view --json baseRefName -q .baseRefName 2>/dev/null)
                    if [ -n "$pr_base" ]; then
                        base="$pr_base"
                        echo "$base" > "$cache_file" 2>/dev/null
                    fi
                fi
            fi

            if [ -z "$base" ]; then
                # 3. Heuristic: merge-base analysis
                # A parent's tip is on our first-parent ancestry. A child's tip diverges.
                head_sha=$(git -C "$cwd" rev-parse HEAD 2>/dev/null)
                same_base=""
                ahead_base="" ahead_best=""
                dist_base="" dist_best=""
                while IFS= read -r candidate; do
                    [ "$candidate" = "$branch" ] && continue
                    mb=$(git -C "$cwd" merge-base HEAD "$candidate" 2>/dev/null) || continue
                    if [ "$mb" = "$head_sha" ]; then
                        ahead=$(git -C "$cwd" rev-list --count "HEAD..$candidate" 2>/dev/null) || continue
                        if [ "$ahead" -eq 0 ]; then
                            # Same commit as HEAD: likely the parent we branched from
                            same_base="$candidate"
                            continue
                        fi
                        if [ -z "$ahead_best" ] || [ "$ahead" -lt "$ahead_best" ]; then
                            ahead_best="$ahead"
                            ahead_base="$candidate"
                        fi
                    else
                        # Check if candidate tip is on our first-parent path (parent, not child)
                        candidate_sha=$(git -C "$cwd" rev-parse "$candidate" 2>/dev/null)
                        git -C "$cwd" merge-base --is-ancestor "$candidate_sha" HEAD 2>/dev/null || continue
                        # Verify it's on the first-parent path (not a merged side branch)
                        git -C "$cwd" log --first-parent --format='%H' HEAD 2>/dev/null | grep -q "^$candidate_sha$" || continue
                        dist=$(git -C "$cwd" rev-list --count "$mb..HEAD" 2>/dev/null) || continue
                        if [ -z "$dist_best" ] || [ "$dist" -lt "$dist_best" ]; then
                            dist_best="$dist"
                            dist_base="$candidate"
                        fi
                    fi
                done < <(git -C "$cwd" for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)

                # Check if branch has own commits (via reflog)
                own_commits=$(git -C "$cwd" reflog show "$branch" --format='%gs' 2>/dev/null | grep -c "^commit" || true)

                if [ "$own_commits" -eq 0 ] && [ -n "$same_base" ]; then
                    base="$same_base"
                elif [ "$own_commits" -eq 0 ] && [ -n "$ahead_base" ]; then
                    base="$ahead_base"
                elif [ -n "$dist_base" ]; then
                    base="$dist_base"
                elif [ -n "$ahead_base" ]; then
                    base="$ahead_base"
                fi

                # Cache heuristic result to avoid re-running the loop
                if [ -n "$base" ]; then
                    echo "$base" > "$cache_file" 2>/dev/null
                fi
            fi
        fi

        if [ -n "$base" ]; then
            merge_base=$(git -C "$cwd" merge-base "$base" HEAD 2>/dev/null)
            if [ -n "$merge_base" ]; then
                # Diff merge-base against working tree (committed + staged + unstaged)
                numstat=$(git -C "$cwd" diff --numstat "$merge_base" 2>/dev/null)

                # List untracked files once, compute both all and substantive line counts
                untracked_files=$(cd "$cwd" && git ls-files --others --exclude-standard 2>/dev/null)
                ut_all_lines=0
                ut_sub_lines=0
                if [ -n "$untracked_files" ]; then
                    ut_all_lines=$(cd "$cwd" && echo "$untracked_files" | tr '\n' '\0' | xargs -0 wc -l 2>/dev/null | tail -1 | awk '{print $1+0}')
                    ut_sub_lines=$(echo "$untracked_files" | awk "$FILTER { next } { print }" | (cd "$cwd" && tr '\n' '\0' | xargs -0 wc -l 2>/dev/null) | tail -1 | awk '{print $1+0}')
                fi

                stats=$(echo "$numstat" | awk -v ut_all="$ut_all_lines" -v ut_sub="$ut_sub_lines" '
                    {
                        i = ($1 != "-") ? $1 : 0; d = ($2 != "-") ? $2 : 0
                        all_ins += i; all_del += d
                        f = $3
                        if (f ~ /\.(lock|snap)$/ || f ~ /package-lock\.json/ || f ~ /pnpm-lock\.yaml/ || f ~ /yarn\.lock/ ||
                            f ~ /\.test\./ || f ~ /\.spec\./ || f ~ /_test\./ || f ~ /_spec\./ ||
                            f ~ /\/__snapshots__\// || f ~ /\.generated\./) { next }
                        sub_ins += i; sub_del += d
                    }
                    END {
                        print all_ins+ut_all+0, all_del+0, sub_ins+ut_sub+0, sub_del+0
                    }
                ')
                read all_ins all_del sub_ins sub_del <<< "$stats"
                sub_total=$((sub_ins + sub_del))
                all_total=$((all_ins + all_del))

                if [ "$all_total" -gt 0 ]; then
                    # Color based on substantive change thresholds
                    # <=100: green, <=500: yellow, >500: red
                    if [ "$sub_total" -le 100 ]; then
                        color="32" # green
                    elif [ "$sub_total" -le 500 ]; then
                        color="33" # yellow
                    else
                        color="31" # red
                    fi
                    # Substantive stats colored, total stats dimmed
                    if [ "$sub_total" -ne "$all_total" ]; then
                        diff_stats=$(printf " \033[%sm+%d -%d\033[0m \033[2m(+%d -%d)\033[0m" "$color" "$sub_ins" "$sub_del" "$all_ins" "$all_del")
                    else
                        diff_stats=$(printf " \033[%sm+%d -%d\033[0m" "$color" "$all_ins" "$all_del")
                    fi
                fi
            fi
        fi
    fi
fi

# Output the status line
printf "%s%s%s" "$current_dir" "$git_branch" "$diff_stats"
