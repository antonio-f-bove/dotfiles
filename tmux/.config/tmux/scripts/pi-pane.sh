#!/usr/bin/env bash

set -euo pipefail

# tmux pi pane helpers
# This file will host small, testable helper functions for managing the pi pane.

current_session_id() {
  tmux display-message -p '#{session_id}'
}

current_window_id() {
  tmux display-message -p '#{window_id}'
}

current_pane_id() {
  tmux display-message -p '#{pane_id}'
}

current_pane_path() {
  tmux display-message -p '#{pane_current_path}'
}

list_session_panes() {
  local session_id="${1:-$(current_session_id)}"
  tmux list-panes -s -F '#{session_id}|#{window_id}|#{pane_id}|#{pane_active}|#{pane_current_command}' \
    | awk -F'|' -v sid="$session_id" '$1 == sid'
}

find_pi_pane_in_session() {
  local session_id="${1:-$(current_session_id)}"
  list_session_panes "$session_id" | awk -F'|' '$5 == "pi" { print $0; exit }'
}

find_pi_pane_in_current_window() {
  local session_id="${1:-$(current_session_id)}"
  local window_id="${2:-$(current_window_id)}"
  list_session_panes "$session_id" | awk -F'|' -v wid="$window_id" '$2 == wid && $5 == "pi" { print $0; exit }'
}

manage_pi_pane() {
  local session_id window_id pane_id pane_path pi_record pi_pane_id pi_window_id

  session_id="$(current_session_id)"
  window_id="$(current_window_id)"
  pane_id="$(current_pane_id)"
  pane_path="$(current_pane_path)"
  pi_record="$(find_pi_pane_in_session "$session_id")"

  if [[ -n "$pi_record" ]]; then
    pi_window_id="$(awk -F'|' '{print $2}' <<< "$pi_record")"
    pi_pane_id="$(awk -F'|' '{print $3}' <<< "$pi_record")"

    if [[ "$pi_window_id" == "$window_id" ]]; then
      current_window_id="$(current_window_id)"
      pi_pane_path="$(tmux display-message -p -t "$pi_pane_id" '#{pane_current_path}')"
      placeholder_pane_id="$(tmux new-window -d -P -F '#{pane_id}' -c "$pi_pane_path" 'sleep 2147483647')"
      tmux swap-pane -s "$pi_pane_id" -t "$placeholder_pane_id"
      tmux kill-pane -t "$placeholder_pane_id"
      tmux select-window -t "$current_window_id"
    else
      tmux join-pane -h -s "$pi_pane_id" -t "$pane_id"
    fi
  else
    tmux split-window -h -c "$pane_path" 'pi -c'
  fi
}

list_paths_from_cwd() {
  local cwd="$1"
  local pattern="${2:-.}"

  (
    cd "$cwd"
    fd --hidden --follow --exclude .git "$pattern" --strip-cwd-prefix
  )
}

append_slash_to_directories() {
  local base_dir="$1"
  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    if [[ -d "$(realpath -m "$base_dir/$candidate")" ]]; then
      printf '%s/\n' "${candidate%/}"
    else
      printf '%s\n' "$candidate"
    fi
  done
}

fuzzy_filter_paths() {
  local needle="${1:-}"
  awk -v needle="$needle" '
    function fuzzy(haystack, needle,    i, j, c) {
      if (needle == "") return 1
      haystack = tolower(haystack)
      needle = tolower(needle)
      j = 1
      for (i = 1; i <= length(haystack) && j <= length(needle); i++) {
        c = substr(haystack, i, 1)
        if (c == substr(needle, j, 1)) j++
      }
      return j > length(needle)
    }
    fuzzy($0, needle)
  '
}

sort_paths_by_zoxide() {
  local cwd="$1"
  declare -A scores=()
  local score path candidate normalized abs target dir_score

  while read -r score path; do
    [[ -n "${path:-}" ]] || continue
    scores["$path"]="$score"
  done < <(zoxide query -ls --all --base-dir "$cwd" 2>/dev/null || true)

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    normalized="${candidate%/}"
    abs="$(realpath -m "$cwd/$normalized")"
    if [[ -d "$abs" ]]; then
      target="$abs"
    else
      target="$(dirname "$abs")"
    fi
    dir_score="${scores["$target"]:-0}"
    printf '%s\t%s\n' "$dir_score" "$candidate"
  done | sort -t $'\t' -k1,1gr -k2,2 | cut -f2-
}

