#!/usr/bin/env bash
# Compara dois inventários (atual vs novo). Uso: diff-inventory.sh inventory-atual/ inventory-novo/ > DIFF.md
set -uo pipefail
A="$1"; B="$2"
echo "# DIFF inventário — $A vs $B"
for f in apt-manual.txt snap.txt flatpak.txt pipx.txt npm-global.txt vscode-extensions.txt gnome-extensions.txt systemd-system-enabled.txt; do
  [ -f "$A/$f" ] || continue
  echo; echo "## $f"; echo '```'
  diff <(sort "$A/$f" 2>/dev/null) <(sort "$B/$f" 2>/dev/null) && echo "(idêntico)"
  echo '```'
done
