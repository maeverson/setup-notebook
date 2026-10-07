# notebook-provision

Kit para o Claude (Claude Code no VS Code) mapear o notebook corporativo atual (Ubuntu 25) e gerar Ansible para provisionar um notebook novo.

```
CLAUDE.md        ← ponto de entrada do Claude (regras + comandos)
CONTEXT.md       ← cenário, particularidades do Ubuntu 25, fontes de verdade
PLAN.md          ← fases com critérios de pronto
AGENTS.md        ← papéis: Inventariador, Classificador, Gerador Ansible, Validador
MANUAL.md        ← passos manuais (segredos, logins, VPN)
INVENTORY.md / UNKNOWN.md ← preenchidos pelo Claude
scripts/
  inventory.sh      ← coleta somente-leitura, sem sudo, sem segredos
  diff-inventory.sh ← compara atual vs novo
  bootstrap-new.sh  ← roda no notebook novo
ansible/
  site.yml, group_vars/all.yml (variáveis a preencher), roles/* (uma por origem de pacote)
```

## Uso rápido
1. Abra a pasta no VS Code com Claude Code e peça: *"Execute a Fase 1 do PLAN.md"*.
2. Depois: *"Execute a Fase 2"* (classificação) e *"Fase 3"* (preencher `group_vars/all.yml`, validar com `--check`).
3. Commit no GitLab. No notebook novo: `REPO_URL=<url> bash scripts/bootstrap-new.sh`.
