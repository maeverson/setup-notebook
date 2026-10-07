# UNKNOWN — itens sem origem determinada

Nada aqui foi para o playbook. Para resolver um item, rode o comando sugerido **no notebook antigo** (Dell `T-N2965`).

| Item | Onde foi visto | O que tentei | Próximo passo |
|---|---|---|---|
| Extensões do VS Code | `vscode-extensions.txt` vazio (VS Code era snap) | `settings.json` cita prettier, redhat.java, Dracula, gitlens, sonarlint, copilot, gemini, veracode, cody, continue, drawio, plantuml, claude-code; nenhuma lista instalada confirmada | No antigo: `snap run code --list-extensions > ext.txt` e preencher `vscode_extensions`; ou ativar o Settings Sync |
| `~/.local/bin/rtk` (11 MB) | `local-bin.txt`, `~/.config/rtk` | Automatizado como Rust Token Killer (`rtk-ai/rtk`), mas existe outro projeto chamado `rtk` | No antigo: `rtk gain`; se não for o Token Killer, tirar de `ai_tools_installers` |
| gcloud 585.0.0 no PATH (o snap é 587.0.0) e `$GOOGLE_CLOUD_SDK_HOME` | `dev-versions.txt`, `shell-rc-sources.txt` | Há um SDK por tarball além do snap | No antigo: `echo $GOOGLE_CLOUD_SDK_HOME; gcloud components list --only-local-state`. O playbook usa só o snap |
| Docker Compose v2.27.1 | `docker.txt` | Não é o pacote apt (apt = 2.40.3); provável plugin em `~/.docker/cli-plugins` | O playbook instala `docker-compose-v2` do apt (versão mais nova). Confirmar se a versão importa |
| `~/.bun` | `dotfiles-list.txt` | `bun` não está no PATH | No antigo: `ls ~/.bun/bin`; se usar, instalar via `curl -fsSL https://bun.sh/install \| bash` |
| Configs de BraveSoftware, chromium, microsoft-edge, vivaldi em `~/.config` | `dotfiles-list.txt` | Os binários não estão no PATH (`browsers-comms.txt`) | Provavelmente resíduo; confirmar se algum ainda é usado |
| `.android`, `Android Open Source Project`, `.emulator_console_auth_token` | `dotfiles-list.txt` | Android SDK/emulador sem binário rastreado | Confirmar se o Android Studio/SDK é necessário |
| Diretórios de outras ferramentas de IA: `.gemini`, `.junie`, `.codemoss`, `.claude-code-gui`, `.agents`, `.headroom` | `dotfiles-list.txt` | São configs de usuário, não pacotes | Copiar manualmente as que interessarem (revisando segredos) |
