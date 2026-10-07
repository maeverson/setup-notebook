#!/usr/bin/env bash
# Inventário somente-leitura do notebook atual. NÃO usa sudo. NÃO lê segredos.
# Uso: bash scripts/inventory.sh [dir_saida]   (default: inventory/)
set -uo pipefail
export LC_ALL=C   # saída de apt-cache/snap etc. em inglês: os parsers dependem disso
OUT="${1:-inventory}"; mkdir -p "$OUT"; ERR="$OUT/_errors.log"; : > "$ERR"
run() { # run <arquivo> <comando...>
  local f="$OUT/$1"; shift
  if "$@" > "$f" 2>>"$ERR"; then echo "[ok ] $f"; else echo "[err] $f (ver $ERR)"; fi
}
have() { command -v "$1" >/dev/null 2>&1; }
# Se a ferramenta não existe, zera o arquivo para não sobrar dado de uma coleta anterior.
skip() { : > "$OUT/$1"; echo "[---] $OUT/$1 (ferramenta ausente)"; }

echo "== Sistema =="
run os.txt sh -c 'lsb_release -a 2>/dev/null; echo; uname -a; echo; hostnamectl 2>/dev/null; echo; echo "SHELL=$SHELL"; echo "DESKTOP=$XDG_CURRENT_DESKTOP SESSION=$XDG_SESSION_TYPE"'
run hardware.txt sh -c 'lscpu | head -20; echo; free -h; echo; lsblk; echo; lspci 2>/dev/null | grep -Ei "vga|3d|network|wireless"'
run locale.txt sh -c 'locale; echo; timedatectl 2>/dev/null; echo; cat /etc/default/keyboard 2>/dev/null'

echo "== APT =="
run apt-manual.txt apt-mark showmanual
run dpkg-all.tsv dpkg-query -W -f='${Package}\t${Version}\t${Architecture}\t${db:Status-Abbrev}\n'
# origem da versão instalada de cada pacote manual; "/var/lib/dpkg/status" como única origem => .deb manual
run apt-origins.tsv sh -c '
for p in $(apt-mark showmanual); do
  pol=$(apt-cache policy "$p" 2>/dev/null)
  ver=$(echo "$pol" | awk "/Installed:/{print \$2}")
  origin=$(echo "$pol" | awk "/^ \\*\\*\\* /{f=1;next} f{print \$2; exit}")
  printf "%s\t%s\t%s\n" "$p" "$ver" "${origin:-unknown}"
done'
run apt-sources.txt sh -c 'for f in /etc/apt/sources.list /etc/apt/sources.list.d/*; do [ -f "$f" ] && { echo "### $f"; grep -v "^\s*#" "$f" | grep -v "^\s*$"; echo; }; done'
run apt-keyrings.txt sh -c 'ls -la /etc/apt/keyrings /usr/share/keyrings /etc/apt/trusted.gpg.d 2>/dev/null'
run apt-preferences.txt sh -c 'cat /etc/apt/preferences /etc/apt/preferences.d/* 2>/dev/null'
run apt-history-installs.txt sh -c 'zgrep -h "Commandline:" /var/log/apt/history.log* 2>/dev/null | sort -u'

echo "== Snap / Flatpak / AppImage / opt =="
if have snap; then run snap.txt snap list; else skip snap.txt; fi
if have snap; then run snap-classic.txt sh -c 'snap list | awk "NR>1 && /classic/{print \$1}"'; else skip snap-classic.txt; fi
if have flatpak; then run flatpak.txt flatpak list --app --columns=application,origin,version,installation; else skip flatpak.txt; fi
if have flatpak; then run flatpak-remotes.txt flatpak remotes --columns=name,url; else skip flatpak-remotes.txt; fi
run appimage.txt sh -c 'find ~/Applications ~/apps ~/.local/bin ~/Downloads /opt -maxdepth 2 -iname "*.AppImage" 2>/dev/null'
run opt.txt sh -c 'ls -la /opt 2>/dev/null'
run local-bin.txt sh -c 'echo "## /usr/local/bin"; ls -la /usr/local/bin 2>/dev/null; echo; echo "## ~/.local/bin"; ls -la ~/.local/bin 2>/dev/null'
run usr-local.txt sh -c 'ls -la /usr/local/share /usr/local/lib 2>/dev/null'

echo "== Toolchains de desenvolvimento =="
run dev-versions.txt sh -c '
for c in java javac mvn gradle python3 pip3 pipx node npm pnpm yarn bun go rustc cargo ruby php dotnet terraform kubectl helm gcloud aws az docker podman git gh glab jq yq make cmake gcc clang; do
  if command -v $c >/dev/null 2>&1; then printf "%-16s %s\n" "$c" "$($c --version 2>&1 | head -1)"; fi
