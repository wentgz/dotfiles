# Session helpers
alias tls='tmux list-sessions'
alias tnew='tmux new-session -s'
alias tatt='tmux attach-session -t'
alias tsw='tmux switch-client -t'
alias tkill='tmux kill-session -t'
alias tkillall='tmux kill-server'

# Window helpers
alias tw='tmux list-windows'
alias twn='tmux new-window'
alias twr='tmux rename-window'
alias twk='tmux kill-window'

# Pane helpers
alias tp='tmux list-panes'
alias tpn='tmux split-window -v'
alias tpr='tmux split-window -h'
alias tpk='tmux kill-pane'
alias tpres='tmux resize-pane'
alias tsync='tmux setw synchronize-panes'

# Attach to a session, creating it when absent.
ta() {
  if [ "$#" -eq 0 ]; then
    tmux new-session -A -s main
  else
    tmux new-session -A -s "$1"
  fi
}
