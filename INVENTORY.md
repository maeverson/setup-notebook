# INVENTORY — resumo humano

**Fonte:** `inventory/` — notebook ANTIGO, Dell Pro 16 PC16250 (`T-N2965`), Ubuntu 24.04.5 LTS (noble),
kernel 7.0.0-31 HWE, GNOME/X11, usuário de domínio `maeverson.waitman@CONTABILIZEI.COM.BR`, coletado em 2026-10-07 07:50.
**Destino:** notebook NOVO, Lenovo ThinkPad E14 Gen 6 (`PE0F644R`), Ubuntu 24.04.5 LTS, usuário local `maeversonwaitman`.
Coleta do novo antes do provisionamento: `inventory-novo-baseline/` (baseline para o DIFF da Fase 4).

Legenda da coluna **Ansible**: ✅ automatizado · 📝 MANUAL.md · ❓ UNKNOWN.md · ⏭ omitido de propósito.

## Resumo

| Categoria | Qtde | Observações |
|---|---|---|
| apt (repo Ubuntu) | 42 + 10 AD | `apt_packages`; pacotes do AD em `ad_join_packages` (desligado) |
| apt (repo terceiro) | 3 repos | nodesource 22.x, claude-desktop, Google Chrome (via .deb); VS Code (repo Microsoft, role vscode) |
| PPA | 0 | — |
| .deb manual | 5 | 4 agentes corporativos (📝) + anydesk (📝); nenhum com URL pública reproduzível |
| snap | 12 de 32 | o resto é base/runtime ou padrão do Ubuntu |
| flatpak | 0 | flatpak não instalado |
| AppImage / /opt | 0 AppImage; /opt = agentes corporativos | 📝 |
| pipx / uv / npm -g / cargo / go | 1 / 1 (+1 ❓) / 5 / 0 / 0 | gdown via pipx; headroom-ai via uv; npm globais via nvm |
| Binários em ~/.local/bin | 11 | uv, uvx, claude, glab ✅; agy, codex, rtk, proxy, cloud-sql-proxy, flow ❓ |
| VS Code extensões | ? | `vscode-extensions.txt` veio vazio (code era snap) ❓; settings + keybindings ✅ |
| Serviços habilitados | 163 system / 28 user | só os ligados a pacotes reinstalados (docker); resto é padrão ou corporativo |
| Desktop | 4 extensões padrão, 0 fontes de usuário | 20 chaves dconf ✅ |

## APT — repositório Ubuntu (archive.ubuntu.com) → `apt_packages`

| Grupo | Pacotes |
|---|---|
| Build/dev | build-essential, cmake, make, git, curl, wget, jq, unzip, gnupg, ca-certificates, apt-transport-https, graphviz, ffmpeg |
| Java | default-jre, openjdk-8-jdk, openjdk-17-jdk, openjdk-25-jre-headless, maven |
| Python | python3, python3-pip, python3-venv, python3-netifaces, pipx |
| Desktop | dconf-editor, flameshot, tilix, vlc, usb-creator-gtk, imvirt, x11-xserver-utils |
| Libs (instaladas por script, ver apt-history) | libnss3, libnspr4, libatk1.0-0t64, libatk-bridge2.0-0t64, libcups2t64, libdrm2, libxkbcommon0, libgtk-3-0t64, libgtk2.0-0t64, libgdk-pixbuf2.0-0, libx11-6, libasound2t64 |
| AD/SSSD (`ad_join_enabled: false`) | adcli, realmd, sssd, sssd-tools, libnss-sss, libpam-sss, oddjob, oddjob-mkhomedir, samba-common-bin, packagekit |

Observações:
- `openjdk-8-jdk`, `openjdk-17-jdk`, `curl`, `dmidecode`, `libglib2.0-0t64` e `google-chrome-stable` aparecem com origem
  `/var/lib/dpkg/status` em `apt-origins.tsv` porque a versão instalada estava **desatualizada** (já existe uma mais nova no repo),
  e não porque são .deb manuais. Conferido com `apt-cache policy` no novo (mesmo release).