done'
run dev-managers.txt sh -c '
for d in ~/.sdkman ~/.nvm ~/.pyenv ~/.asdf ~/.rustup ~/.cargo ~/go ~/.jenv ~/.volta ~/.fnm ~/.local/share/mise; do [ -d "$d" ] && echo "DIR $d"; done
[ -d ~/.sdkman/candidates ] && { echo "## sdkman"; ls ~/.sdkman/candidates/*/ 2>/dev/null; }
[ -d ~/.nvm/versions/node ] && { echo "## nvm"; ls ~/.nvm/versions/node; }
[ -d ~/.pyenv/versions ] && { echo "## pyenv"; ls ~/.pyenv/versions; }
command -v asdf >/dev/null && { echo "## asdf"; asdf list 2>/dev/null; }
command -v mise >/dev/null && { echo "## mise"; mise ls 2>/dev/null; }
command -v rustup >/dev/null && { echo "## rustup"; rustup show 2>/dev/null; }
true'
if have pipx; then run pipx.txt pipx list --short; else skip pipx.txt; fi
if have pip3; then run pip-user.txt pip3 list --user --format=freeze; else skip pip-user.txt; fi
if have npm; then run npm-global.txt npm ls -g --depth=0; else skip npm-global.txt; fi
if have cargo; then run cargo-bin.txt sh -c 'ls ~/.cargo/bin 2>/dev/null'; else skip cargo-bin.txt; fi
run go-bin.txt sh -c 'ls ~/go/bin 2>/dev/null; true'
if have gem; then run gem.txt gem list --local; else skip gem.txt; fi
if have code; then run vscode-extensions.txt code --list-extensions --show-versions; else skip vscode-extensions.txt; fi
run vscode-settings.json sh -c 'cat ~/.config/Code/User/settings.json 2>/dev/null; true'
run vscode-keybindings.json sh -c 'cat ~/.config/Code/User/keybindings.json 2>/dev/null; true'
run jetbrains.txt sh -c 'ls ~/.local/share/JetBrains/Toolbox/apps 2>/dev/null; true'
if have docker; then run docker.txt sh -c 'docker version 2>/dev/null; echo; docker compose version 2>/dev/null; echo; docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null; echo; docker context ls 2>/dev/null; true'; else skip docker.txt; fi
run git-config.txt sh -c 'git config --global --list 2>/dev/null | grep -viE "token|password|credential\.helper=.*store"; true'

echo "== Serviços / cron =="
run systemd-system-enabled.txt systemctl list-unit-files --state=enabled --no-pager
run systemd-user-enabled.txt systemctl --user list-unit-files --state=enabled --no-pager
run cron.txt sh -c 'crontab -l 2>/dev/null; ls /etc/cron.d 2>/dev/null; true'

echo "== Desktop =="
if have dconf; then run dconf-dump.ini dconf dump /; else skip dconf-dump.ini; fi
if have gnome-extensions; then run gnome-extensions.txt gnome-extensions list --enabled; else skip gnome-extensions.txt; fi
run gnome-extensions-dirs.txt sh -c 'ls ~/.local/share/gnome-shell/extensions 2>/dev/null; true'
run fonts-user.txt sh -c 'ls -R ~/.fonts ~/.local/share/fonts 2>/dev/null; true'
run themes.txt sh -c 'ls ~/.themes ~/.icons ~/.local/share/themes ~/.local/share/icons 2>/dev/null; true'
run autostart.txt sh -c 'ls ~/.config/autostart 2>/dev/null; echo; grep -h "^Exec=" ~/.config/autostart/*.desktop 2>/dev/null; true'
run desktop-files-user.txt sh -c 'ls ~/.local/share/applications 2>/dev/null; true'
run default-apps.txt sh -c 'cat ~/.config/mimeapps.list 2>/dev/null; true'
run electron-flags.txt sh -c 'ls ~/.config/*-flags.conf 2>/dev/null; true'

echo "== Shell / dotfiles (somente nomes) =="
run shell.txt sh -c 'echo "$SHELL"; grep "^$USER" /etc/passwd; echo; ls -d ~/.oh-my-zsh ~/.config/starship.toml ~/.config/fish ~/.tmux.conf ~/.config/nvim ~/.vimrc 2>/dev/null; true'
run dotfiles-list.txt sh -c 'ls -A ~ | grep "^\." | grep -vE "^\.(ssh|gnupg|netrc|aws|kube|docker|password-store|cache|local|mozilla)$"; echo; ls -A ~/.config 2>/dev/null; true'
run shell-rc-sources.txt sh -c 'grep -hE "^(source|\.|export PATH|eval)" ~/.bashrc ~/.zshrc ~/.profile ~/.bash_profile ~/.zprofile 2>/dev/null | grep -viE "token|secret|key|password"; true'

echo "== Rede / certs / impressoras (somente nomes) =="
if have nmcli; then run network-connections.txt nmcli -t -f NAME,TYPE,DEVICE connection show; else skip network-connections.txt; fi
run ca-certs-local.txt sh -c 'ls /usr/local/share/ca-certificates 2>/dev/null; true'
run vpn-clients.txt sh -c 'for c in openvpn openconnect wg forticlient globalprotect nordvpn tailscale zerotier-cli; do command -v $c >/dev/null && echo $c; done; true'
if have lpstat; then run printers.txt lpstat -p -d; else skip printers.txt; fi
run hosts-extra.txt sh -c 'grep -vE "^(#|\s*$|127\.|::1|ff0|fe00)" /etc/hosts 2>/dev/null; true'

echo "== Navegadores / comunicação =="
run browsers-comms.txt sh -c 'for c in google-chrome chromium firefox brave-browser microsoft-edge slack teams-for-linux zoom discord telegram-desktop signal-desktop obsidian notion-app postman insomnia dbeaver; do command -v $c >/dev/null && echo "$c -> $(command -v $c)"; done; true'

echo; echo "Inventário salvo em: $OUT/  (erros: $ERR, $(wc -l < "$ERR") linhas)"
