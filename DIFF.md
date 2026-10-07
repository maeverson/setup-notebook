# DIFF — antigo (`inventory/`, Dell T-N2965) vs novo (`inventory-novo/`, Lenovo PE0F644R)

Gerado em 2026-10-07 após a Fase 4 (`site.yml`: 2ª execução com failed=0; `--check` seguinte com **changed=0**).
Veredito: **só diferenças esperadas.** Nenhum item do antigo ficou sem tratamento: cada um foi instalado
ou está em MANUAL.md / UNKNOWN.md.

## Esperadas (decisões documentadas)
| Diferença | Motivo |
|---|---|
| `adcli`, `realmd`, `sssd*`, `libnss-sss`, `libpam-sss`, `oddjob*`, `samba-common-bin`, `packagekit` e `oddjobd.service` só no antigo | Ingresso no AD desligado (`ad_join_enabled: false`); no novo o usuário é local → MANUAL.md |
| `language-pack-en*` → `language-pack-pt*`, `hyphen-pt-*`, `mythes-pt-pt`, `*-l10n-pt*`, `thunderbird-locale-pt*`, `gnome-user-docs-pt` | O novo foi instalado em pt_BR |
| snap `code` só no antigo; apt `code` só no novo | VS Code pelo repo Microsoft |
| snap `libreoffice` só no antigo | O novo usa o LibreOffice .deb |
| snap `test-edge-only` só no antigo; `core` (16) só no antigo | Snap de teste / base antiga sem dependente |
| `google-cloud-cli` 587 → 588, `gnome-46-2404` rev 164 → 168 | Versão/revisão mais nova |
| `libglib2.0-0t64` manual só no antigo | No novo é dependência automática (base) |
| Pacotes manuais a mais no novo: `docker-buildx`, `docker-compose-v2`, `python3-psutil`, `htop`, `tree`, `zip`, `software-properties-common`, `gcc`, `dconf-cli`, `gnome-tweaks`, `gnome-shell-extension-manager` | Instalados pelas roles `base`, `docker` e `desktop` (já eram dependências no antigo ou foram explicitados) |
| Pacotes manuais a mais no novo: `ubuntu-desktop`, `linux-generic-hwe-24.04`, `openssh-server`, `cpanminus`, `perl`, `libnet-*-perl`, `libxml-simple-perl`, `gpg` | Vieram da imagem do TI (o OCS Inventory usa os perls) |
| `npm-global.txt`: o novo lista `/usr/lib` (npm 10.9.9 + corepack) | Artefato da coleta: o `inventory.sh` roda sem carregar o nvm e pega o node do sistema (NodeSource 22). Os globais via nvm conferem: @github/copilot, @sonar/scan, @stripe/cli, @usebruno/cli e snyk em node v26.5.0 |
| `pipx.txt`: `ansible`, `gdown` no novo | ansible do bootstrap; gdown substitui o pip do sistema do antigo |
| `vscode-extensions.txt` | No antigo veio vazio (ver UNKNOWN.md) |
| Serviços só no novo: `disable-usb-storage`, `stagentd`, `ssh` | Imagem do TI (bloqueio de USB, agente Netskope, servidor SSH) |

## Pontos de atenção
- **`ssh.service` habilitado no novo** (`openssh-server` veio da imagem do TI; no antigo não estava). Se não for política do TI, considere desabilitar.
- O grupo `docker` só passa a valer **após reboot/logout**.

## Diff bruto (`scripts/diff-inventory.sh inventory inventory-novo`)


## apt-manual.txt
```
1d0
< adcli
9a9,10
> code
> cpanminus
12a14
> dconf-cli
16a19,20
> docker-buildx
> docker-compose-v2
24a29
> gcc
25a31,33
> gnome-shell-extension-manager
> gnome-tweaks
> gnome-user-docs-pt
27a36
> gpg
33a43,45
> htop
> hyphen-pt-br
> hyphen-pt-pt
40,43c52,56
< language-pack-en
< language-pack-en-base
< language-pack-gnome-en
< language-pack-gnome-en-base
---
> language-pack-gnome-pt
> language-pack-gnome-pt-base
> language-pack-pt
> language-pack-pt-base
> libasound2t64
51d63
< libglib2.0-0t64
55a68,69
> libnet-ip-perl
> libnet-snmp-perl
58d71
< libnss-sss
62d74
< libpam-sss
64a77,81
> libreoffice-help-common
> libreoffice-help-pt
> libreoffice-help-pt-br
> libreoffice-l10n-pt
> libreoffice-l10n-pt-br
66a84,85
> libxml-simple-perl
> linux-generic-hwe-24.04
71a91
> mythes-pt-pt
75,76d94
< oddjob
< oddjob-mkhomedir
80c98,99
< packagekit
---
> openssh-server
> perl
84a104
> python3-psutil
86,87d105
< realmd
< samba-common-bin
89,90c107
< sssd
< sssd-tools
---
> software-properties-common
91a109,111
> thunderbird-locale-pt
> thunderbird-locale-pt-br
> thunderbird-locale-pt-pt
92a113,114
> tree
> ubuntu-desktop
102a125
> zip
```

