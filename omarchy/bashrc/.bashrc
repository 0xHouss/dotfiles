# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
alias resource="source ~/.bashrc"
alias fman="compgen -c | fzf | xargs man"
alias stow="stow -t ~"
alias vmux="tmuxifier load-session vmux"
alias t="tmux"
alias tl="tmux ls"
alias ta="tmux attach"
alias n="nvim"
alias lg="lazygit"

alias dot="cd ~/dotfiles/omarchy/"
alias om="cd ~/.local/share/omarchy/"
alias obs="cd ~/Vaults/Second\ Brain/"

# pnpm
export PNPM_HOME="/home/houss/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
# yazi end

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Environment variables
export PATH="/home/houss/perl5/bin${PATH:+:${PATH}}";
export PATH="/usr/bin/core_perl:$PATH"
export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PERL5LIB="/home/houss/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}";
export PERL_LOCAL_LIB_ROOT="/home/houss/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}";
export PERL_MB_OPT="--install_base \"/home/houss/perl5\"";
export PERL_MM_OPT="INSTALL_BASE=/home/houss/perl5";
export MANPAGER="nvim +Man!"

# deno env
. "/home/houss/.deno/env"
