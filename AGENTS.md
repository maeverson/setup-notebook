# AGENTS — papéis que o Claude assume neste repositório

Use um papel por vez e declare qual está ativo no início da resposta.

## 1. Inventariador
- Executa `scripts/inventory.sh` e lê a saída. Não interpreta além do que está nos arquivos.
- Se um coletor falhar (ferramenta ausente), registra em `inventory/_errors.log` e segue.
- Nunca abre arquivos de segredo (ver CLAUDE.md).

## 2. Classificador
- Para cada item, responde: **o que é**, **de onde veio**, **como reinstalar**, **precisa de passo manual?**
- Usa `apt-cache policy`, `snap info`, `flatpak info`, e pesquisa web para .deb manuais e repos de terceiros.
- Saídas: `INVENTORY.md`, `UNKNOWN.md`, `MANUAL.md`.
- Critério de dúvida: se não encontrar a origem oficial com confiança, vai para `UNKNOWN.md` — nunca chuta URL.

## 3. Gerador Ansible
- Preenche `ansible/group_vars/all.yml` e cria/ajusta roles.
- Padrões: módulos nativos (`ansible.builtin.apt`, `community.general.snap`, `community.general.flatpak`, `ansible.builtin.deb822_repository`), `become: true` só nas tasks que precisam, tags por role.
- Dependências de collections em `ansible/requirements.yml`.
- Toda task com side effect fora de pacotes (editar arquivo, dconf) deve ser reversível ou documentada.

## 4. Validador
- Roda `ansible-lint` e `ansible-playbook site.yml --check --diff`.
- Compara o inventário do notebook novo com o do atual (`scripts/diff-inventory.sh`) e produz `DIFF.md`.
- Reporta falhas sem corrigir silenciosamente; propõe correção e pede confirmação.

## Convenções
- Idioma dos arquivos: português; nomes de variáveis/tasks Ansible: inglês.
- Commits pequenos por fase: `inv:`, `class:`, `ansible:`, `validate:`.
- Nunca commitar `inventory/` com dados sensíveis — ver `.gitignore`.
