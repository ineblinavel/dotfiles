#!/bin/bash

# Script de instalação para configurar um novo ambiente a partir dos dotfiles.

# --- Configuração ---
# MUITO IMPORTANTE: Mude para o URL do seu repositório de dotfiles!
DOTFILES_REPO_URL="https://github.com/ineblinavel/dotfiles.git"
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
  # Adicionado 'kitty', 'dconf-cli' e 'gnome-tweaks' aqui para garantir
  sudo apt install -y zsh git curl fzf bat eza python3-pip unzip fontconfig kitty dconf-cli gnome-tweaks
  [ $? -eq 0 ] && success "Dependências instaladas." || fail "Falha ao instalar dependências."

  info "Instalando The Fuck..."
  pip install thefuck --user --break-system-packages 2>/dev/null || pip install thefuck --user
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

  create_symlink() {
    local source_file="$1"
    local target_link="$2"
    # Se o arquivo já existe e não é um link, faz backup
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
      info "Fazendo backup de $target_link para ${target_link}.bak"
      mv "$target_link" "${target_link}.bak"
    fi
    # Se for um link quebrado ou incorreto, remove para recriar
    if [ -L "$target_link" ]; then
        rm "$target_link"
    fi
    ln -s "$source_file" "$target_link"
    success "Link criado para $target_link"
  }

  # 1. Configurações do Kitty
  mkdir -p "$HOME/.config"
  create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"

  # 2. Arquivos principais do Zsh
  create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

  # 3. Customizações do Oh My Zsh
  mkdir -p "$HOME/.oh-my-zsh/custom"
  create_symlink "$DOTFILES_DIR/custom/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"
  create_symlink "$DOTFILES_DIR/custom/env.zsh" "$HOME/.oh-my-zsh/custom/env.zsh"

  # 4. Scripts Pessoais
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
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts

  info "Instalando fontes MesloLGS NF (para P10k)..."
  curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

  info "Baixando FiraCode Nerd Font (para o Kitty)..."
  if [ ! -f "FiraCodeRegular.ttf" ]; then # Checagem simples para não baixar sempre
      curl -fLo "FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
      unzip -o FiraCode.zip
      rm FiraCode.zip
  fi

  fc-cache -f -v
  success "Fontes instaladas. Lembre-se de configurar no terminal!"
  cd - >/dev/null
}

install_gnome_setup() {
  info "Configurando GNOME (Temas e Extensões)..."

  # 1. Restaura as extensões (arquivos físicos)
  if [ -d "$DOTFILES_DIR/gnome/extensions" ]; then
    mkdir -p "$HOME/.local/share/gnome-shell/extensions"
    cp -r "$DOTFILES_DIR/gnome/extensions/"* "$HOME/.local/share/gnome-shell/extensions/"
    success "Extensões restauradas."
  fi

  # 2. Restaura Cursores e Ícones
  if [ -d "$DOTFILES_DIR/gnome/icons" ]; then
    mkdir -p "$HOME/.icons"
    cp -r "$DOTFILES_DIR/gnome/icons/"* "$HOME/.icons/"
    success "Cursores/Ícones restaurados."
  fi

  # 3. Instala o Tema WhiteSur (Versão Black/Dark)
  info "Instalando WhiteSur-gtk-theme..."
  if [ -d "/tmp/WhiteSur" ]; then rm -rf "/tmp/WhiteSur"; fi
  git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur
  /tmp/WhiteSur/install.sh -c Dark -t all -N stable 
  rm -rf /tmp/WhiteSur
  success "Tema WhiteSur instalado."

  # 4. Carrega configurações do banco de dados (Dconf)
  if [ -f "$DOTFILES_DIR/gnome/gnome_settings.dconf" ]; then
    dconf load / < "$DOTFILES_DIR/gnome/gnome_settings.dconf"
    success "Configurações do GNOME carregadas!"
  else
    info "Nenhum arquivo de backup dconf encontrado. Pulando restauração de configurações."
  fi
}
setup_github_ssh() {
  info "Configurando chave SSH para o GitHub..."
  local ssh_key="$HOME/.ssh/id_ed25519"

  # 1. Verifica se a chave já existe
  if [ ! -f "$ssh_key" ]; then
    info "Nenhuma chave SSH encontrada. Vamos gerar uma nova."
    echo -n "Digite o email associado ao seu GitHub: "
    read ssh_email
    
    # Gera a chave sem pedir senha (passphrase vazia -N "")
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$ssh_key" -N ""
    
    # Inicia o agente SSH e adiciona a chave
    eval "$(ssh-agent -s)"
    ssh-add "$ssh_key"
    success "Chave SSH gerada com sucesso."
  else
    info "Chave SSH já existente. Pulando geração."
  fi

  # 2. Mostra a chave para o usuário
  echo ""
  echo -e "\033[33m👇 COPIE A LINHA ABAIXO (do ssh-ed25519 até o email): 👇\033[0m"
  echo "----------------------------------------------------------------------"
  cat "$ssh_key.pub"
  echo "----------------------------------------------------------------------"
  echo ""
  
  # 3. Instrui o usuário
  info "Agora precisamos adicionar essa chave ao seu GitHub:"
  info "1. Abra este link: https://github.com/settings/ssh/new"
  info "2. No campo 'Title', coloque: Linux Debian (ou o nome que preferir)"
  info "3. No campo 'Key', cole o código que apareceu acima."
  info "4. Clique em 'Add SSH key'."
  echo ""
  echo -n "Pressione [ENTER] depois de adicionar a chave no site para testar a conexão..."
  read

  # 4. Testa a conexão
  info "Testando conexão com o GitHub..."
  ssh -T git@github.com -o StrictHostKeyChecking=no
  
  # O ssh retorna código 1 quando conecta com sucesso (porque não dá shell), então checamos isso
  if [ $? -eq 1 ]; then
      success "Conexão SSH configurada com sucesso! Agora você pode fazer git push sem senha."
      
      # Ajusta a URL do repositório atual para usar SSH em vez de HTTPS
      if [ -d "$DOTFILES_DIR" ]; then
          cd "$DOTFILES_DIR"
          git remote set-url origin "git@github.com:ineblinavel/dotfiles.git"
          success "Repositório dotfiles atualizado para usar SSH."
          cd - >/dev/null
      fi
  else
      fail "Não foi possível autenticar. Verifique se você colou a chave corretamente."
  fi
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
  install_gnome_setup
  setup_github_ssh
  success "INSTALAÇÃO CONCLUÍDA!"
  info "Passos finais:"
  info "1. Configure a fonte 'MesloLGS NF' ou 'FiraCode NF' no seu terminal."
  info "2. Mude o shell para Zsh: chsh -s \$(which zsh)"
  info "3. Reinicie a sessão (Logout/Login) para aplicar as extensões do GNOME e o grupo de usuário."
  
  # Entra no zsh
  exec zsh
}

main "$@"