## snap.txt
```
3,4d2
< code                         07f806f9                        267    latest/stable    vscode**            classic
< core                         16-2.61.4-20260225              17292  latest/stable    canonical**         core
15,16c13,14
< gnome-46-2404                0+git.b31ceab-sdk0+git.f0723a0  164    latest/stable    canonical**         -
< google-cloud-cli             587.0.0                         503    latest/stable    google-cloud-sdk**  classic
---
> gnome-46-2404                0+git.b31ceab-sdk0+git.f80dd8b  168    latest/stable    canonical**         -
> google-cloud-cli             588.0.0                         509    latest/stable    google-cloud-sdk**  classic
21d18
< libreoffice                  26.2.5.2                        377    latest/stable    canonical**         -
28c25
< snap-store                   0+git.d2bdf905                  1419   2/stable/…       canonical**         -
---
> snap-store                   0+git.e3dd562                   1173   2/stable/…       canonical**         -
32c29
< test-edge-only               1                               1      latest/edge      robert-ancell       -
---
> thunderbird                  157.0-2                         1279   latest/stable/…  canonical**         -
```

## pipx.txt
```
0a1,2
> ansible 14.5.0
> gdown 6.4.1
```

## npm-global.txt
```
2,8c2,4
< ├── @github/copilot@1.0.74
< /home/maeverson.waitman@CONTABILIZEI.COM.BR/.nvm/versions/node/v26.5.0/lib
< ├── npm@12.0.1
< └── snyk@1.1307.2
< ├── @sonar/scan@5.0.0
< ├── @stripe/cli@1.53.0
< ├── @usebruno/cli@4.0.0
---
> +-- corepack@0.36.0
> `-- npm@10.9.9
> /usr/lib
```

## vscode-extensions.txt
```
0a1
> anthropic.claude-code@2.1.292
```

## gnome-extensions.txt
```
(idêntico)
```

## systemd-system-enabled.txt
```
2c2
< 163 unit files listed.
---
> 150 unit files listed.
35a36
> disable-usb-storage.service                                   enabled enabled
63d63
< oddjobd.service                                               enabled enabled
73d72
< snap-bruno-120.mount                                          enabled enabled
75,78d73
< snap-code-266.mount                                           enabled enabled
< snap-code-267.mount                                           enabled enabled
< snap-core-17292.mount                                         enabled enabled
< snap-core18-2999.mount                                        enabled enabled
80d74
< snap-core20-2866.mount                                        enabled enabled
82c76
< snap-core22-2437.mount                                        enabled enabled
---
> snap-core22-1564.mount                                        enabled enabled
84d77
< snap-core24-1643.mount                                        enabled enabled
88d80
< snap-dbeaver\x2dce-557.mount                                  enabled enabled
97c89
< snap-firefox-8969.mount                                       enabled enabled
---
> snap-firefox-4793.mount                                       enabled enabled
99c91
< snap-firmware\x2dupdater-226.mount                            enabled enabled
---
> snap-firmware\x2dupdater-127.mount                            enabled enabled
103c95
< snap-gnome\x2d42\x2d2204-202.mount                            enabled enabled
---
> snap-gnome\x2d42\x2d2204-176.mount                            enabled enabled
105,107c97,98
< snap-gnome\x2d46\x2d2404-164.mount                            enabled enabled
< snap-google\x2dcloud\x2dcli-499.mount                         enabled enabled
< snap-google\x2dcloud\x2dcli-503.mount                         enabled enabled
---
> snap-gnome\x2d46\x2d2404-168.mount                            enabled enabled
> snap-google\x2dcloud\x2dcli-509.mount                         enabled enabled
109d99
< snap-intellij\x2didea\x2dultimate-826.mount                   enabled enabled
113,114d102
< snap-libreoffice-374.mount                                    enabled enabled
< snap-libreoffice-377.mount                                    enabled enabled
119c107
< snap-snapd-27738.mount                                        enabled enabled
---
> snap-snapd-21759.mount                                        enabled enabled
121c109
< snap-snapd\x2ddesktop\x2dintegration-253.mount                enabled enabled
---
> snap-snapd\x2ddesktop\x2dintegration-178.mount                enabled enabled
123,125c111
< snap-snap\x2dstore-1390.mount                                 enabled enabled
< snap-snap\x2dstore-1419.mount                                 enabled enabled
< snap-spotify-97.mount                                         enabled enabled
---
> snap-snap\x2dstore-1173.mount                                 enabled enabled
127d112
< snap-sublime\x2dtext-245.mount                                enabled enabled
129d113
< snap-teams\x2dfor\x2dlinux-2552.mount                         enabled enabled
131,132c115,116
< snap-test\x2dedge\x2donly-1.mount                             enabled enabled
< snap-zoom\x2dclient-275.mount                                 enabled enabled
---
> snap-thunderbird-1279.mount                                   enabled enabled
> snap-thunderbird-507.mount                                    enabled enabled
133a118,119
> ssh.service                                                   enabled enabled
> ssh.socket                                                    enabled enabled
142a129
> stagentd.service                                              enabled enabled
```
