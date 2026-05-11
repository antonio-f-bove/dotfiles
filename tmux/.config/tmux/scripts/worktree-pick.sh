#!/usr/bin/env bash
set -euo pipefail

wt=${1-}
if [ -z "$wt" ]; then
  set +e
  wt="$({
    git worktree list --porcelain |
      awk '/^worktree /{print substr($0,10)}'
  } | fzf-tmux -p 55%,60% --border-label ' worktrees ' --prompt '  ')"
  status=$?
  set -e

  case "$status" in
    0) ;;
    1|130) exit 0 ;;
    *) exit "$status" ;;
  esac
fi

[ -n "$wt" ] || exit 0

wt_q=$(printf '%q' "$wt")
tmux command-prompt -p 'Append subdir (empty = root)' \
  "run-shell 'base=$wt_q; suffix=\"%%\"; suffix=\${suffix#/}; target=\${base%/}; [ -n \"\$suffix\" ] && target=\"\$target/\$suffix\"; if [ ! -d \"\$target\" ]; then tmux display-message \"missing dir: \$target\"; exit 1; fi; exec sesh connect \"\$target\"'"