- Ficaram de fora por serem do sistema base ou da imagem: `ubuntu-desktop-minimal`, `ubuntu-minimal`, `ubuntu-standard`,
  kernel/grub/shim/lvm2/cryptsetup, coreutils (`bsdutils`, `dash`, `grep`…), `language-pack-en*`, `ibus-table-*`,
  `libchewing*`, `libpinyin*`, `libm17n-0`, `m17n-db`, `libopencc*`, `libotf1`, `libmarisa0`, `ubuntu-wallpapers`, `wpasupplicant`.
- Locale: o antigo usava `en_US.UTF-8`; o novo foi instalado com `pt_BR.UTF-8`. Mantive o do novo.
- `qemu-system-x86`, `qemu-utils` e `qemu-kvm.service` vêm como dependência do **claude-desktop** (confirmado no `history.log` da Fase 4; usado pelo Cowork).

## APT — repositórios de terceiros → `apt_repos`

| Repo | URI | Chave | Pacote | Ansible |
|---|---|---|---|---|
| nodesource | `https://deb.nodesource.com/node_22.x` nodistro main | `https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key` | nodejs 22.23.2 | ✅ pin `nodejs=22.*`; substitui o nodejs 18 + npm 9.2 do Ubuntu (remove 133 pacotes `node-*`; aprovado em 2026-10-07) |
| claude-desktop | `https://downloads.claude.ai/claude-desktop/apt/stable` stable main | `https://downloads.claude.ai/claude-desktop/key.asc` → `/usr/share/keyrings/claude-desktop-archive-keyring.asc` | claude-desktop 2.110.1 | ✅ `apt_list_repos`: o postinst do pacote reescreve `claude-desktop.list`, então o playbook só cria esse mesmo arquivo se faltar |
| google-chrome | `https://dl.google.com/linux/chrome-stable/deb/` stable main | instalado pelo próprio .deb | google-chrome-stable | ✅ via `deb_manual` (o .deb cria o repo) |
| vscode | `https://packages.microsoft.com/repos/code` stable main | `https://packages.microsoft.com/keys/microsoft.asc` | code | ✅ role vscode |

Bitdefender: `/etc/apt/trusted.gpg.d/bitdefender*.gpg`; o agente usa um sources.list próprio em `/opt` e é corporativo. 📝

## .deb sem repositório

| Pacote | Versão | O que é | Ansible |
|---|---|---|---|
| anydesk | 8.0.4 | acesso remoto (autostart `anydesk --tray`, `anydesk.service`) | 📝 corporativo (já presente no novo) |
| bitdefender-security-tools | 7.9.3 | antivírus corporativo (`bdsec*.service`, CA `BDNetworkMonitorCA.crt`) | 📝 TI (já presente no novo) |
| flexxagent | 26.03.501.199 | agente de gestão corporativo | 📝 TI (já presente no novo) |
| forticlient-sslvpn | 4.4.2333-1 | VPN corporativa | 📝 TI (já presente no novo) |
| contabilizei-store (/opt + serviço) | — | loja de apps corporativa | 📝 TI (já presente no novo) |

## Snap → `snap_packages`

| Snap | Publisher | Classic | Ansible |
|---|---|---|---|
| bruno | helloanoop | | ✅ |
| dbeaver-ce | dbeaver-corp | ✓ | ✅ |
| gemini | kyleawayan | | ✅ (cliente não oficial do Gemini) |
| google-cloud-cli | google-cloud-sdk** | ✓ | ✅ |
| intellij-idea-ultimate | jetbrains** | ✓ | ✅ (licença: 📝) |
| keepassxc | keepassxreboot | | ✅ |
| ngrok | ngrok-publisher | | ✅ channel `v3/stable` |
| remmina | remmina** | | ✅ |
| spotify | spotify** | | ✅ |
| sublime-text | snapcrafters | ✓ | ✅ (já no novo) |
| teams-for-linux | ismaelmartinez | | ✅ |
| zoom-client | ogra | | ✅ |
| code | vscode** | ✓ | ⏭ o novo usa o repo Microsoft (evita duas instalações) |
| libreoffice | canonical** | | ⏭ o novo já tem LibreOffice .deb 24.2 |
| test-edge-only | robert-ancell | | ⏭ snap de teste |
| firefox, thunderbird, snap-store, firmware-updater, snapd-desktop-integration | canonical | | ⏭ padrão do Ubuntu |
| core, core18/20/22/24, bare, gnome-*, kf5-*, mesa-2404, gtk-common-themes, snapd | — | | ⏭ bases/runtime (dependências) |

