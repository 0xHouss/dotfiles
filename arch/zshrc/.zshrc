# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/clipboard.zsh
zinit snippet OMZP::sudo
zinit snippet OMZP::extract
zinit snippet OMZP::copypath
zinit snippet OMZP::copyfile
zinit snippet OMZP::dirhistory
zinit snippet OMZP::command-not-found
zinit snippet OMZP::archlinux

# zinit snippet OMZL::git.zsh
# zinit snippet OMZP::git

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons=always --no-filesize --no-time --no-user --no-permissions -l $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons=always --no-filesize --no-time --no-user --no-permissions -l $realpath'
zstyle ':fzf-tab:complete:tssh:*' fzf-flags '--height=5'
zstyle ':fzf-tab:complete:tssh:*' fzf-preview \
'tssh --list-hosts | jq -r --arg alias "$word" ".[] | select(.Alias == \$alias) | \"Host: \(.Host)\nPort: \(.Port)\nUser: \(.User)\""'


# Aliases
alias ls="eza --color=always --long --icons=always --no-filesize --no-time --no-user --no-permissions"
alias lsa="eza --color=always --long --icons=always --no-filesize --no-time --no-user --no-permissions --all"
alias l="eza --color=always --long --git --icons=always"
alias la="eza --color=always --long --git --icons=always --all"
alias lt="eza --tree --icons=always"
alias lta="eza --tree --icons=always --all"

alias upup="yay -Syu --noconfirm && sudo pacman -Sc --noconfirm && yay -Sc --noconfirm"
alias yayy="yay --noconfirm"

alias fman="compgen -c | fzf | xargs man"
alias stow="stow -t ~"
alias resource="source ~/.zshrc"

alias v="nvim"
alias vh="nvim ."
alias vmux="tmuxifier load-session vmux"

alias t="tmux"
alias tl="tmux ls"
alias ta="tmux attach"
alias y="yazi"
alias z="zoxide"

# Environment variables
export PNPM_HOME="$HOME/.local/share/pnpm"
export ANDROID_HOME="/opt/android-sdk"

export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$HOME/.local/bin"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(tmuxifier init -)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# fzf
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza --tree --color=always --level=4 {}; else bat --style=numbers --color=always {}; fi'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=always {}'"
# fzf end

# tssh
tssh() {
  if [[ "$1" == "-n" ]]; then # custom flag for new host
    shift
    command tssh --new-host "$@"
  else
    command tssh "$@"
  fi
}

_tssh_completions() {
  local -a items
  items=($(tssh --list-hosts | jq -r '.[].Alias'))

  compadd -- "$@" "${items[@]}"
}

compdef _tssh_completions tssh # Add tssh completions
# tssh end
