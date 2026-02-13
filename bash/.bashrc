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

# source local_env to get machine specific environtment variables sourced
[ -f ~/.local_env ] && source ~/.local_env

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

eval "$(starship init bash)"
eval "$(zoxide init bash)"

export PATH=$PATH:/usr/local/bin
