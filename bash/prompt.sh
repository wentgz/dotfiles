#!/usr/bin/env bash

# Debian/Ubuntu chroot name
if [[ -z ${debian_chroot:-} && -r /etc/debian_chroot ]]; then
  IFS= read -r debian_chroot < /etc/debian_chroot
fi

# Colors
if [[ $TERM == xterm-color || $TERM == *-256color ]]; then
	# Reset and styles
	C_RESET='\[\e[0m\]'
	C_BOLD='\[\e[1m\]'
	C_DIM='\[\e[2m\]'
	C_UNDERLINE='\[\e[4m\]'

	# Normal colors
	C_BLACK='\[\e[30m\]'
	C_RED='\[\e[31m\]'
	C_GREEN='\[\e[32m\]'
	C_YELLOW='\[\e[33m\]'
	C_BLUE='\[\e[34m\]'
	C_MAGENTA='\[\e[35m\]'
	C_CYAN='\[\e[36m\]'
	C_WHITE='\[\e[37m\]'

	# Bright colors
	C_GRAY='\[\e[90m\]'
	C_BRIGHT_RED='\[\e[91m\]'
	C_BRIGHT_GREEN='\[\e[92m\]'
	C_BRIGHT_YELLOW='\[\e[93m\]'
	C_BRIGHT_BLUE='\[\e[94m\]'
	C_BRIGHT_MAGENTA='\[\e[95m\]'
	C_BRIGHT_CYAN='\[\e[96m\]'
	C_BRIGHT_WHITE='\[\e[97m\]'
else
	C_RESET=''
	C_BOLD=''
	C_DIM=''
	C_UNDERLINE=''

	C_BLACK=''
	C_RED=''
	C_GREEN=''
	C_YELLOW=''
	C_BLUE=''
	C_MAGENTA=''
	C_CYAN=''
	C_WHITE=''

	C_GRAY=''
	C_BRIGHT_RED=''
	C_BRIGHT_GREEN=''
	C_BRIGHT_YELLOW=''
	C_BRIGHT_BLUE=''
	C_BRIGHT_MAGENTA=''
	C_BRIGHT_CYAN=''
	C_BRIGHT_WHITE=''
fi

# Git branch
__git_branch() {
  local branch

  git rev-parse --is-inside-work-tree &>/dev/null || return

  branch=$(
    git symbolic-ref --quiet --short HEAD 2>/dev/null ||
    git rev-parse --short HEAD 2>/dev/null
  )

  [[ -n $branch ]] && printf '(%s) ' "$branch"
}

# Save the previous command's exit code
__update_prompt_status() {
  local exit_code=$?
	printf -v exit_c '%d' "$exit_code"
}

# Preserve existing PROMPT_COMMAND entries
PROMPT_COMMAND=(
  __update_prompt_status
  "${PROMPT_COMMAND[@]}"
)

# Terminal title
case $TERM in
  xterm*|rxvt*)
    PS1='\[\e]0;\u@\h:\W\a\]'
    ;;
esac

# Main prompt
PS1=''

PS1+="${C_BRIGHT_GREEN}"'\u'"${C_RESET}"' '
PS1+='[exit:'"${C_BRIGHT_YELLOW}"'${exit_c}'"${C_RESET}"'] '
PS1+="${C_BLUE}"'\W'"${C_RESET}"' '
PS1+="${C_BRIGHT_YELLOW}"'$(\__git_branch)'"${C_RESET}"
PS1+='\n$ '
