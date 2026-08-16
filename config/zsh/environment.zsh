typeset -U path PATH
path+=("$HOME/.local/bin" "$HOME/.npm-global/bin")

if command -v nvim >/dev/null 2>&1; then export EDITOR=nvim
elif command -v code >/dev/null 2>&1; then export EDITOR=code
else export EDITOR=vi; fi
export VISUAL="$EDITOR"
export NNN_OPENER="$HOME/.config/nnn/plugins/nuke"
export NNN_PLUG='o:fzopen;p:preview-tui;d:diffs;v:imgview'
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'

[[ -r "$HOME/.config/dotfiles/local.zsh" ]] && source "$HOME/.config/dotfiles/local.zsh"
