#!/usr/bin/env bash
set -euo pipefail

mode_file=$(mktemp)
trap 'rm -f "$mode_file"' EXIT
printf 'all' > "$mode_file"

set +e
selection="$({
  sesh list
} | fzf-tmux -p 55%,60% \
  --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
  --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find ^w worktrees' \
  --bind 'tab:down,btab:up' \
  --bind "ctrl-a:change-prompt(⚡  )+execute-silent(printf all > $mode_file)+reload(sesh list)" \
  --bind "ctrl-t:change-prompt(🪟  )+execute-silent(printf tmux > $mode_file)+reload(sesh list -t)" \
  --bind "ctrl-g:change-prompt(⚙️  )+execute-silent(printf config > $mode_file)+reload(sesh list -c)" \
  --bind "ctrl-x:change-prompt(📁  )+execute-silent(printf zoxide > $mode_file)+reload(sesh list -z)" \
  --bind "ctrl-f:change-prompt(🔎  )+execute-silent(printf find > $mode_file)+reload(fd -H -d 2 -t d -E .Trash . ~)" \
  --bind "ctrl-w:change-prompt(  )+execute-silent(printf worktree > $mode_file)+reload(git worktree list --porcelain | awk '/^worktree /{print substr(\$0,10)}')" \
  --bind "ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+execute-silent(printf all > $mode_file)+reload(sesh list)"
)"
status=$?
set -e

case "$status" in
  0) ;;
  1|130) exit 0 ;;
  *) exit "$status" ;;
esac

[ -n "$selection" ] || exit 0

mode=$(cat "$mode_file")
case "$mode" in
  worktree)
    script=${HOME}/.config/tmux/scripts/worktree-pick.sh
    script_q=$(printf '%q' "$script")
    sel_q=$(printf '%q' "$selection")
    tmux run-shell "$script_q $sel_q"
    ;;
  *)
    exec sesh connect "$selection"
    ;;
esac
