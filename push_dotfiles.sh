#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$SCRIPT_DIR"

usage() {
  cat <<'EOF'
Uso: ./push_dotfiles.sh [--include-gnome] [--push] [mensagem]

Os arquivos gerenciados por symlink já vivem no repositório e não são copiados.
Por padrão, este comando apenas atualiza backups opcionais e cria o commit.
EOF
}

INCLUDE_GNOME=false
DO_PUSH=false
COMMIT_MSG="Atualização de rotina dos dotfiles"

while (($#)); do
  case "$1" in
    --include-gnome) INCLUDE_GNOME=true; shift ;;
    --push) DO_PUSH=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) COMMIT_MSG="$1"; shift ;;
  esac
done

copy_if_not_same() {
  local source_path="$1" target_path="$2" source_real target_real
  [[ -e "$source_path" ]] || { printf '[WARN] Ausente: %s\n' "$source_path" >&2; return; }
  source_real="$(readlink -f "$source_path")"
  target_real="$(readlink -f "$target_path" 2>/dev/null || true)"
  if [[ "$source_real" == "$target_real" ]]; then
    printf '[INFO] Já gerenciado por link: %s\n' "$source_path"
    return
  fi
  mkdir -p "$(dirname "$target_path")"
  cp -a -- "$source_path" "$target_path"
}

# Estes comandos são seguros mesmo antes de o instalador criar os symlinks.
copy_if_not_same "$HOME/.zshrc" "$SCRIPT_DIR/.zshrc"
copy_if_not_same "$HOME/.p10k.zsh" "$SCRIPT_DIR/.p10k.zsh"
copy_if_not_same "$HOME/.oh-my-zsh/custom/aliases.zsh" "$SCRIPT_DIR/custom/aliases.zsh"
copy_if_not_same "$HOME/.oh-my-zsh/custom/env.zsh" "$SCRIPT_DIR/custom/env.zsh"

if [[ "$INCLUDE_GNOME" == true ]]; then
  command -v dconf >/dev/null 2>&1 || { echo '[ERROR] dconf não encontrado' >&2; exit 1; }
  dconf dump / > "$SCRIPT_DIR/gnome/gnome_settings.dconf.new"
  printf '[INFO] Snapshot salvo como gnome_settings.dconf.new para revisão manual.\n'
fi

git add -u
git add -- ".zshrc" ".p10k.zsh" ".github" ".gitattributes" ".editorconfig" ".pre-commit-config.yaml" "custom" "scripts" "config" "lib" "profiles" "features" "packages" "tests" "gnome/settings" "gnome/extensions/manifest-"*.txt "README.md" "versions.lock" "dotfiles" "install.sh" "push_dotfiles.sh"
git add --chmod=+x -- "dotfiles" "install.sh" "push_dotfiles.sh" "scripts/doctor.sh" "scripts/rollback.sh" "scripts/status.sh" "scripts/update.sh" "tests/run.sh" "gnome/settings/common.sh" "gnome/settings/laptop.sh"

if git diff --cached --quiet; then
  echo '[INFO] Nenhuma alteração para commit.'
  exit 0
fi

git diff --cached --stat
git commit -m "$COMMIT_MSG"

if [[ "$DO_PUSH" == true ]]; then
  branch="$(git branch --show-current)"
  [[ -n "$branch" ]] || { echo '[ERROR] HEAD destacado; push cancelado.' >&2; exit 1; }
  git push origin "$branch"
else
  echo '[INFO] Commit criado localmente. Use --push para enviar ao remoto.'
fi
