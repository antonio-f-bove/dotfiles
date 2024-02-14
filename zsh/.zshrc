eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

PATH="/usr/local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pyenv-virtualenv plugin
# if which pyenv-virtualenv-init > /dev/null; then 
eval "$(pyenv virtualenv-init -)"
# ; fi

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

### ---- history config ---------------------------------------
export HISTSIZE=10000 # How many commands zsh will load to memory.
export SAVEHIST=10000 # How many commands history will save on file.
setopt HIST_IGNORE_ALL_DUPS # History won't save duplicates.
setopt HIST_FIND_NO_DUPS # History won't show duplicates on search.

# ---- stuff --------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ---- permanent aliases -------------------------------------
# alias zz="cd ${HOME}/.config && nvim zsh/.zshrc"
alias src="source ${HOME}/.zshrc"
alias ll="ls -latrh"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias lg="lazygit"
alias grep="rg"

# tmux
alias ta="tmux attach"
alias tn="tmux new -s"

# nvim
alias v="nvim"
alias vim="nvim"
alias swap="cd ~/.local/state/nvim/swap && ll"
alias sessions="cd ~/.local/share/nvim/sessions && ll"

export MANPAGER='nvim +Man!'

# ---- custom functions --------------------------------------
source ${HOME}/dotfiles/zsh/functions/dbconn.sh
source ${HOME}/dotfiles/zsh/functions/ll.sh
source ${HOME}/dotfiles/zsh/functions/notes.sh
# for file in ${ZDOTDIR}/functions/*.sh; do
#   source "$file"
# done

# ---- plugins -----------------------------------------------
# source $ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# fpath=($ZDOTDIR/plugins/zsh-completions/src $fpath)

export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.2.0/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/anto/code/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/anto/code/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/anto/code/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/anto/code/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

