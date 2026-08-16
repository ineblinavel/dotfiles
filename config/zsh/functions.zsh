mkcd() { [[ $# -eq 1 ]] || { echo 'Uso: mkcd <diretório>' >&2; return 2; }; mkdir -p -- "$1" && cd -- "$1"; }
port() { [[ $# -eq 1 ]] || { echo 'Uso: port <número>' >&2; return 2; }; command lsof -nP -iTCP:"$1" -sTCP:LISTEN; }
serve() { python3 -m http.server "${1:-8000}"; }

git-clean-branches() {
  local branches
  branches="$(git branch --merged | sed -E '/^\*|main|master|develop/d')"
  [[ -n "$branches" ]] || { echo 'Nenhum branch local já integrado.'; return; }
  echo "$branches"
  read -q 'REPLY?Remover estes branches? [y/N] ' || { echo; return 1; }
  echo
  echo "$branches" | xargs git branch -d
}
