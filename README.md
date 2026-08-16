# Dotfiles portáteis

Configurações para Debian e distribuições da família Debian/Ubuntu, com perfis separados para uso pessoal, trabalho e GNOME. O repositório é a fonte da verdade: o instalador cria links simbólicos e preserva arquivos existentes em backups com timestamp.

## Uso rápido

```bash
git clone https://github.com/ineblinavel/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Computador pessoal (terminal e Kitty; não altera o GNOME)
./dotfiles install --profile home

# Trabalho, sem exigir instalação de pacotes pelo sudo
./dotfiles install --profile work --no-sudo

# Base mínima
./dotfiles install --profile base
```

Confira previamente tudo que seria executado:

```bash
./dotfiles install --profile home --with-gnome --dry-run
```

## Perfis

| Perfil | Conteúdo |
| --- | --- |
| `base` | Zsh, Oh My Zsh, plugins, Git, Emacs e ferramentas CLI comuns |
| `home` | Base, Kitty e pacotes pessoais |
| `work` | Base, Kitty e utilitários de terminal, sem personalizações do desktop |

O instalador detecta `/etc/os-release`, sessão gráfica e versão principal do GNOME. Em sistemas não baseados em `apt`, ele informa a lista de pacotes em vez de escolher outro gerenciador automaticamente.

## GNOME

GNOME é opcional porque extensões são sensíveis à versão:

```bash
./dotfiles install --profile home --with-gnome
```

O módulo aceita atualmente GNOME 45–49 e instala somente as extensões presentes no manifesto da versão. Por padrão aplica apenas as chaves legíveis em `gnome/settings/`. O snapshot amplo antigo só é usado quando `--legacy-gnome-snapshot` é solicitado explicitamente.

## Comandos

```bash
./dotfiles doctor
./dotfiles status
./dotfiles update
./dotfiles backup "Minha alteração"
./dotfiles rollback
./dotfiles test
```

`doctor` verifica ferramentas, links, Git, SSH e compatibilidade GNOME. `rollback` primeiro mostra os backups; a restauração só acontece com `./dotfiles rollback --yes`.

## Features de desenvolvimento

Features são opcionais e separadas do perfil:

```bash
./dotfiles install --profile home --features docker,node,python
./dotfiles install --profile work --features java,rust --no-sudo
```

Disponíveis: `docker`, `node`, `python`, `java`, `rust`, `terminal` e `mise`. `terminal` adiciona tmux, direnv, um monitor de recursos e eza/exa quando disponível. Com `--no-sudo`, o instalador apenas informa os pacotes necessários.

## Temas

Kitty possui temas `dracula`, `catppuccin` e `tokyonight`:

```bash
./dotfiles install --profile home --theme catppuccin
```

O perfil usa a fonte FiraCode disponível nos repositórios Debian/Ubuntu. Uma Nerd Font pode ser configurada localmente se você preferir todos os glifos do Powerlevel10k.

## Configuração específica da máquina

Não coloque segredos ou caminhos corporativos nos arquivos rastreados. Crie:

```text
~/.config/dotfiles/local.zsh
```

Exemplo:

```zsh
export WORKSPACE="$HOME/Documents/Trabalho"
export GITHUB_TOKEN="carregar-de-um-cofre-de-segredos"
```

Esse arquivo é carregado por `custom/env.zsh` e não pertence ao repositório.

## Atualização e backup

Como `.zshrc`, Kitty e outros arquivos são links para este repositório, suas edições já estão aqui. Para revisar e criar um commit local:

```bash
./dotfiles backup "Minha alteração"
```

Para também enviar o branch atual:

```bash
./dotfiles backup --push "Minha alteração"
```

O snapshot GNOME nunca substitui automaticamente o arquivo rastreado. Esta opção cria `gnome/gnome_settings.dconf.new` para revisão:

```bash
./dotfiles backup --include-gnome
```

## Segurança e recuperação

- O instalador não gera chaves SSH, não altera remotes e não executa `git push`.
- Oh My Zsh, Powerlevel10k e plugins são fixados por commit em `versions.lock`.
- Arquivos existentes recebem nomes como `.zshrc.backup-20260815-120000`.
- `--dry-run` não modifica a máquina.
- `--no-sudo` pula pacotes do sistema.
- O módulo GNOME nunca é ativado implicitamente.
- Configurações Git pessoais ficam em `~/.config/git/local`; as corporativas, em `~/.config/git/work`.
- `config/ssh/config.example` documenta hosts sem armazenar chaves privadas.
- `config/git/delta.example` pode ser incluído no arquivo local quando Git Delta estiver instalado.

## Qualidade

O projeto possui testes locais, ShellCheck, Ruff, pre-commit, Gitleaks e CI em Debian Stable e Ubuntu 24.04:

```bash
./dotfiles test
pre-commit install
pre-commit run --all-files
```

## Estrutura

```text
config/       configurações dos aplicativos
custom/       aliases e ambiente Zsh
gnome/        snapshot e extensões legadas do GNOME
lib/          detecção de plataforma e funções do instalador
packages/     pacotes por perfil
profiles/     seleção de módulos
features/     módulos opcionais de desenvolvimento
tests/        testes sem alterações na máquina
scripts/      utilitários pessoais
dotfiles      CLI principal
install.sh    instalador principal
```
