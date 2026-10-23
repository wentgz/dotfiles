#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$HOME/.config/dotfiles"
readonly BASHRC="$HOME/.bashrc"

INSTALL_VIM_PLUG=false

# Use colors only when output is a terminal.
if [[ -t 1 ]]; then
  readonly GREEN=$'\033[0;32m'
  readonly YELLOW=$'\033[0;33m'
  readonly RED=$'\033[0;31m'
  readonly BLUE=$'\033[0;34m'
  readonly RESET=$'\033[0m'
else
  readonly GREEN=''
  readonly YELLOW=''
  readonly RED=''
  readonly BLUE=''
  readonly RESET=''
fi

log_ok() {
  printf '%s[ OK ]%s %s\n' "$GREEN" "$RESET" "$*"
}

log_skip() {
  printf '%s[SKIP]%s %s\n' "$YELLOW" "$RESET" "$*"
}

log_info() {
  printf '%s[INFO]%s %s\n' "$BLUE" "$RESET" "$*"
}

log_error() {
  printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$*" >&2
}

log_section() {
  printf '\n%s==> %s%s\n' "$BLUE" "$*" "$RESET"
}

usage() {
  printf 'Usage: %s [-v|--vim-plug]\n' "$0"
}

for arg in "$@"; do
  case "$arg" in
    -v|--vim-plug)
      INSTALL_VIM_PLUG=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $arg"
      usage >&2
      exit 1
      ;;
  esac
done

install_bash_configs() {
  local source_dir="$REPO_DIR/bash"
  local target_dir="$DOTFILES_DIR/bash"
  local file
  local found=false

  log_section "Bash configs"

  if [[ ! -d "$source_dir" ]]; then
    log_skip "Source directory not found: $source_dir"
    return 0
  fi

  mkdir -p "$target_dir"

  for file in "$source_dir"/*.sh; do
    [[ -f "$file" ]] || continue
    found=true

    log_info "Found source file: $file"
    cp "$file" "$target_dir/"
    log_ok "Copied to: $target_dir/$(basename "$file")"
  done

  if [[ "$found" == false ]]; then
    log_skip "No .sh files found in: $source_dir"
  fi
}

install_tmux_config() {
  local source="$REPO_DIR/tmux/.tmux.conf"
  local target_dir="$DOTFILES_DIR/tmux"
  local target="$target_dir/.tmux.conf"

  log_section "tmux config"

  if [[ ! -f "$source" ]]; then
    log_skip "Source file not found: $source"
    return 0
  fi

  log_info "Found source file: $source"
  mkdir -p "$target_dir"

  cp "$source" "$target"
  log_ok "Copied to: $target"

  ln -sfn "$target" "$HOME/.tmux.conf"
  log_ok "Symlink created: $HOME/.tmux.conf -> $target"
}

install_vim_config() {
  local source="$REPO_DIR/vim/.vimrc"
  local target_dir="$DOTFILES_DIR/vim"
  local target="$target_dir/.vimrc"

  log_section "Vim config"

  if [[ ! -f "$source" ]]; then
    log_skip "Source file not found: $source"
    return 0
  fi

  log_info "Found source file: $source"
  mkdir -p "$target_dir"

  cp "$source" "$target"
  log_ok "Copied to: $target"

  ln -sfn "$target" "$HOME/.vimrc"
  log_ok "Symlink created: $HOME/.vimrc -> $target"
}

install_vim_plug() {
  local vim_plug="$HOME/.vim/autoload/plug.vim"

  log_section "vim-plug"

  if [[ -f "$vim_plug" ]]; then
    log_skip "Already installed: $vim_plug"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required to install vim-plug."
    exit 1
  fi

  log_info "Installing vim-plug to: $vim_plug"

  curl -fLo "$vim_plug" \
    --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  log_ok "Installed: $vim_plug"
}

install_vim_plugins() {
  local vimrc="$HOME/.vimrc"

  log_section "Vim plugins"

  if ! command -v vim >/dev/null 2>&1; then
    log_error "Vim is not installed."
    exit 1
  fi

  if [[ ! -f "$vimrc" ]]; then
    log_skip "Vim config not found: $vimrc"
    return 0
  fi

  log_info "Using Vim: $(command -v vim)"
  log_info "Using config: $vimrc"

  if ! grep -qE '^[[:space:]]*Plug[[:space:]]' "$vimrc"; then
    log_skip "No Plug declarations found in: $vimrc"
    return 0
  fi

  log_info "Running PlugInstall..."
  vim +'PlugInstall --sync' +qall

  log_ok "Vim plugins installed."
}

configure_fzf() {
  local block_start="# >>> dotfiles fzf >>>"
  local block_end="# <<< dotfiles fzf <<<"

  log_section "fzf shell integration"

  touch "$BASHRC"

  if grep -qF "$block_start" "$BASHRC"; then
    log_skip "fzf block already exists in: $BASHRC"
    return 0
  fi

  cat >> "$BASHRC" <<EOF

$block_start

if [[ -x "\$HOME/.vim/plugged/fzf/bin/fzf" ]]; then
  export PATH="\$HOME/.vim/plugged/fzf/bin:\$PATH"

  [[ -r "\$HOME/.vim/plugged/fzf/shell/key-bindings.bash" ]] &&
    source "\$HOME/.vim/plugged/fzf/shell/key-bindings.bash"

  [[ -r "\$HOME/.vim/plugged/fzf/shell/completion.bash" ]] &&
    source "\$HOME/.vim/plugged/fzf/shell/completion.bash"
fi

$block_end

EOF

  log_ok "Added fzf block to: $BASHRC"
}

configure_bashrc() {
  local block_start="# >>> dotfiles bash >>>"
  local block_end="# <<< dotfiles bash <<<"

  log_section "Bash config loading"

  touch "$BASHRC"

  if grep -qF "$block_start" "$BASHRC"; then
    log_skip "Dotfiles Bash block already exists in: $BASHRC"
    return 0
  fi

  cat >> "$BASHRC" <<EOF

$block_start

for file in "\$HOME/.config/dotfiles/bash"/*.sh; do
  [[ -r "\$file" ]] && source "\$file"
done

$block_end

EOF

  log_ok "Added Bash config loading block to: $BASHRC"
  log_info "Bash config files will be sourced when .bashrc is loaded."
}

main() {
  log_info "Dotfiles repository: $REPO_DIR"
  log_info "Install destination: $DOTFILES_DIR"

  mkdir -p "$DOTFILES_DIR"

  install_bash_configs
  install_tmux_config
  install_vim_config

  if [[ "$INSTALL_VIM_PLUG" == true ]]; then
    install_vim_plug
    install_vim_plugins
  else
    log_skip "vim-plug installation not requested. Use --vim-plug to enable it."
  fi

  configure_bashrc

  if [[ "$INSTALL_VIM_PLUG" == true ]]; then
    configure_fzf
  else
    log_skip "fzf shell integration not configured because --vim-plug was not used."
  fi

  printf '\n'
  log_ok "Dotfiles installation completed."
  log_info "To load Bash config files in this shell, run: source \"$BASHRC\""
}

main "$@"
