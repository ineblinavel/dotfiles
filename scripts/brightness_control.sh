#!/usr/bin/env bash
set -euo pipefail

value="${1:-}"
[[ "$value" =~ ^(0(\.[0-9]+)?|1(\.0+)?)$ ]] || {
  echo "Uso: $0 <valor entre 0.0 e 1.0> [saída]" >&2
  exit 2
}

output="${2:-$(xrandr --query | awk '/ connected primary/{print $1; found=1; exit} / connected/{fallback=$1} END{if (!found) print fallback}')}"
[[ -n "$output" ]] || { echo "Nenhuma saída xrandr encontrada" >&2; exit 1; }
xrandr --output "$output" --brightness "$value"
