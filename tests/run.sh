#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
passed=0; failed=0

test_case() {
  local name="$1"; shift
  if "$@"; then printf '[OK] %s\n' "$name"; passed=$((passed + 1))
  else printf '[FAIL] %s\n' "$name" >&2; failed=$((failed + 1)); fi
}

run_profile() {
  local profile="$1" output
  output="$("$ROOT/install.sh" --profile "$profile" --no-sudo --dry-run 2>&1)"
  grep -q "Instalação do perfil '$profile' concluída" <<< "$output"
}

reject_invalid_profile() { ! "$ROOT/install.sh" --profile invalid --dry-run >/dev/null 2>&1; }
reject_invalid_feature() { ! "$ROOT/install.sh" --profile base --features invalid --no-sudo --dry-run >/dev/null 2>&1; }
base_skips_kitty() { local output; output="$("$ROOT/install.sh" --profile base --no-sudo --dry-run 2>&1)"; ! grep -q 'kitty-theme.conf' <<< "$output"; }
home_has_kitty() { local output; output="$("$ROOT/install.sh" --profile home --no-sudo --dry-run 2>&1)"; grep -q 'kitty-theme.conf' <<< "$output"; }
rollback_is_safe() { "$ROOT/scripts/rollback.sh" 2>&1 | grep -Eq 'Nenhum backup|Execute novamente'; }
dry_run_does_not_write() {
  local temporary output
  temporary="$(mktemp -d)"
  output="$(HOME="$temporary" "$ROOT/install.sh" --profile home --no-sudo --dry-run 2>&1)"
  [[ -n "$output" && -z "$(find "$temporary" -mindepth 1 -print -quit)" ]]
  rm -rf -- "$temporary"
}
links_are_idempotent() {
  local temporary source_file target_file first_target
  temporary="$(mktemp -d)"; source_file="$temporary/source"; target_file="$temporary/target"
  printf 'teste\n' > "$source_file"
  DRY_RUN=false BACKUP_MANIFEST="$temporary/backups" source "$ROOT/lib/common.sh"
  create_symlink "$source_file" "$target_file" >/dev/null
  first_target="$(readlink "$target_file")"
  create_symlink "$source_file" "$target_file" >/dev/null
  [[ -L "$target_file" && "$(readlink "$target_file")" == "$first_target" ]]
  rm -rf -- "$temporary"
}

test_case 'perfil base' run_profile base
test_case 'perfil home' run_profile home
test_case 'perfil work' run_profile work
test_case 'perfil inválido recusado' reject_invalid_profile
test_case 'feature inválida recusada' reject_invalid_feature
test_case 'base não configura Kitty' base_skips_kitty
test_case 'home configura Kitty' home_has_kitty
test_case 'rollback exige confirmação' rollback_is_safe
test_case 'dry-run não escreve' dry_run_does_not_write
test_case 'links são idempotentes' links_are_idempotent

printf '\n%d passaram; %d falharam.\n' "$passed" "$failed"
((failed == 0))
