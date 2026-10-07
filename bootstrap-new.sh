#!/usr/bin/env bash
# Rodar no notebook NOVO (Ubuntu 25 limpo). Instala git + ansible e executa o playbook localmente.
set -euo pipefail
REPO_URL="${REPO_URL:-}"   # ex.: git@gitlab.com:usuario/notebook-provision.git (vazio se já clonou)
DEST="${DEST:-$HOME/notebook-provision}"

sudo apt update
sudo apt install -y git python3 pipx curl
pipx ensurepath
pipx install --include-deps ansible
pipx inject ansible ansible-lint
export PATH="$HOME/.local/bin:$PATH"

if [ -n "$REPO_URL" ] && [ ! -d "$DEST" ]; then git clone "$REPO_URL" "$DEST"; fi
cd "${DEST}/ansible"
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml --ask-become-pass "$@"
echo; echo ">> Agora siga os passos de ../MANUAL.md"
