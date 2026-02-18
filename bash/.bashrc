#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR=nvim
export MANPAGER='nvim +Man!'

# aliases
alias g=git
alias v=nvim
alias ls='ls --color=auto'
alias ll='ls --color=auto -latr'
alias grep='grep --color=auto'
alias cpc='xsel --input --clipboard'
alias fzcp='fzf | xsel --input --clipboard'

# functions
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
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
