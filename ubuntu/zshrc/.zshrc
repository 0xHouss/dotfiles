export EDITOR="nvim"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load (https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
ZSH_THEME="bira"

source $ZSH/oh-my-zsh.sh

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm end

# pnpm
export PNPM_HOME="/home/houss/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# perl5
PATH="/home/houss/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/houss/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/houss/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/houss/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/houss/perl5"; export PERL_MM_OPT;
# perl5 end

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always {}'"
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
    *)            fzf --preview "batcat -n --color=always --line-range {}" "$@" ;;
  esac
}
# fzf end

# aliases
alias bat="batcat"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias l="eza --color=always --long --git --icons=always"
alias tree="eza --tree --icons=always"
alias up="sudo apt-get update -y && sudo apt-get upgrade -y"
alias fman="compgen -c | fzf | xargs man"
# aliases end

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
