#!/bin/bash

# Script de instalação para configurar um novo ambiente a partir dos dotfiles.

# --- Configuração ---
# MUITO IMPORTANTE: Mude para o URL do seu repositório de dotfiles!
DOTFILES_REPO_URL="https://github.com/SEU_USUARIO/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# --- Funções de Ajuda ---
info() { echo -e "\033[34m🔵 $1\033[0m"; }
success() { echo -e "\033[32m✅ $1\033[0m"; }
fail() {
  echo -e "\033[31m❌ $1\033[0m"
  exit 1
}

# --- Funções de Instalação ---

install_dependencies() {
  info "Instalando dependências essenciais..."
  sudo apt update
  sudo apt install -y zsh git curl fzf bat eza python3-pip unzip fontconfig
  [ $? -eq 0 ] && success "Dependências instaladas." || fail "Falha ao instalar dependências."

  info "Instalando The Fuck..."
  pip install thefuck --user
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh já está instalado."
  else
    info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh instalado."
  fi
}

clone_dotfiles_repo() {
  if [ -d "$DOTFILES_DIR" ]; then
    info "Repositório de dotfiles já existe. Fazendo pull..."
    cd "$DOTFILES_DIR" && git pull origin main
  else
    info "Clonando o repositório de dotfiles..."
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
    [ $? -eq 0 ] && success "Repositório clonado." || fail "Falha ao clonar o repositório."
  fi
}

setup_symlinks() {
  info "Configurando links simbólicos..."

  # Função para criar um link, fazendo backup do arquivo original se ele existir
  create_symlink() {
    local source_file="$1"
    local target_link="$2"
    if [ -e "$target_link" ] || [ -L "$target_link" ]; then
      info "Fazendo backup de $target_link para ${target_link}.bak"
      mv "$target_link" "${target_link}.bak"
    fi
    ln -s "$source_file" "$target_link"
    success "Link criado para $target_link"
  }

  # Links para os arquivos principais
  create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

  # Links para os arquivos customizados do Oh My Zsh
  mkdir -p "$HOME/.oh-my-zsh/custom"
  create_symlink "$DOTFILES_DIR/custom/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"
  create_symlink "$DOTFILES_DIR/custom/env.zsh" "$HOME/.oh-my-zsh/custom/env.zsh"

  # Link para a pasta de scripts
  mkdir -p "$HOME/scripts"
  create_symlink "$DOTFILES_DIR/scripts" "$HOME/scripts/dotfiles_scripts"
}

install_powerlevel10k() {
  local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ -d "$p10k_dir" ]; then
    info "Powerlevel10k já está instalado."
  else
    info "Instalando o tema Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    success "Powerlevel10k instalado."
  fi
}

install_custom_plugins() {
  info "Instalando plugins customizados do Zsh..."
  local history_plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/history-substring-search"
  if [ ! -d "$history_plugin_dir" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$history_plugin_dir"
    success "Plugin 'history-substring-search' instalado."
  else
    info "Plugin 'history-substring-search' já existe."
  fi
}

install_fonts() {
  info "Instalando fontes MesloLGS NF (para Powerlevel10k)..."
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
  fc-cache -f -v
  success "Fontes instaladas. Lembre-se de selecioná-las no seu emulador de terminal!"
  cd - >/dev/null
}

# --- Script Principal ---
main() {
  install_dependencies
  install_oh_my_zsh
  clone_dotfiles_repo
  setup_symlinks
  install_powerlevel10k
  install_custom_plugins
  install_fonts

  success "INSTALAÇÃO CONCLUÍDA!"
  info "Por favor, siga os passos finais:"
  info "1. Configure a fonte 'MesloLGS NF' no seu emulador de terminal."
  info "2. Mude seu shell padrão para Zsh com o comando: chsh -s \$(which zsh)"
  info "3. FAÇA LOGOUT E LOGIN NOVAMENTE para que as mudanças tenham efeito."
  zsh
}

main "$@"
