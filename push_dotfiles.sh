#!/bin/bash

# Script para automatizar o backup e commit dos dotfiles.

# --- Configuração ---
# O diretório onde seu repositório de dotfiles está clonado.
DOTFILES_REPO_DIR="$HOME/dotfiles"

# --- Início do Script ---
echo "🔵 Iniciando o backup dos dotfiles para o repositório..."

# 1. ZSH e Powerlevel10k
echo "📂 Copiando configurações do Zsh..."
cp "$HOME/.zshrc" "$DOTFILES_REPO_DIR/.zshrc"
cp "$HOME/.p10k.zsh" "$DOTFILES_REPO_DIR/.p10k.zsh"

# Garante que as pastas de destino existam
mkdir -p "$DOTFILES_REPO_DIR/custom"
mkdir -p "$DOTFILES_REPO_DIR/scripts"
mkdir -p "$DOTFILES_REPO_DIR/config"
mkdir -p "$DOTFILES_REPO_DIR/gnome"

# Copia arquivos customizados do Oh My Zsh
cp "$HOME/.oh-my-zsh/custom/aliases.zsh" "$DOTFILES_REPO_DIR/custom/aliases.zsh"
cp "$HOME/.oh-my-zsh/custom/env.zsh" "$DOTFILES_REPO_DIR/custom/env.zsh"

# 2. Scripts Pessoais
echo "📜 Copiando scripts pessoais..."
cp "$HOME/scripts/solkeyboard.sh" "$DOTFILES_REPO_DIR/scripts/solkeyboard.sh"
cp "$HOME/scripts/brightness_control.sh" "$DOTFILES_REPO_DIR/scripts/brightness_control.sh"

# 3. Configurações do GNOME
echo "🎨 Fazendo backup das configurações do GNOME..."

# Salva as configurações do banco de dados dconf (Dash to dock, atalhos, ArcMenu, etc)
dconf dump / > "$DOTFILES_REPO_DIR/gnome/gnome_settings.dconf"

# Salva as extensões instaladas manualmente
if [ -d "$HOME/.local/share/gnome-shell/extensions" ]; then
    rm -rf "$DOTFILES_REPO_DIR/gnome/extensions" # Limpa backup antigo para evitar lixo
    cp -r "$HOME/.local/share/gnome-shell/extensions" "$DOTFILES_REPO_DIR/gnome/extensions"
fi

# Salva ícones e cursores (ex: cursor do Gnome-Look)
if [ -d "$HOME/.icons" ]; then
    rm -rf "$DOTFILES_REPO_DIR/gnome/icons"
    cp -r "$HOME/.icons" "$DOTFILES_REPO_DIR/gnome/icons"
elif [ -d "$HOME/.local/share/icons" ]; then
    rm -rf "$DOTFILES_REPO_DIR/gnome/icons"
    cp -r "$HOME/.local/share/icons" "$DOTFILES_REPO_DIR/gnome/icons"
fi

# 4. Configurações do Kitty
echo "🐱 Salvando configurações do Kitty..."
if [ -d "$HOME/.config/kitty" ]; then
    rm -rf "$DOTFILES_REPO_DIR/config/kitty"
    cp -r "$HOME/.config/kitty" "$DOTFILES_REPO_DIR/config/"
else
    echo "⚠️ Pasta ~/.config/kitty não encontrada. Pulei esta etapa."
fi

echo "✅ Todos os arquivos foram copiados."

# --- Git Operations ---
cd "$DOTFILES_REPO_DIR" || exit

# Adiciona todos os arquivos modificados
git add .

# Faz o commit
COMMIT_MSG="${1:-"Atualização de rotina dos dotfiles"}"
git commit -m "$COMMIT_MSG"

# Envia para o repositório remoto
git push origin main # Confirme se seu branch é 'main' ou 'master'

echo "🚀 Commit e Push realizados com sucesso!"
echo "Mensagem do commit: $COMMIT_MSG"

# Volta para o diretório anterior
cd - >/dev/null
