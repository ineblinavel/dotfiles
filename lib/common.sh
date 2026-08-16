#!/usr/bin/env bash

info() { printf '\033[34m[INFO]\033[0m %s\n' "$*"; }
success() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if [[ "${DRY_RUN:-false}" == true ]]; then
    printf '[dry-run]'; printf ' %q' "$@"; printf '\n'
    return 0
  fi
  "$@"
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

create_symlink() {
  local source_path="$1" target_path="$2" current_target backup
  [[ -e "$source_path" ]] || die "Origem inexistente: $source_path"
  run mkdir -p "$(dirname "$target_path")"
  if [[ -L "$target_path" ]]; then
    current_target="$(readlink "$target_path")"
    [[ "$current_target" == "$source_path" ]] && { info "Link já está correto: $target_path"; return; }
    run rm -- "$target_path"
  elif [[ -e "$target_path" ]]; then
    backup="${target_path}.backup-$(date +%Y%m%d-%H%M%S)"
    warn "Preservando configuração existente em $backup"
    run mv -- "$target_path" "$backup"
    if [[ "${DRY_RUN:-false}" != true && -n "${BACKUP_MANIFEST:-}" ]]; then
      mkdir -p "$(dirname "$BACKUP_MANIFEST")"
      printf '%s\t%s\n' "$backup" "$target_path" >> "$BACKUP_MANIFEST"
    fi
  fi
  run ln -s "$source_path" "$target_path"
  success "Link criado: $target_path"
}