path_up_one_segment() {
  local query="${1:-}"
  local trimmed parent

  if [[ -z "$query" ]]; then
    printf '\n'
    return
  fi

  trimmed="${query%/}"
  if [[ -z "$trimmed" ]]; then
    printf '/\n'
    return
  fi

  if [[ "$trimmed" != */* ]]; then
    printf '\n'
    return
  fi

  parent="${trimmed%/*}"
  if [[ -z "$parent" ]]; then
    printf '\n'
  else
    printf '%s/\n' "$parent"
  fi
}

tab_complete_or_parent() {
  local query="${1:-}"
  local selected="${2:-}"

  if [[ -n "$selected" ]]; then
    printf '%s\n' "$selected"
  elif [[ -z "$query" ]]; then
    printf '../\n'
  else
    printf '%s../\n' "$query"
  fi
}

list_picker_candidates() {
  local cwd="$1"
  local query="${2:-}"
  local dir_part needle search_dir prefix normalized_query

  normalized_query="$query"
  if [[ "$normalized_query" == ./* ]]; then
    normalized_query="${normalized_query#./}"
  fi

  if [[ -z "$normalized_query" ]]; then
    list_paths_from_cwd "$cwd" \
      | append_slash_to_directories "$cwd" \
      | sort_paths_by_zoxide "$cwd"
    return
  fi

  if [[ "$normalized_query" != */* ]]; then
    list_paths_from_cwd "$cwd" \
      | append_slash_to_directories "$cwd" \
      | fuzzy_filter_paths "$normalized_query" \
      | sort_paths_by_zoxide "$cwd"
    return
  fi

  if [[ "$normalized_query" == */ ]]; then
    dir_part="${normalized_query%/}"
    needle=""
  else
    dir_part="${normalized_query%/*}"
    needle="${normalized_query##*/}"
  fi

  search_dir="$(realpath -m "$cwd/$dir_part")"
  [[ -d "$search_dir" ]] || return 0

  prefix="${dir_part%/}"
  [[ -n "$prefix" ]] && prefix="$prefix/"

  find -L "$search_dir" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) -printf '%P\n' \
    | sort \
    | awk -v prefix="$prefix" '{ print prefix $0 }' \
    | append_slash_to_directories "$cwd" \
    | fuzzy_filter_paths "$needle" \
    | sort_paths_by_zoxide "$cwd"
}

pick_file_for_pi() {
  local cwd="${1:-$(current_pane_path)}"
  local script_path

  script_path="$(realpath "${BASH_SOURCE[0]}")"

  PI_PICKER_CWD="$cwd" \
    fzf \
      --phony \
      --prompt 'file> ' \
      --header 'type a path, including ../.. segments · tab: autocomplete/../ · shift-tab: up' \
      --bind "tab:transform-query:bash '$script_path' __tab-complete '{q}' '{}'" \
      --bind "btab:transform-query:bash '$script_path' __path-up '{q}'" \
      --bind "start:reload:bash '$script_path' __list-files" \
      --bind "change:reload:bash '$script_path' __list-files '{q}'" \
      --height 100% \
      --layout reverse \
      --border
}

pick_file_and_open_pi_pane() {
  local pane_path selected selected_path target_dir

  pane_path="$(current_pane_path)"
  selected="$(pick_file_for_pi "$pane_path")" || return 0
  [[ -n "$selected" ]] || return 0

  selected_path="$(realpath -m "$pane_path/$selected")"

  if [[ -d "$selected_path" ]]; then
    target_dir="$selected_path"
  else
    target_dir="$(dirname "$selected_path")"
  fi

  tmux split-window -h -c "$target_dir" 'pi -c'
}

manage_pi_pane_or_pick_file() {
  local session_id pi_record script_path

  session_id="$(current_session_id)"
  pi_record="$(find_pi_pane_in_session "$session_id")"

  if [[ -n "$pi_record" ]]; then
    manage_pi_pane
  else
    script_path="$(realpath "${BASH_SOURCE[0]}")"
    tmux display-popup -E "bash '$script_path' __pick-file-and-open-pi"
  fi
}

if [[ "${1:-}" == "__list-files" ]]; then
  list_picker_candidates "${PI_PICKER_CWD:?PI_PICKER_CWD is required}" "${2:-}"
  exit 0
fi

if [[ "${1:-}" == "__path-up" ]]; then
  path_up_one_segment "${2:-}"
  exit 0
fi

if [[ "${1:-}" == "__tab-complete" ]]; then
  tab_complete_or_parent "${2:-}" "${3:-}"
  exit 0
fi

if [[ "${1:-}" == "__pick-file-and-open-pi" ]]; then
  pick_file_and_open_pi_pane
  exit 0
fi
