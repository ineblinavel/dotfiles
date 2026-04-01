# 🚀 Dotfiles - @ineblinavel

Meus arquivos de configuração pessoais para ambiente Linux/Debian com Zsh + Oh My Zsh + Powerlevel10k.

## 📋 Conteúdo

- **Zsh** - Shell configuration com plugins modernos
- **Kitty** - Terminal emulator otimizado
- **GNOME** - Settings e extensões
- **Scripts** - Utilitários personalizados

## 🛠️ Stack

- **Shell:** Zsh + Oh My Zsh
- **Theme:** Powerlevel10k
- **Terminal:** Kitty
- **Editor:** Neovim / VSCode
- **Tools:** eza, bat, ripgrep, delta, lazygit, fzf, zoxide

## 📦 Plugins Zsh

- git
- zsh-autosuggestions
- fast-syntax-highlighting
- zsh-completions
- command-not-found
- aliases
- sudo
- dirhistory
- web-search
- fzf-tab
- history-substring-search
- you-should-use

## 🚀 Instalação

```bash
# Clone o repositório
git clone https://github.com/ineblinavel/dotfiles.git ~/dotfiles

# Execute o instalador
cd ~/dotfiles
./install.sh
```

## 📁 Estrutura

```
dotfiles/
├── .zshrc              # Configuração principal do Zsh
├── .p10k.zsh           # Tema Powerlevel10k
├── custom/
│   ├── aliases.zsh     # Aliases e funções
│   └── env.zsh         # Variáveis de ambiente
├── config/
│   └── kitty/          # Configuração do Kitty
├── gnome/
│   ├── icons/          # Ícones personalizados
│   ├── extensions/     # Extensões GNOME
│   └── gnome_settings.dconf
├── scripts/            # Scripts úteis
└── install.sh          # Script de instalação
```

## 🎯 Features

### Aliases Modernos
- `ll` - Lista detalhada com ícones (eza)
- `lg` - LazyGit interface
- `rg` - ripgrep (busca rápida)
- `gd` - git diff com delta

### Funções Úteis
- `mcd <dir>` - Cria e entra em diretório
- `backup <file>` - Backup com timestamp
- `extract <file>` - Extrai qualquer arquivo compactado
- `fco` - Fuzzy checkout de branches
- `fhist` - Navegação interativa no git log

### Keybindings
- `Ctrl+G` - Git add + commit prompt
- `Home/End` - Início/fim da linha
- `Ctrl+←/→` - Navegar por palavras

## 🔧 Ferramentas Necessárias

```bash
# CLI Tools
sudo apt install -y ripgrep git-delta nnn zsh

# Node tools
npm install -g tldr

# LazyGit
# Ver: https://github.com/jesseduffield/lazygit
```

## 📝 Notas

- **Segurança:** Variáveis sensíveis devem ficar em `~/.config/env/.env` (não versionado)
- **Histórico:** 100K comandos salvos
- **Performance:** Startup otimizado (~150ms)

## 🔐 Segurança

Este repositório **NÃO** contém:
- API keys ou tokens
- Senhas ou credenciais
- Arquivos SSH privados

Dados sensíveis ficam em `~/.config/env/.env` (gitignored).

## 📸 Screenshots

_(Adicione screenshots do seu terminal aqui)_

## 📜 Licença

MIT

---

**Última atualização:** 2026-04-01
