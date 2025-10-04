source ~/.local/share/omarchy/default/bash/rc

# Ensure gazarchy and other custom utlities from ~/bin are exported.
# Use neovim version from bob as I'm hitting https://github.com/neovim/neovim/issues/33067.
export PATH=$PATH:~/bin:~/.local/share/bob/nvim-bin

# Jump is better!
eval "$(jump shell bash)"

# Use git with a twist -- if the first argument is an existing branch
# then switch to it. If no args are given, run git status.
git() {
  local target_branch=$1

  if [ $# -eq 1 ] && [ -e "$(command git rev-parse --git-dir 2>/dev/null)/refs/heads/$target_branch" ]; then
    command git checkout $target_branch
  elif [ $# -eq 0 ]; then
    command git status
  else
    case "$1" in
      ]) shift; command git push "$@" ;;
      [) shift; command git pull "$@";;
      +) shift; command git add "$@";;
      -) shift; command git rm "$@";;
      *) command git "$@" ;;
    esac
  fi
}

# Rage quit everywhere.
alias Q=exit

# Don't even bother with old vi.
alias vi=nvim

# All them vimkeys
alias v=nvim
alias vim=nvim

# Some systems may not be happy with the $TERM of screen-256colors, so be sane.
alias ssh="TERM=xterm ssh"

alias g=git
alias m=make

alias be='bundle exec'

# Dot aliases.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# I never learned how to type freakin' killall.
alias kilalll=killall
alias kilall=killall

# Do it by default. Don't let me think about it.
alias mkdir='mkdir -p'

# Git subcommands shortcuts.
alias gc='git commit'
alias gco='git commit'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gl='git short'
alias gs='git status'
alias ga='git commit --amend'

alias g[='git push'
alias g]='git pull'
alias g+='git add'
alias g-='git rm'

# Bundle shortcuts.
alias b='bundle'
alias bu='bundle update'
alias br='bundle exec rails'
alias brat='bundle exec rails test'
alias bo='bundle open'
alias bi='bundle install'
alias bam='bundle exec middleman'
