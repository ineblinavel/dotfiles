# Powerlevel10k instant prompt deve permanecer no início.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"
plugins=(git zsh-autosuggestions fast-syntax-highlighting zsh-completions command-not-found aliases sudo dirhistory web-search fzf-tab history-substring-search you-should-use)

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

DOTFILES_ZSH_DIR="${${(%):-%x}:A:h}/config/zsh"
for module in history completion environment tools keybindings functions; do
  [[ -r "$DOTFILES_ZSH_DIR/$module.zsh" ]] && source "$DOTFILES_ZSH_DIR/$module.zsh"
done

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
