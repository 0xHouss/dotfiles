# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias resource="source ~/.bashrc"
alias fman="compgen -c | fzf | xargs man"
alias stow="stow -t ~"
alias vmux="tmuxifier load-session vmux"
alias t="tmux"
alias tl="tmux ls"
alias ta="tmux attach"
alias y="yazi"
alias n="nvim"

. "$HOME/.local/share/../bin/env"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="/usr/bin/core_perl:$PATH"
export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"


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
OMARCHY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots";
