#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$SCRIPT_DIR"
PROFILE=home
DRY_RUN=false
NO_SUDO=false
WITH_GNOME=false
LEGACY_GNOME_SNAPSHOT=false
FEATURES=""
THEME="dracula"
BACKUP_MANIFEST="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/last-backups.tsv"
export BACKUP_MANIFEST

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/platform.sh"
source "$SCRIPT_DIR/versions.lock"

usage() {
  cat <<'EOF'
Uso: ./install.sh [opções]
  --profile base|home|work  Seleciona os módulos (padrão: home)
  --with-gnome             Aplica o módulo GNOME compatível
  --legacy-gnome-snapshot  Aplica também o snapshot dconf amplo legado
  --dry-run                Mostra ações sem alterar a máquina
  --no-sudo                Não instala pacotes do sistema
  --features LISTA         Features: docker,node,python,java,rust,terminal,mise
  --theme NOME             Tema: dracula,catppuccin,tokyonight
  -h, --help               Exibe esta ajuda
EOF
}

while (($#)); do
  case "$1" in
    --profile) [[ $# -ge 2 ]] || die "--profile requer um valor"; PROFILE="$2"; shift 2 ;;
    --with-gnome) WITH_GNOME=true; shift ;;
    --legacy-gnome-snapshot) WITH_GNOME=true; LEGACY_GNOME_SNAPSHOT=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --no-sudo) NO_SUDO=true; shift ;;
    --features) [[ $# -ge 2 ]] || die "--features requer uma lista"; FEATURES="$2"; shift 2 ;;
    --theme) [[ $# -ge 2 ]] || die "--theme requer um nome"; THEME="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Opção desconhecida: $1" ;;
  esac
done

[[ "$PROFILE" =~ ^(base|home|work)$ ]] || die "Perfil inválido: $PROFILE"
source "$SCRIPT_DIR/profiles/$PROFILE.sh"
[[ "$THEME" =~ ^(dracula|catppuccin|tokyonight)$ ]] || die "Tema inválido: $THEME"
if [[ "$WITH_GNOME" == true ]]; then INSTALL_GNOME=true; fi
detect_platform
show_platform
info "Perfil selecionado: $PROFILE"

install_packages() {
  local package_files=("$SCRIPT_DIR/packages/common.txt") packages=() line file
  [[ "$PROFILE" != base ]] && package_files+=("$SCRIPT_DIR/packages/home.txt")
  for file in "${package_files[@]}"; do
    while IFS= read -r line; do
      [[ -n "$line" && "$line" != \#* ]] && packages+=("$line")
    done < "$file"
  done
  if [[ "$NO_SUDO" == true ]]; then
    warn "Instalação de pacotes ignorada por --no-sudo"
  elif is_apt_family && command_exists apt-get; then
    run sudo apt-get update
    run sudo apt-get install -y "${packages[@]}"
  else
    warn "Gerenciador não suportado automaticamente. Instale: ${packages[*]}"
  fi
}

install_feature_packages() {
  if [[ "$NO_SUDO" == true ]]; then warn "Feature sem pacotes por --no-sudo: $*"
  elif is_apt_family && command_exists apt-get; then run sudo apt-get install -y "$@"
  else warn "Instale manualmente os pacotes da feature: $*"; fi
}

install_first_available() {
  local candidate
  if [[ "$NO_SUDO" == true ]]; then
    warn "Escolha manualmente um pacote compatível entre: $*"
    return
  fi
  for candidate in "$@"; do
    if command_exists apt-cache && apt-cache show "$candidate" >/dev/null 2>&1; then
      install_feature_packages "$candidate"
      return
    fi
  done
  warn "Nenhum pacote compatível encontrado entre: $*"
}

install_features() {
  local feature feature_file
  [[ -n "$FEATURES" ]] || return 0
  IFS=',' read -r -a requested_features <<< "$FEATURES"
  for feature in "${requested_features[@]}"; do
    feature_file="$SCRIPT_DIR/features/$feature.sh"
    [[ -r "$feature_file" ]] || die "Feature desconhecida: $feature"
    unset -f feature_install 2>/dev/null || true
    source "$feature_file"
    info "Instalando feature: $feature"
    feature_install
  done
}

install_theme() {
  local source_theme="$SCRIPT_DIR/config/kitty/themes/$THEME.conf"
  [[ -r "$source_theme" ]] || die "Tema não encontrado: $THEME"
  run mkdir -p "$HOME/.config/dotfiles"
  run cp -- "$source_theme" "$HOME/.config/dotfiles/kitty-theme.conf"
}

prepare_backup_manifest() {
  [[ "$DRY_RUN" == true ]] && return 0
  mkdir -p "$(dirname "$BACKUP_MANIFEST")"
  if [[ -s "$BACKUP_MANIFEST" ]]; then
    mv -- "$BACKUP_MANIFEST" "${BACKUP_MANIFEST}.previous-$(date +%Y%m%d-%H%M%S)"
  fi
  : > "$BACKUP_MANIFEST"
}

install_oh_my_zsh() {
  [[ -d "$HOME/.oh-my-zsh" ]] && { info "Oh My Zsh já está instalado"; return; }
  command_exists git || die "git é necessário para instalar Oh My Zsh"
  clone_pinned https://github.com/ohmyzsh/ohmyzsh.git "$OH_MY_ZSH_REF" "$HOME/.oh-my-zsh"
}

clone_pinned() {
  local url="$1" ref="$2" destination="$3" temporary="${3}.partial.$$"
  if [[ "$DRY_RUN" == true ]]; then
    run git init "$temporary"
    run git -C "$temporary" remote add origin "$url"
    run git -C "$temporary" fetch --depth=1 origin "$ref"
    run git -C "$temporary" checkout --detach FETCH_HEAD
    run mv -- "$temporary" "$destination"
    return
  fi
  mkdir -p "$(dirname "$destination")"
  if ! (
    set -e
    git init "$temporary"
    git -C "$temporary" remote add origin "$url"
    git -C "$temporary" fetch --depth=1 origin "$ref"
    git -C "$temporary" checkout --detach FETCH_HEAD
  ); then
    rm -rf -- "$temporary"
    return 1
  fi
  mv -- "$temporary" "$destination"
}

install_powerlevel10k() {
  local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  [[ -d "$theme_dir" ]] && { info "Powerlevel10k já está instalado"; return; }
  run mkdir -p "$(dirname "$theme_dir")"
  clone_pinned https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL10K_REF" "$theme_dir"
}

install_zsh_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" spec name url ref
  local plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git|$ZSH_AUTOSUGGESTIONS_REF"
    "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting.git|$FAST_SYNTAX_HIGHLIGHTING_REF"
    "zsh-completions|https://github.com/zsh-users/zsh-completions.git|$ZSH_COMPLETIONS_REF"
    "fzf-tab|https://github.com/Aloxaf/fzf-tab.git|$FZF_TAB_REF"
    "history-substring-search|https://github.com/zsh-users/zsh-history-substring-search.git|$HISTORY_SUBSTRING_SEARCH_REF"
    "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use.git|$YOU_SHOULD_USE_REF"
  )
  run mkdir -p "$custom/plugins"
  for spec in "${plugins[@]}"; do
    name="${spec%%|*}"; spec="${spec#*|}"; url="${spec%%|*}"; ref="${spec#*|}"
    [[ -d "$custom/plugins/$name" ]] || clone_pinned "$url" "$ref" "$custom/plugins/$name"
  done
}

setup_links() {
  create_symlink "$DOTFILES_DIR/dotfiles" "$HOME/.local/bin/dotfiles"
  create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
  create_symlink "$DOTFILES_DIR/custom/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"
  create_symlink "$DOTFILES_DIR/custom/env.zsh" "$HOME/.oh-my-zsh/custom/env.zsh"
  create_symlink "$DOTFILES_DIR/config/emacs" "$HOME/.emacs.d"
  create_symlink "$DOTFILES_DIR/config/git/config" "$HOME/.config/git/config"
  create_symlink "$DOTFILES_DIR/config/git/ignore" "$HOME/.config/git/ignore"
  create_symlink "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  create_symlink "$DOTFILES_DIR/scripts" "$HOME/scripts/dotfiles_scripts"
  if [[ "$INSTALL_KITTY" == true ]]; then
    create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
  fi
}

install_gnome() {
  [[ "$INSTALL_GNOME" == true ]] || return 0
  [[ -n "$GNOME_MAJOR" ]] || die "GNOME não foi detectado; módulo cancelado"
  ((GNOME_MAJOR >= 45 && GNOME_MAJOR <= 49)) || die "GNOME $GNOME_MAJOR não está coberto pelas extensões (45–49)"
  command_exists dconf || die "dconf é necessário para o módulo GNOME"
  info "Aplicando somente chaves GNOME declarativas para a versão $GNOME_MAJOR"
  run mkdir -p "$HOME/.local/share/gnome-shell/extensions" "$HOME/.icons"
  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] copiaria extensões do manifesto e aplicaria settings/common.sh"
    return
  fi
  while IFS= read -r extension; do
    [[ -n "$extension" && -d "$DOTFILES_DIR/gnome/extensions/$extension" ]] || continue
    cp -a "$DOTFILES_DIR/gnome/extensions/$extension" "$HOME/.local/share/gnome-shell/extensions/"
  done < "$DOTFILES_DIR/gnome/extensions/manifest-$GNOME_MAJOR.txt"
  cp -a "$DOTFILES_DIR/gnome/icons/." "$HOME/.icons/"
  bash "$DOTFILES_DIR/gnome/settings/common.sh"
  [[ -d /sys/class/power_supply/BAT0 ]] && bash "$DOTFILES_DIR/gnome/settings/laptop.sh"
  if [[ "$LEGACY_GNOME_SNAPSHOT" == true ]]; then
    warn "Aplicando snapshot dconf legado por solicitação explícita"
    dconf load / < "$DOTFILES_DIR/gnome/gnome_settings.dconf"
  fi
}

main() {
  install_packages
  install_features
  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugins
  prepare_backup_manifest
  setup_links
  if [[ "$INSTALL_KITTY" == true ]]; then
    install_theme
  fi
  install_gnome
  success "Instalação do perfil '$PROFILE' concluída"
  info 'Para definir Zsh como padrão: chsh -s "$(command -v zsh)"'
}

main
