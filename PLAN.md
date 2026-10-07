# PLAN — fases e critérios de pronto

## Fase 0 — Preparação
- [x] Confirmar versão do Ubuntu atual (`lsb_release -a`) e anotar em `CONTEXT.md`.
- [x] Garantir que `scripts/inventory.sh` roda sem `sudo` (apenas leitura).

## Fase 1 — Inventário bruto
- [x] Rodar `bash scripts/inventory.sh inventory/`.
- [x] Verificar `inventory/_errors.log`; reexecutar seções que falharam.
- **Pronto quando**: todos os arquivos listados no cabeçalho do script existem.

## Fase 2 — Classificação (Claude)
- [x] Ler `inventory/apt-origins.tsv` e separar: repo Ubuntu oficial / repo terceiro / PPA / .deb manual.
- [x] Para cada repo terceiro, identificar URL, chave e componente → `apt_repos` em `group_vars/all.yml`.
- [x] Para cada .deb manual, descobrir URL de download oficial (pesquisar) → `deb_manual`.
- [x] Listar snaps (com `--classic` quando aplicável), flatpaks (com remote).
- [x] Toolchains: versões de Java/Node/Python/Go/Rust e gerenciador usado.
- [x] VS Code: extensões + settings (sem tokens).
- [x] Desktop: extensões GNOME, dconf relevante (atalhos, tema), fontes.
- [x] Escrever `INVENTORY.md` (resumo humano) e `UNKNOWN.md`.
- **Pronto quando**: cada item do inventário está em `group_vars/all.yml` OU em `UNKNOWN.md` OU em `MANUAL.md`.

## Fase 3 — Geração do Ansible
- [x] Preencher `ansible/group_vars/all.yml`.
- [x] Ajustar roles em `ansible/roles/*` conforme necessidade (ex.: repo Docker, gcloud, VS Code).
- [x] `ansible-lint` e `ansible-playbook site.yml --check --diff` sem erros.
- **Pronto quando**: check mode passa e `MANUAL.md` lista todos os passos manuais.

> Status 2026-10-07: Fases 0–4 concluídas (playbook rodado direto com ansible já instalado; 2ª passada changed=0; DIFF.md só com itens esperados). Pendente: MANUAL.md.
> Fases 0–3: Ressalvas: Ubuntu é 24.04 (não 25); o inventário do antigo veio do clone
> (o notebook atual já é o NOVO); a lista de extensões do VS Code não foi coletada (UNKNOWN.md); `--check` rodou com
> `-e ansible_become=false` (sem sudo), então as tasks que exigem root foram avaliadas como usuário comum.

## Fase 4 — Execução no notebook novo
- [x] `bash scripts/bootstrap-new.sh` (instala git + ansible, clona o repo, roda `site.yml`).
- [ ] Seguir `MANUAL.md`.
- [x] Rodar `scripts/inventory.sh` no novo e fazer `diff` com o inventário do atual → `DIFF.md`.
- **Pronto quando**: diff contém apenas itens esperados (ex.: versões patch, caches).

## Fase 5 — CLIs de IA, ferramentas avulsas e MCP (tags `fase5`, `ai`, `mcp`)
- [x] Identificar a origem de agy, codex, rtk, cloud-sql-proxy e kubectl (pesquisa + snap do gcloud).
- [x] Versionar o script `proxy` (select-proxy.sh do antigo) em `ansible/files/bin/proxy`.
- [x] Extrair do `~/.claude.json` do antigo só nomes/URLs de MCP e plugins (arquivo não versionado).
- [x] Roles `ai_tools` e `mcp_servers`; lint production e `--check --tags fase5` sem erros.
- [ ] Confirmar no Dell que o `rtk` é o Rust Token Killer (`rtk gain`) e decidir `rtk_claude_hook`.
- [x] Origem do flow: PyPI privado do GitLab (doc do Outline) → `flow_cli_install` + `FLOW_GITLAB_TOKEN` em tempo de execução.
- [ ] Rodar: `ansible-playbook site.yml --tags fase5 --ask-become-pass` e logins (MANUAL.md).
- **Pronto quando**: os 7 itens funcionam no novo (`agy/codex/rtk/cloud-sql-proxy/proxy/kubectl --version`, `flow --version`) e `claude mcp list` mostra base-conhecimento.

