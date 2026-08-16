command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
[[ -r "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[[ -r "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"

# Gerenciadores pesados são carregados na primeira utilização.
lazy_source() {
  local command_name="$1" init_file="$2"
  eval "$command_name() { unfunction $command_name; source \"$init_file\"; $command_name \"\$@\"; }"
}
[[ -r "$HOME/.nvm/nvm.sh" ]] && lazy_source nvm "$HOME/.nvm/nvm.sh"
if [[ -r "$HOME/.nvm/nvm.sh" ]]; then
  for nvm_command in node npm npx; do
    command -v "$nvm_command" >/dev/null 2>&1 || lazy_source "$nvm_command" "$HOME/.nvm/nvm.sh"
  done
fi
[[ -r "$HOME/.sdkman/bin/sdkman-init.sh" ]] && lazy_source sdk "$HOME/.sdkman/bin/sdkman-init.sh"

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
  path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init -)"
fi
