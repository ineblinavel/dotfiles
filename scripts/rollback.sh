#!/usr/bin/env bash
set -Eeuo pipefail
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
manifest="$STATE_HOME/last-backups.tsv"
[[ -s "$manifest" ]] || { echo 'Nenhum backup de instalação encontrado.'; exit 0; }

if [[ "${1:-}" != --yes ]]; then
  echo 'Backups que serão restaurados:'
  awk -F '\t' '{printf "  %s -> %s\n", $1, $2}' "$manifest"
  echo 'Execute novamente com --yes para confirmar.'
  exit 0
fi

while IFS=$'\t' read -r backup target; do
  [[ -e "$backup" ]] || { echo "Backup ausente: $backup" >&2; continue; }
  [[ -L "$target" ]] && rm -- "$target"
  [[ -e "$target" ]] && { echo "Destino ocupado, não restaurado: $target" >&2; continue; }
  mv -- "$backup" "$target"
  echo "Restaurado: $target"
done < "$manifest"
mv -- "$manifest" "$manifest.restored-$(date +%Y%m%d-%H%M%S)"
