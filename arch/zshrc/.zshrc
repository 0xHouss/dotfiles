# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 7

# Uncomment the following line to change the command history execution timestamp
HIST_STAMPS="%d/%m/%Y %H:%M:%S"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  copypath
  copyfile
  dirhistory
  extract
)

source $ZSH/oh-my-zsh.sh

# User configuration
export MANPAGER="nvim +Man!"
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# fzf
source <(fzf --zsh)

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {}'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {}' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range {}" "$@" ;;
  esac
}
# fzf end

# tmuxifier
export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"

eval "$(tmuxifier init -)"
# tmuxifier end

# aliases
alias ls="eza --color=always --long --git --icons=always --no-filesize --no-time --no-user --no-permissions"
alias l="eza --color=always --long --git --icons=always"
alias tree="eza --tree --icons=always"
alias upup="yay -Syu --noconfirm && sudo pacman -Sc --noconfirm && yay -Sc --noconfirm"
alias fman="compgen -c | fzf | xargs man"
alias yayy="yay --noconfirm"
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
# aliases end

# keybindings
bindkey '^l' autosuggest-accept
# keybindings end

# pnpm
export PNPM_HOME="/home/houss/.local/share/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# Load custom scripts
export PATH="$PATH:/home/houss/.local/bin"


# ruby
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
# ruby end

# zoxide
eval "$(zoxide init --cmd cd zsh)"
# zoxide end
