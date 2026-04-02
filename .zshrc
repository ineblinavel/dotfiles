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
    fast-syntax-highlighting
    zsh-completions
    command-not-found
    aliases
    sudo
    dirhistory
    web-search
    fzf-tab
    history-substring-search
    you-should-use
  )

# Carrega o Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- Configurações Avançadas de Histórico ---

# Aumenta o tamanho do histórico
HISTSIZE=100000
SAVEHIST=100000
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

# Configuração do nnn - file browser
export NNN_OPENER="$HOME/.config/nnn/plugins/nuke"
export NNN_PLUG='o:fzopen;p:preview-tui;d:diffs;v:imgview'
export EDITOR="code"
export VISUAL="code"

# (Opcional) Ativação do FZF (Fuzzy Finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Configura o fzf para usar o 'bat' como preview e melhora a aparência
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border --preview "if [ -d {2..} ]; then exa --tree --color=always {2..}; else bat --color=always --style=numbers --line-range=:500 {2..}; fi"'

eval "$(zoxide init zsh)"

# Pyenv - Python version manager
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# Esta linha DEVE ser a última do arquivo.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Created by `pipx` on 2025-11-15 03:24:10
export PATH="$PATH:/home/luan/.local/bin"
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"



eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Carregar variáveis de ambiente seguras (API keys, etc)
[ -f ~/.config/env/.env ] && source ~/.config/env/.env

[ -f "/home/luan/.ghcup/env" ] && . "/home/luan/.ghcup/env" # ghcup-env

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
