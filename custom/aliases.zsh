# Meus Aliases e Funções Pessoais

# --- Aliases Básicos ---
alias c='clear'
alias py='python3'
alias myip="curl http://ipecho.net/plain; echo"
alias zshconfig="nvim ~/.zshrc"
alias omz="cd ~/.oh-my-zsh"
alias aliases="nvim ~/.oh-my-zsh/custom/aliases.zsh" # Alias para editar este arquivo

# --- Aliases para Scripts Pessoais ---
alias keyb='/home/luan/scripts/solkeyboard.sh'
alias bright='/home/luan/scripts/brightness_control.sh'

# --- Aliases de Produtividade (Sugestões) ---
# Substitutos modernos (instale com 'sudo apt install exa bat')
# Lembre-se que em Debian/Ubuntu, o executável do bat é 'batcat'.
alias ls='exa --icons'
alias la='exa -la'
alias l='exa -l --header'
alias tree='exa --tree'
alias cat='batcat'

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
    cp "$1" "$1_$(date +%Y-%m-%d_%H-%M-%S).bak"
}
fco() {
  local branches branch
  branches=$(git branch -a | sed 's/^\s*//' | sed 's/remotes\/origin\///' | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf-tmux -d 20 -- --exit-0 --prompt="Checkout > " --multi) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
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