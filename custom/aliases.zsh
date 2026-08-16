# Meus Aliases e Funções Pessoais

# --- Aliases Básicos ---
alias c='clear'
command -v python3 >/dev/null 2>&1 && alias py='python3'
alias myip="curl -fsSL https://api.ipify.org; echo"
alias zshconfig="nvim ~/.zshrc"
alias omz="cd ~/.oh-my-zsh"
alias aliases="nvim ~/.oh-my-zsh/custom/aliases.zsh" # Alias para editar este arquivo
alias ccp="xclip -selection clipboard"
# --- Aliases para Scripts Pessoais ---



# --- Aliases de Produtividade (Sugestões) ---
# Substitutos modernos - ferramentas CLI melhoradas
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias la='eza -la'
    alias l='eza -l --header'
    alias ll='eza -lah'
    alias tree='eza --tree'
    alias lt='eza --tree -L 3'
fi
if command -v batcat >/dev/null 2>&1; then
    alias cat='batcat'
elif command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# Ferramentas modernas (se instaladas)
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

if command -v delta &> /dev/null; then
    alias diff='delta'
fi

if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
    alias glog='lazygit'
fi

# Navegação
alias ..='cd ..'
alias ...='cd ../..'

# --- Funções Úteis ---
# Criar uma pasta e entrar nela
mcd() {
  mkdir -p "$1" && cd "$1"
}

# Fazer backup de um arquivo com timestamp
backup() {
    cp -- "$1" "${1}_$(date +%Y-%m-%d_%H-%M-%S).bak"
}
fco() {
  local branches branch
  branches=$(git branch -a | sed 's/^\s*//' | sed 's/remotes\/origin\///' | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf-tmux -d 20 -- --exit-0 --prompt="Checkout > " --multi) &&
  git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")"
}

# fbr - Fuzzy Branch (similar ao fco, mas focado em listar)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD)
  branch=$(echo "$branches" | fzf-tmux -d 20 -- --exit-0 --multi)
  echo $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
}

# fhist - Fuzzy History (navegar no log do git de forma interativa)
fhist() {
  git log --oneline --graph --pretty=format:'%C(auto)%h %d %s %C(reset)%C(blue)%cr%C(reset)' |
  fzf --no-sort --reverse --tiebreak=index --no-multi \
  --preview 'git show --color=always {+1}'
}

# Função para extrair qualquer tipo de arquivo compactado
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar Jxvf "$1"    ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' não pode ser extraído com a função 'extract'" ;;
        esac
    else
        echo "'$1' não é um arquivo válido"
    fi
}

# --- Novas Funções Úteis (2026-04-02) ---

# Jump rápido para projetos com FZF
cdproject() {
  local project
  # Procura em ~/git e permite busca interativa
  if [ -d ~/git ]; then
    project=$(ls ~/git 2>/dev/null | fzf --preview 'ls -lah ~/git/{}' --height 40% --border)
    if [ -n "$project" ]; then
      cd ~/git/"$project"
      echo "📂 Projeto: $project"
      # Mostrar status git se for repo
      if [ -d .git ]; then
        echo ""
        git status -sb
      fi
    fi
  else
    echo "Diretório ~/git não existe"
  fi
}

# Sistema de notas rápidas
note() {
  local notes_file="$HOME/.notes/quick-notes.txt"
  mkdir -p "$HOME/.notes"
  
  if [ $# -eq 0 ]; then
    echo "📝 Uso: note <sua nota aqui>"
    echo "   ou: notes (para ver todas)"
    return 1
  fi
  
  echo "$(date '+%Y-%m-%d %H:%M') | $*" >> "$notes_file"
  echo "✅ Nota salva"
}

# Ver todas as notas
notes() {
  local notes_file="$HOME/.notes/quick-notes.txt"
  
  if [ ! -f "$notes_file" ]; then
    echo "📝 Nenhuma nota ainda. Use: note <sua nota>"
    return
  fi
  
  echo "📝 NOTAS RÁPIDAS"
  echo "════════════════"
  cat "$notes_file"
  echo ""
  echo "Total: $(wc -l < "$notes_file") notas"
}

# Estatísticas git do repositório atual
gitstats() {
  if [ ! -d .git ]; then
    echo "❌ Não é um repositório git"
    return 1
  fi
  
  echo "📊 GIT STATISTICS"
  echo "═════════════════"
  echo ""
  echo "📦 Repositório: $(basename $(git rev-parse --show-toplevel))"
  echo "🌿 Branch atual: $(git branch --show-current)"
  echo ""
  echo "📈 Commits:"
  echo "  • Total: $(git rev-list --count HEAD 2>/dev/null || echo 0)"
  echo "  • Este ano: $(git log --since='1 year ago' --oneline 2>/dev/null | wc -l)"
  echo "  • Este mês: $(git log --since='1 month ago' --oneline 2>/dev/null | wc -l)"
  echo "  • Esta semana: $(git log --since='1 week ago' --oneline 2>/dev/null | wc -l)"
  echo ""
  echo "👤 Top 5 contribuidores:"
  git shortlog -sn --no-merges | head -5
  echo ""
  echo "📝 Último commit:"
  git log -1 --pretty=format:"  %h - %s (%cr)" 2>/dev/null
  echo ""
}

# Status do sistema
syshealth() {
  echo "🖥️  SYSTEM HEALTH"
  echo "═════════════════"
  echo ""
  echo "💻 CPU:"
  echo "  $(top -bn1 | grep "Cpu(s)" | awk '{print "Uso: " $2}' || echo "N/A")"
  echo ""
  echo "🧠 RAM:"
  echo "  $(free -h | awk 'NR==2{printf "Uso: %s / %s (%.0f%%)", $3,$2,$3*100/$2}')"
  echo ""
  echo "💾 Disco (/):"
  echo "  $(df -h / | awk 'NR==2{printf "Uso: %s / %s (%s)", $3,$2,$5}')"
  echo ""
  echo "⏰ Uptime:"
  echo "  $(uptime -p)"
  echo ""
  
  # Mostrar temperatura CPU se disponível
  if command -v sensors &> /dev/null; then
    echo "🌡️  Temperatura:"
    sensors | grep -E "Core|temp" | head -3
  fi
}

# --- Fim das Novas Funções ---

# --- Meus Atalhos de Teclado (Keybindings) ---

# Faz as teclas Home e End funcionarem como esperado
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
# Para alguns terminais (como o tilix), pode ser necessário usar:
# bindkey '^[[1~' beginning-of-line
# bindkey '^[[4~' end-of-line


# Navega palavra por palavra com Ctrl + Seta Esquerda/Direita
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Atalho para limpar a tela com Ctrl+L (alguns terminais já fazem isso)
bindkey '^L' clear-screen

# Cria um widget (função) para executar 'git add . && git commit'
# e o associa ao atalho Ctrl+G
function git_add_commit() {
  git add .
  zle -I # Aceita o comando atual e prepara para o próximo
  BUFFER="git commit -m ''"
  CURSOR=18 # Move o cursor para dentro das aspas
}
zle -N git_add_commit
bindkey '^g' git_add_commit

alias grubc="sudo micro /etc/default/grub"

# Backup automático
alias backup-dotfiles='dotfiles backup'

# Docker Compose shortcuts (usa o plugin oficial)
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcr='docker compose restart'
alias dcp='docker compose ps'
alias dcb='docker compose build'