## Toolchains

| Ferramenta | Versão no antigo | Origem | Ansible |
|---|---|---|---|
| Java (default `java`) | openjdk 25.0.4.1 | apt | ✅ (a escolha do `update-alternatives` é 📝) |
| javac | 17.0.20 | apt openjdk-17-jdk | ✅ |
| Maven | 3.8.7 | apt | ✅ |
| Python | 3.12.3 | sistema | ✅ |
| Node (sistema) | 22.23.2 | nodesource | ✅ |
| Node (nvm) | v26.5.0 | nvm | ✅ nvm v0.40.3 + node 26.5.0 |
| npm -g (nvm) | @github/copilot 1.0.74, @sonar/scan 5.0.0, @stripe/cli 1.53.0, @usebruno/cli 4.0.0, snyk 1.1307.2 | npm | ✅ (sem pin de versão) |
| gcloud | 585.0.0 no PATH; snap 587.0.0 | snap + `$GOOGLE_CLOUD_SDK_HOME` | ✅ snap; a origem do 585 é ❓ |
| kubectl | (presente) | ? | ❓ |
| glab | 1.120.0 | binário do release GitLab em ~/.local/bin | ✅ `glab_version` |
| uv / uvx | — | instalador astral.sh | ✅ |
| uv tools | headroom-ai, flow-cli | uv | headroom-ai ✅; flow-cli ❓ (não está no PyPI) |
| Claude Code CLI | 2.1.286 | instalador nativo | ✅ |
| gdown (+tqdm) | — | `pip` do sistema em /usr/local/bin | ✅ via pipx (método diferente, mesma ferramenta) |
| Docker | docker.io 29.1.3, containerd 2.2.1 | apt Ubuntu | ✅ `docker_source: ubuntu` + docker-compose-v2 + docker-buildx |
| Docker Compose | v2.27.1 | não é do apt (o apt traz 2.40.3) | ❓ plugin manual; o playbook instala docker-compose-v2 do apt |
| cmake / gcc / make | 3.28.3 / 13.3.0 / 4.3 | apt | ✅ |

Imagens Docker no antigo (só nomes, não automatizado; baixam sob demanda): postgres:14/17/18.4, eclipse-temurin:11/25-jdk,
python:3.13-slim-bookworm, node:22-alpine, debian:bookworm-slim, sonarqube:community, wiremock/wiremock:3.13.1,
quay.io/keycloak/keycloak:26.0, testcontainers/ryuk, gcr.io/…/cloud-sdk:emulators, google-cloud-cli:emulators,
ghcr.io/aertje/cloud-tasks-emulator, messagebird/gcloud-pubsub-emulator, ghcr.io/github/github-mcp-server:0.30.3,
doitintl/secrets-init, `plataforma-monolito-monolito:latest` (build local do projeto).

## VS Code

- Settings: `ansible/files/vscode/settings.json`, uma cópia de `inventory/vscode-settings.json` **sem** o bloco
  `chat.tools.terminal.autoApprove`, que aprovava um comando `mv` pontual com caminho absoluto do antigo. Sem tokens.
- Keybindings: `shift+enter` → sendSequence no terminal (para o Claude Code).
- Tema "Dracula Theme", ícones "fira-code-material-icon-theme", fonte "Fira Code". Nenhum pacote `fonts-firacode`
  estava instalado no antigo (o VS Code caía na fonte padrão). Se quiser a fonte: `fonts-firacode` existe no noble/universe.
- Extensões: lista não coletada ❓.

## Desktop GNOME (dconf-dump.ini) → `dconf_settings`

Aplicado: tema escuro (Yaru-dark, `prefer-dark`), teclado `br`, numlock, privacidade (lixeira 30 dias), sem bloqueio por
inatividade (`idle-delay 0`), volume acima de 100%, Nautilus em lista, night light desligado, energia na tomada (suspender após
3600 s → `nothing`), dock embaixo com ícones de 48, DING sem pasta home, cor do tiling-assistant, favoritos do dock.
Fica de fora: estado de janelas, tamanhos, últimas pastas, `app-picker-layout` e RDP do gnome-remote-desktop (📝).
Extensões: só as padrão do Ubuntu (ding, ubuntu-dock, tiling-assistant, ubuntu-appindicators), que já vêm instaladas.

