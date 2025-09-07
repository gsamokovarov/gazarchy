source ~/.local/share/omarchy/default/bash/rc

# Ensure gazarchy and other custom utlities from ~/bin are exported.
export PATH=$PATH:~/bin

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
    command git $*
  fi
}

# Rage quit everywhere.
alias Q=exit

# Custom old-man setup
alias v="nvim -u ~/.oldvimrc -p"
alias vim="nvim -u ~/.oldvimrc -p"

# Don't even bother with old vi.
alias vi=nvim

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
