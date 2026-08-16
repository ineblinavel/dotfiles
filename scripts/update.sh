#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
git -C "$ROOT" diff --quiet || { echo 'Há alterações locais; update cancelado.' >&2; exit 1; }
git -C "$ROOT" diff --cached --quiet || { echo 'Há alterações staged; update cancelado.' >&2; exit 1; }
git -C "$ROOT" pull --ff-only
echo 'Atualizado. Execute ./dotfiles doctor para revisar o ambiente.'
