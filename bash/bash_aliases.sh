#!/usr/bin/env bash

if [ -x /usr/bin/dircolors ]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi

  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias t='type'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Show PATH line by line
path() {
  tr ':' '\n' <<< "$PATH"
}

# Find files/directories
ff() {
	local targ="$1"
	local dest="${2:-$PWD}"
  find "$dest" -type f -iname "*$targ*"
}

fd() {
	local targ="$1"
	local dest="${2:-$PWD}"
  find "$dest" -type d -iname "*$targ*"
}
