#!/bin/zsh

function notes() {
    local notes_dir="$HOME/notes"
    cd "$notes_dir"

  # local note_path="$notes_dir/**/${1}.md"
  local note_path=$(find "$notes_dir" -type f -name "*.md" -path "*/$1.md" -print -quit)
  echo "${note_path}"

  # If no arguments are provided, open the notes directory in vim
  if [ $# -eq 0 ]; then
      nvim .
  else
      # Check if the note file exists
      if [ -f "$note_path" ]; then
          vim "$note_path"
      else
          echo "Note not found: $1"
      fi
  fi
}

# Define a completion function for the note_path argument
function _note_path_complete() {
    # Use the compadd command to add the suggestions
    compadd $(ls $HOME/notes/)
}

# Bind the completion function to the notes function
compdef _note_path_complete notes
