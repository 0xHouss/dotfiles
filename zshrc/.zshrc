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

PATH="/home/houss/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/houss/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/houss/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/houss/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/houss/perl5"; export PERL_MM_OPT;
