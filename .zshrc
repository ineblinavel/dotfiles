# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    command-not-found
    aliases
    sudo
    dirhistory
    web-search
  )

# Carrega o Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- Configurações Avançadas de Histórico ---

# Aumenta o tamanho do histórico
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Ignora comandos duplicados no histórico
setopt HIST_IGNORE_ALL_DUPS

# Apaga espaços em branco do início de cada linha do histórico
setopt HIST_REDUCE_BLANKS

# Não adiciona comandos que começam com espaço ao histórico (modo "privado")
setopt HIST_IGNORE_SPACE

# Compartilha o histórico instantaneamente entre todos os terminais abertos
setopt SHARE_HISTORY

# Permite que você adicione comandos ao arquivo de histórico de forma incremental
setopt INC_APPEND_HISTORY

# --- Configurações de Ferramentas Adicionais ---
# Suas configs (aliases, exports) são carregadas de ~/.oh-my-zsh/custom/

# (Opcional) Ativação do FZF (Fuzzy Finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Configura o fzf para usar o 'bat' como preview e melhora a aparência
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border --preview "if [ -d {2..} ]; then exa --tree --color=always {2..}; else bat --color=always --style=numbers --line-range=:500 {2..}; fi"'

eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# Esta linha DEVE ser a última do arquivo.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Created by `pipx` on 2025-11-15 03:24:10
export PATH="$PATH:/home/luan/.local/bin"
