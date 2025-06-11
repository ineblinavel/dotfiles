#!/bin/bash

# Script para automatizar o backup e commit dos dotfiles.

# --- Configuração ---
# O diretório onde seu repositório de dotfiles está clonado.
DOTFILES_REPO_DIR="$HOME/dotfiles"

# --- Início do Script ---
echo "🔵 Iniciando o backup dos dotfiles para o repositório..."

# Copia os arquivos de configuração principais
cp "$HOME/.zshrc" "$DOTFILES_REPO_DIR/.zshrc"
cp "$HOME/.p10k.zsh" "$DOTFILES_REPO_DIR/.p10k.zsh"

# Garante que as pastas custom/ e scripts/ existam no repositório
mkdir -p "$DOTFILES_REPO_DIR/custom"
mkdir -p "$DOTFILES_REPO_DIR/scripts"

# Copia os arquivos customizados
cp "$HOME/.oh-my-zsh/custom/aliases.zsh" "$DOTFILES_REPO_DIR/custom/aliases.zsh"
cp "$HOME/.oh-my-zsh/custom/env.zsh" "$DOTFILES_REPO_DIR/custom/env.zsh"

# Copia seus scripts pessoais
# Adicione outros scripts se necessário
cp "$HOME/scripts/solkeyboard.sh" "$DOTFILES_REPO_DIR/scripts/solkeyboard.sh"
cp "$HOME/scripts/brightness_control.sh" "$DOTFILES_REPO_DIR/scripts/brightness_control.sh"

echo "✅ Arquivos copiados com sucesso."

# Navega para o diretório do repositório
cd "$DOTFILES_REPO_DIR"

# Adiciona todos os arquivos modificados
git add .

# Faz o commit
# Usa a mensagem passada como argumento ou uma mensagem padrão
COMMIT_MSG="${1:-"Atualização de rotina dos dotfiles"}"
git commit -m "$COMMIT_MSG"

# Envia para o repositório remoto
git push origin main # ou master, dependendo do seu branch

echo "🚀 Commit e Push realizados com sucesso!"
echo "Mensagem do commit: $COMMIT_MSG"

# Volta para o diretório anterior
cd - >/dev/null