## Shell, git, dotfiles

- Shell `/bin/bash`, sem oh-my-zsh/starship. Nos rc só há `export PATH` para `~/.local/bin` (já é o padrão do `.profile`)
  e `$GOOGLE_CLOUD_SDK_HOME/bin` ❓.
- git: `user.name`/`user.email` ✅; credential helper do gitlab.com via `glab auth git-credential` → criado pelo `glab auth login` 📝.
- Associações padrão (`mimeapps.list`): Chrome para http/https/mailto, Sublime para `.sh`/`.json`, e handlers `claude://`,
  `claude-cli://` e `jetbrains://`. Os handlers são registrados pelos próprios apps; o resto é 📝.
- Dotfiles com segredos (só nomes, conteúdo não lido): `.boto`, `.mcp-auth`, `.emulator_console_auth_token`,
  `.homolog-prd164215.env`, `.claude.json`, `.config/gcloud`, `.config/glab-cli`, `.config/github-copilot`, `.config/stripe`. 📝

## Rede, VPN, certificados, impressoras

- Wi-Fi (só nomes): `CTBZ-Corp` (corporativo, 802.1x/EAP), `Familia Waitman` (já existe no novo), além de redes de visitante/hotel. 📝
- VPN: FortiClient SSL VPN (corporativo) e `openvpn.service` habilitado, sem perfil openvpn no nmcli. 📝
- CA local: `BDNetworkMonitorCA.crt` (Bitdefender, instalado pelo agente; já no novo).
- Impressoras: nenhuma.

## Serviços

Systemd (system) fora do padrão Ubuntu: `docker`/`containerd` (✅), `anydesk`, `bdsec*`, `flexxagent`, `contabilizei-store` (corporativos),
`sssd*`/`oddjobd` (AD), `openvpn`, `qemu-kvm` (❓), `gnome-remote-desktop` (user, RDP 📝), `snap.remmina.ssh-agent` (vem com o snap).
Cron: só os padrão (anacron, e2scrub_all, sysstat).

## Fase 5 — CLIs de IA, ferramentas avulsas e MCP

| Item | Origem | Ansible |
|---|---|---|
| agy | Google Antigravity CLI, `https://antigravity.google/cli/install.sh` | ✅ `ai_tools_installers` |
| codex | OpenAI Codex CLI, `https://chatgpt.com/codex/install.sh` (instala em `~/.codex/packages/standalone`, como no antigo) | ✅ |
| rtk | Rust Token Killer, `rtk-ai/rtk` install.sh | ✅ (confirmar ❓); hook do Claude atrás de `rtk_claude_hook: false` |
| cloud-sql-proxy | `storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.26.0/…linux.amd64` → `~/.local/bin` | ✅ (versão do Dell desconhecida; usei a última) |
| proxy | `select-proxy.sh` do antigo → `ansible/files/bin/proxy`; usa o `cloud-sql-proxy` da mesma pasta | ✅ |
| kubectl | já vem no snap `google-cloud-cli` (1.31–1.37); só faltava o alias | ✅ `snap_alias` |
| flow-cli | PyPI privado do GitLab (`gitlab.com/api/v4/projects/66189044/packages/pypi/simple`), `uv tool install flow-cli@latest`; exige PAT (`read_api` + `read_registry`) — doc "Flow - Documentação Completa" (Outline) | ✅ com `FLOW_GITLAB_TOKEN` no ambiente; sem token é pulado |
| MCP `base-conhecimento` (http) | `~/.claude.json` do antigo, escopo user | ✅ `claude mcp add --scope user` |
| Plugin stripe | `~/.claude.json` (pluginUsage: `stripe@claude-plugins-official`); hoje `stripe@anthropic-plugin-directory` (github.com/stripe/ai) | ✅ `claude plugin install` |
| MCP `stripe` (projeto stripe-event-processor) | escopo de projeto; coberto pelo plugin stripe | ⏭ |

`.claude.json` e `config.toml` do antigo **não** foram versionados: têm IDs de conta/organização e caminhos de projetos.
`files/bin/proxy` contém nomes de projetos e instâncias Cloud SQL (sem credenciais) → manter o repo privado.

