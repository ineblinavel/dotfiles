
```bash
# Clone o repositório
git clone https://github.com/ineblinavel/dotfiles.git ~/dotfiles

# Execute o instalador
cd ~/dotfiles
./install.sh
```

## Estrutura

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
```bash
# CLI Tools
sudo apt install -y ripgrep git-delta nnn zsh

# Node tools
npm install -g tldr

# LazyGit
# Ver: https://github.com/jesseduffield/lazygit
```
**Última atualização:** 2026-04-01
