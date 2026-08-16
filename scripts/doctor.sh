#!/usr/bin/env bash
set -u

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ROOT/lib/common.sh"
source "$ROOT/lib/platform.sh"
errors=0; warnings=0

ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }
problem() { printf '\033[31m[ERRO]\033[0m %s\n' "$*"; errors=$((errors + 1)); }
advice() { printf '\033[33m[AVISO]\033[0m %s\n' "$*"; warnings=$((warnings + 1)); }

check_command() {
  local command_name="$1" required="${2:-false}"
  if command -v "$command_name" >/dev/null 2>&1; then ok "Comando disponível: $command_name"
  elif [[ "$required" == true ]]; then problem "Comando obrigatório ausente: $command_name"
  else advice "Comando opcional ausente: $command_name"
  fi
}

check_any() {
  local label="$1" candidate; shift
  for candidate in "$@"; do
    if command -v "$candidate" >/dev/null 2>&1; then ok "$label: $candidate"; return; fi
  done
  advice "$label ausente (alternativas: $*)"
}

check_link() {
  local target="$1" expected="$2"
  if [[ ! -e "$target" && ! -L "$target" ]]; then advice "Ainda não instalado: $target"
  elif [[ ! -L "$target" ]]; then advice "Não é link simbólico: $target"
  elif [[ "$(readlink -f "$target")" != "$(readlink -f "$expected")" ]]; then problem "Link aponta para destino inesperado: $target"
  else ok "Link correto: $target"
  fi
}

detect_platform; show_platform
for cmd in git zsh curl; do check_command "$cmd" true; done
for cmd in fzf rg eza zoxide nvim kitty; do check_command "$cmd" false; done
check_any 'Localizador de arquivos' fd fdfind
check_any 'Visualizador de arquivos' bat batcat

check_link "$HOME/.zshrc" "$ROOT/.zshrc"
check_link "$HOME/.p10k.zsh" "$ROOT/.p10k.zsh"
check_link "$HOME/.config/git/config" "$ROOT/config/git/config"
check_link "$HOME/.local/bin/dotfiles" "$ROOT/dotfiles"

if [[ -d "$HOME/.ssh" ]]; then
  [[ -f "$HOME/.ssh/id_ed25519" ]] && ok "Chave Ed25519 encontrada" || advice "Nenhuma chave ~/.ssh/id_ed25519 (isso pode ser intencional)"
  if [[ -f "$HOME/.ssh/id_ed25519" ]] && find "$HOME/.ssh/id_ed25519" -perm /077 -print -quit 2>/dev/null | grep -q .; then
    problem "Chave privada possui permissões amplas; use chmod 600 ~/.ssh/id_ed25519"
  fi
fi

if [[ -n "$GNOME_MAJOR" ]]; then
  if ((GNOME_MAJOR >= 45 && GNOME_MAJOR <= 49)); then ok "GNOME $GNOME_MAJOR coberto pelos manifests"
  else advice "GNOME $GNOME_MAJOR ainda não possui manifesto validado"
  fi
fi

if [[ -z "$(git -C "$ROOT" status --porcelain)" ]]; then ok "Árvore Git sem alterações"
else advice "Há alterações locais no repositório"; fi

printf '\nResumo: %d erro(s), %d aviso(s).\n' "$errors" "$warnings"
((errors == 0))
