#!/bin/zsh

# Define 'f' function only if it doesn't already exist
if ! command -v f >/dev/null 2>&1; then
  f() {
    local dir=${1:-.}  # Use current directory if no parameter is provided
    local selected_file

    # List files and directories, pipe into fzf for interactive filtering
    selected_file=$(ls -la "$dir" | awk '{print $9}' | tail -n +4 | fzf)

    if [[ -n "$selected_file" ]]; then
      echo "Selected file: $selected_file"
      read -r "command?Enter a command to execute with the selected file: "

      if [[ -n "$command" ]]; then
        # Execute the entered command with the selected file
        eval "$command" "$selected_file"
      fi
    fi
  }
fi

# f "$@"
