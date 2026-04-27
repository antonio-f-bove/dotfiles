#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Check if Windows interop is working
if ! /mnt/c/Windows/System32/cmd.exe /c "exit" &> /dev/null; then
    echo "Warning: Windows Interop is broken. You may need to run 'wsl --shutdown' from PowerShell."
fi

export EDITOR=nvim
export MANPAGER='nvim +Man!'

# aliases
alias g=git
alias v=nvim
# alias ls='ls --color=auto'
alias ls='eza --all --grid --icons'
# alias ll='ls --color=auto -latr'
alias ll='eza -al'
alias grep='grep --color=auto'
alias cpc='xsel --input --clipboard'
alias fzcp='fzf | xsel --input --clipboard'
alias ..='cd .. && ll'
alias ...='cd ../.. && ll'
alias ....='cd ../../.. && ll'

# functions
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function wmv() {
	if [ "$#" -ne 2 ]; then
		echo "usage: wmv <windows-path> <relative-destination>" >&2
		return 1
	fi

	local src dst
	src="$(wslpath -u -- "$1")" || return 1
	dst="$PWD/$2"
	mv -- "$src" "$dst"
}

# vim motions are the best!
set -o vi

# PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
eval "$(zoxide init bash)"

# source local_env to get machine specific environtment variables sourced
# [ -f ~/.local_env ] && source ~/.local_env
export NOTES_HOME="$HOME/notes"
# TODO: auto git pull notes repo

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# pnpm
export PNPM_HOME="/home/anto/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="$PATH:/home/anto/.turso"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export FLYCTL_INSTALL="/home/anto/.fly"
export PATH=$FLYCTL_INSTALL/bin:$PATH

. "$HOME/.cargo/env"

export PATH=$PATH:/usr/local/bin

export PATH="$HOME/.local/bin:$PATH"
