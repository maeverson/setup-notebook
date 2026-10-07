# MANUAL — passos que o Ansible não faz

Ordem sugerida. Marque conforme for fazendo no notebook novo.

## Antes do playbook
- [ ] Publicar este repositório (com `ansible/`) no remoto que o `bootstrap-new.sh` vai clonar. O GitHub `maeverson/setup-notebook` hoje só tem `scripts/` e o `inventory/` do antigo.
- [ ] Revisar a visibilidade do repo: `inventory/` tem hostname, nomes de Wi-Fi, e-mail, imagens Docker e nomes de projetos.

## Corporativo / TI (já presentes no novo, só confirmar)
- [ ] Bitdefender (`bitdefender-security-tools`), FlexxAgent, contabilizei-store, AnyDesk, FortiClient SSL VPN, Netskope e OCS Inventory: instalados pela imagem do TI. Confirmar que estão ativos.
- [ ] Ingresso no domínio AD `CONTABILIZEI.COM.BR`. No antigo o login era de domínio (`maeverson.waitman@CONTABILIZEI.COM.BR`); no novo o usuário é local. Se o TI exigir: `ad_join_enabled: true` instala os pacotes, mas o `realm join` precisa de credencial do TI.

## Segredos (transferir por meio seguro, nunca pelo repo)
- [ ] Chaves SSH (`~/.ssh/`) e GPG (`~/.gnupg/`), se houver.
- [ ] Arquivos com credenciais vistos no antigo: `~/.boto`, `~/.mcp-auth`, `~/.homolog-prd164215.env`, `~/.testcontainers.properties` (revisar).
- [ ] KeePassXC: copiar o arquivo `.kdbx` (o snap é instalado pelo playbook).

## Logins / autenticação
- [ ] Google Chrome: entrar e sincronizar. Isso traz de volta os 7 PWAs (`chrome-*-Default.desktop`) que estão nos favoritos do dock.
- [ ] `gcloud auth login` e `gcloud auth application-default login`; `gcloud config set project …`.
- [ ] `glab auth login` (gitlab.com). Responder "sim" para configurar o git credential helper, como no antigo.
- [ ] `claude` (Claude Code CLI) e Claude Desktop: login com a conta Anthropic.
- [ ] GitHub Copilot CLI (`copilot`), Stripe CLI (`stripe login`), Snyk (`snyk auth`), SonarScanner (token), ngrok (`ngrok config add-authtoken …`).
- [ ] VS Code: login do Settings Sync / Copilot / Gemini Code Assist; instalar as extensões (ver UNKNOWN.md).
- [ ] IntelliJ IDEA Ultimate: licença JetBrains.
- [ ] Teams (teams-for-linux), Zoom, Spotify, Bruno, DBeaver (recriar conexões, sem senhas no repo).

## Rede
- [ ] Wi-Fi corporativo `CTBZ-Corp` (802.1x/EAP): cadastrar com as credenciais e o CA do TI.
- [ ] VPN FortiClient SSL VPN: cadastrar o perfil corporativo.
- [ ] OpenVPN: no antigo o serviço estava habilitado, mas sem perfil no NetworkManager. Se usar, importar o `.ovpn` do TI.

## Desktop / sistema
- [ ] Java padrão: no antigo `java` = 25 e `javac` = 17. Ajustar com `sudo update-alternatives --config java` e `--config javac`.
- [ ] Área de trabalho remota (RDP do GNOME): estava habilitada no antigo. Configurar em Configurações → Sistema → Área de trabalho remota (gera o próprio certificado e senha).
- [ ] Apps padrão: Chrome para links e e-mail; Sublime Text para `.sh` e `.json` (Configurações → Aplicativos padrão ou botão direito → Abrir com).
- [ ] Extensões GNOME: só as padrão do Ubuntu, nada a fazer.
- [ ] Impressoras: nenhuma no antigo.
- [ ] Reboot ao final (grupo `docker`).

## Fase 5 (CLIs de IA / MCP)
- [ ] **Flow CLI:** criar um PAT no GitLab (Profile → Preferences → Access Tokens) com `read_api` + `read_registry`. Rodar o playbook com
      `FLOW_GITLAB_TOKEN=<token> ansible-playbook site.yml --tags fase5 --ask-become-pass` (o token não fica no repo nem no log).
      Para `uv tool upgrade flow-cli` depois, a doc manda exportar `UV_EXTRA_INDEX_URL` no `~/.bashrc` (fica em texto puro: decisão sua).
- [ ] Flow em cada projeto: `flow init .` (ou `flow init . --ai claude,copilot`); depois de upgrade, `flow upgrade`.
- [ ] Copilot CLI (exigido pelo `/flow.build`): já instalado via npm (`@github/copilot`); falta `copilot login`.
- [ ] `agy` (Antigravity): login Google no 1º uso. `codex`: `codex login`. Modelo no antigo: `gpt-6.1-sol`, reasoning `low` (`~/.codex/config.toml`).
- [ ] Codex: plugin `stripe@openai-curated` estava habilitado; o hook `notify` de telemetria é criado pelo flow (`flow telemetry deploy`).
- [ ] Claude Code: autenticar o MCP `base-conhecimento` e o plugin `stripe` no 1º uso (`/mcp`). Os conectores `claude.ai …` (Atlassian, Base Conhecimento, Claude Docs…) voltam sozinhos com o login da conta.
- [ ] `cloud-sql-proxy`/`proxy`: precisa de `gcloud auth application-default login` antes de conectar.
- [ ] `rtk`: se usar o hook do Claude Code, pôr `rtk_claude_hook: true` ou rodar `rtk init --global`.

## Depois
- [ ] Rodar `bash scripts/inventory.sh inventory-novo/` e `bash scripts/diff-inventory.sh inventory inventory-novo > DIFF.md` (Fase 4).
