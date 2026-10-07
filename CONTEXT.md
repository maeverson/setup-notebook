# CONTEXT — Migração de notebook corporativo

## Cenário
> **Confirmado em 2026-10-07 (Fase 0):** os DOIS notebooks são **Ubuntu 24.04.5 LTS (noble)**, não Ubuntu 25.
> - ANTIGO (fonte): Dell Pro 16 PC16250, hostname `T-N2965`, usuário de domínio AD → inventário em `inventory/`.
> - NOVO (destino, onde este repo está clonado): Lenovo ThinkPad E14 Gen 6, hostname `PE0F644R`, usuário local
>   `maeversonwaitman` → baseline pré-provisionamento em `inventory-novo-baseline/`.
> As notas sobre Ubuntu 25 abaixo (sudo-rs, coreutils Rust) não se aplicam; apt 2.7 / deb822 / PEP 668 valem igual no 24.04.

- **Notebook ATUAL**: Ubuntu 25 (25.04 "Plucky" ou 25.10 "Questing" — confirmar com `lsb_release -a`), uso corporativo de um Arquiteto de Soluções: desenvolvimento (Java/Python/Node/Go provável), Docker, VS Code, ferramentas de cloud (gcloud/aws/kubectl provável), VPN, navegadores, comunicação (Slack/Teams/Zoom), produtividade.
- **Notebook NOVO**: Ubuntu 25 instalado do zero, mesmo usuário, mesma edição. Nada mais.
- **Meta**: o novo notebook deve ficar funcionalmente equivalente ao atual executando um único `ansible-playbook`, mais o mínimo de passos manuais (logins, segredos, Wi-Fi) listados em `MANUAL.md`.

## Particularidades do Ubuntu 25 que afetam o mapeamento/instalação
- `apt` 3.x: repos no formato **deb822** (`/etc/apt/sources.list.d/*.sources`) convivem com `.list` legados. Mapear os dois. Chaves ficam em `/etc/apt/keyrings/` ou `/usr/share/keyrings/` (não usar `apt-key`).
- 25.10 traz `sudo-rs` e coreutils em Rust por padrão; flags exóticas de `ls/cp/sort` podem diferir — manter scripts POSIX-simples.
- Python do sistema é "externally managed" (PEP 668): pip global exige `--break-system-packages` ou usar `pipx`/venv. Preferir `pipx` para CLIs.
- Snap é padrão para Firefox, Chromium, etc.; Flatpak só se foi instalado manualmente.
- Wayland é default no GNOME; apps Electron podem ter flags em `~/.config/*-flags.conf`.
- Docker pode estar via repo oficial Docker (`download.docker.com`) ou `docker.io` do Ubuntu — são pacotes diferentes, não misturar.

## Fontes de verdade para o inventário (o que `scripts/inventory.sh` coleta)
| Camada | Onde olhar |
|---|---|
| Pacotes apt instalados manualmente | `apt-mark showmanual`, `apt-cache policy` (origem) |
| Repos/PPAs/chaves | `/etc/apt/sources.list*`, `/etc/apt/keyrings`, `/usr/share/keyrings` |
| .deb instalados fora de repo | pacotes cuja `apt-cache policy` aponta `/var/lib/dpkg/status` como única origem |
| Snap / Flatpak | `snap list`, `flatpak list` |
| AppImage, /opt, binários soltos | `~/Applications`, `/opt`, `/usr/local/bin`, `~/.local/bin` |
| Toolchains de dev | sdkman, nvm, pyenv, asdf, rustup, go, pipx, npm -g, cargo |
| VS Code | `code --list-extensions`, `~/.config/Code/User/settings.json` |
| JetBrains | `~/.local/share/JetBrains/Toolbox/apps` |
| Docker | versão, imagens (nomes), compose plugin |
| Serviços | `systemctl list-unit-files --state=enabled` (system e --user) |
| Desktop GNOME | `dconf dump /`, extensões, fontes, temas, atalhos |
| Shell/dotfiles | `$SHELL`, oh-my-zsh/starship, lista de dotfiles (sem conteúdo sensível) |
| Rede | nomes de conexões `nmcli` (VPN, Wi-Fi) — só nomes |
| Certificados corporativos | nomes em `/usr/local/share/ca-certificates` |
| Impressoras | `lpstat -p` |

## Decisões de design do Ansible
- Execução local no notebook novo (`connection: local`) — não depende de SSH entre máquinas.
- Variáveis em `ansible/group_vars/all.yml`; roles finas por origem de pacote.
- Tudo que exige interação humana (login Google/Slack, importar chave SSH, cadastrar VPN) sai do playbook e vai para `MANUAL.md`.
- Dotfiles: o playbook assume um repositório git de dotfiles (`dotfiles_repo`) ou uma pasta `ansible/files/dotfiles/` copiada do atual **após revisão de segredos**.
