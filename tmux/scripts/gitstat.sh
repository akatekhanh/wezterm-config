#!/usr/bin/env bash
# Output " branch*" for the git repo at $1 (empty if not a repo). "*" = dirty.
dir="${1:-.}"
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[[ -z "$branch" ]] && exit 0
dirty=""
[[ -n "$(git -C "$dir" status --porcelain 2>/dev/null | head -1)" ]] && dirty="*"
printf " %s%s" "$branch" "$dirty"
