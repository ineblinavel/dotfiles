#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
echo "Repositório: $ROOT"
echo "Branch: $(git -C "$ROOT" branch --show-current)"
git -C "$ROOT" status --short
echo
for path in "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.config/git/config" "$HOME/.config/kitty"; do
  if [[ -L "$path" ]]; then printf 'link  %s -> %s\n' "$path" "$(readlink "$path")"
  elif [[ -e "$path" ]]; then printf 'local %s\n' "$path"
  else printf 'falta %s\n' "$path"; fi
done
