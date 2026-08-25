# ani-cli — anime en VF/VOSTFR depuis le terminal

Fork enrichi de [ani-cli](https://github.com/pystardust/ani-cli) : recherchez, regardez et téléchargez des animes en ligne de commande, avec **trois sources** au choix dont deux francophones.

> ⚠️ **Avertissement légal** : ani-cli n'héberge aucun contenu. Il interroge des sites tiers (anidb.app, anime-sama, franime.fr) et n'en est pas affilié. Vérifiez la législation de votre pays avant utilisation — voir [`disclaimer.md`](disclaimer.md).

---

## Sommaire

1. [Fonctionnalités](#-fonctionnalités)
2. [Installation](#-installation)
3. [Mettre à jour la commande](#-mettre-à-jour-la-commande)
4. [Désinstaller](#-désinstaller)
5. [Site par défaut](#-site-par-défaut)
6. [Démarrage rapide](#-démarrage-rapide)
7. [Les trois sources en détail](#-les-trois-sources-en-détail)
8. [Toutes les options en ligne de commande](#-toutes-les-options-en-ligne-de-commande)
9. [Menu pendant la lecture](#-menu-pendant-la-lecture)
10. [Variables d'environnement](#-variables-denvironnement)
11. [Fichier de configuration](#-fichier-de-configuration)
12. [Fichiers utilisés](#-fichiers-utilisés)
13. [Dépendances](#-dépendances)
14. [Dépannage](#-dépannage)
15. [Crédits & licence](#-crédits--licence)

---

## ✨ Fonctionnalités

| Source | Contenu | VF | VOSTFR | Autres langues |
|---|---|:--:|:--:|---|
| **anime-sama** (`--site anime-sama`) | large catalogue FR | ✅ | ✅ | — |
| **franime** (`--site franime`) | catalogue FR sans pub | ✅ | ✅ | — |
| **anidb** (défaut) | catalogue international | parfois | — | jpn, eng… |

- 🇫🇷 Sur anime-sama et franime : **VF par défaut**, repli **automatique en VOSTFR** épisode par épisode
- 🌐 Domaine actif d'anime-sama **résolu automatiquement** via la liste officielle de `anime-sama.pw` (si un domaine tombe, le suivant est essayé : `.si → .tv → .to → .org → .fr → .eu`)
- 🔁 Essai automatique de plusieurs **lecteurs** par épisode (sibnet, vidmoly, sendvid…) jusqu'à trouver un flux exploitable
- 🎚️ Qualité au choix, menus `fzf`/`rofi`/`dmenu`, historique de reprise multi-sources, téléchargement, Syncplay
- 🔤 Sur anidb : langue de dub avec liste de priorités et repli (`--dub-lang fre,eng,jpn`)
- 🧩 Changement de langue, saison et qualité à la volée pendant la lecture

---

## 📦 Installation

Ouvrez un terminal dans le dossier du projet (`ani-cli-master/`), puis selon votre système :

### Linux
```sh
./install/install-linux.sh                  # installation utilisateur (~/.local/bin)
sudo ./install/install-linux.sh --system    # installation système (/usr/local/bin)
```

### macOS
```sh
./install/install-macos.sh                  # (~/.local/bin)
sudo ./install/install-macos.sh --system
```

### Windows — Git Bash / MSYS2 / WSL
```sh
./install/install-windows.sh                # installe dans ~/bin
```
Prérequis Windows : [mpv](https://mpv.io) (ou VLC) installé et présent dans le PATH ; curl/sed/grep sont fournis par Git Bash.

### Android — Termux
```sh
pkg install -y curl mpv fzf
./install/install-termux.sh                 # installe dans $PREFIX/bin
```

### Ce que font les installateurs
1. copient `ani-cli` dans un dossier du PATH,
2. installent la page de manuel (`man ani-cli`),
3. ajoutent le dossier au PATH si nécessaire (`.bashrc`, `.zshrc` ou `.profile`),
4. posent la question du **site par défaut** et écrivent `~/.config/ani-cli/ani-cli.conf`,
5. vérifient que la commande répond.

Mode non interactif (scripts d'env, CI) :
```sh
ANI_INSTALL_SITE=franime ./install/install-linux.sh   # anidb | anime-sama | franime
```

### Installation manuelle (sans script)
```sh
cp ani-cli ~/.local/bin/ && chmod +x ~/.local/bin/ani-cli
mkdir -p ~/.local/share/man/man1 && cp ani-cli.1 ~/.local/share/man/man1/
```

---

## 🔄 Mettre à jour la commande

Après avoir modifié `ani-cli` dans ce dossier (ou récupéré une nouvelle version), propagez vos changements vers la commande installée :

```sh
./install/modif-update.sh            # déploie vers l'installation détectée
./install/modif-update.sh --check    # affiche s'il y a des changements, sans rien faire
sudo ./install/modif-update.sh --system   # cible /usr/local/bin
```

Le script :
- **détecte automatiquement** où ani-cli est installé (`~/.local/bin`, `$PREFIX/bin`, `~/bin`, `/usr/local/bin`) ;
- **refuse de déployer** un code source contenant une erreur de syntaxe (`sh -n` avant copie) ;
- ne recopie rien si les fichiers sont identiques (`cmp`) ;
- synchronise aussi la page de manuel ;
- affiche l'ancienne et la nouvelle version.

À ne pas confondre avec **`ani-cli -U`** : cette option intégrée télécharge la version officielle *upstream* depuis GitHub et patche la copie installée — vos modifications locales seraient perdues. Après un `ani-cli -U`, relancez une synchronisation inverse si besoin, ou préférez `modif-update.sh` pour rester sur votre fork.

---

## 🗑️ Désinstaller

```sh
rm -f ~/.local/bin/ani-cli ~/.local/share/man/man1/ani-cli.1
rm -rf ~/.config/ani-cli              # configuration
rm -rf ~/.local/state/ani-cli         # historique
```
(Adaptez les chemins si vous avez utilisé `--system`, Termux ou `~/bin`.)

---

## ⚙️ Site par défaut

Trois moyens, par ordre de **priorité croissante** :

1. **Fichier de configuration** — `~/.config/ani-cli/ani-cli.conf`
   ```sh
   site=franime        # anidb | sama | franime (alias anime-sama accepté)
   ```
2. **Variable d'environnement**
   ```sh
   export ANI_CLI_SITE=anime-sama
   ```
3. **Ligne de commande** (ponctuel)
   ```sh
   ani-cli --site sama one piece
   ```

Sur anime-sama et franime, la lecture démarre **en VF** et bascule automatiquement en **VOSTFR** quand un épisode n'a pas de VF. Pour forcer la VOSTFR strictement : `ANI_CLI_MODE=sub`. Pendant la lecture, `change_language` bascule VF ↔ VOSTFR à la volée.

---

## 🚀 Démarrage rapide

```sh
ani-cli                               # recherche interactive (site par défaut)
ani-cli naruto                        # recherche directe
ani-cli --site sama "spy x family"    # anime-sama, VF auto
ani-cli --site franime one piece      # franime, VF auto
ani-cli --dub-lang fre,eng cyberpunk edgerunners   # anidb : dub fr puis en

ani-cli -e 5 blue lock                # épisode 5
ani-cli -e 1-12 --site sama one piece # plage d'épisodes
ani-cli -e "3 7 9" blue lock          # épisodes non contigus (multi-sélection)
ani-cli -S 2 -e 4 naruto              # 2e résultat, ép. 4 : tout non interactif

ani-cli -d --site sama one piece -e 1          # télécharger (dossier courant)
ANI_CLI_DOWNLOAD_DIR=~/Videos ani-cli -d ...   # autre dossier

ani-cli -c                            # reprendre l'historique
ani-cli -q 720p one piece             # qualité précise
ani-cli -v one piece                  # lire avec VLC
ani-cli --skip one piece              # skip intro (mpv + ani-skip)
ani-cli -N one piece                  # compte à rebours prochain épisode (anidb)
man ani-cli                           # aide complète
```

---

## 🌍 Les trois sources en détail

### anime-sama (`--site anime-sama`)
- Recherche POST sur le site, choix de la **saga/saison** puis des épisodes.
- Langues par fichier d'épisodes : `vf` et `vostfr` ; si la langue préférée manque pour un épisode → repli automatique sur l'autre avec message.
- Lecteurs essayés dans l'ordre jusqu'à obtenir un flux direct (sibnet → mp4 CDN, ansembed/vidmoly → m3u8…).
- Entrées « scan » (manga sans saison animée) ignorées automatiquement en mode `-S`.

### franime (`--site franime`)
- Catalogue complet via l'API officielle (`api.franime.fr`), index local mis en cache 24 h.
- Choix de la saison puis des épisodes ; flux résolus par lecteur déclaré (sibnet privilégié, puis vidmoly, sendvid…), après décryptage du lien `watch2`.
- Nécessite `python3` **ou** `jq`.

### anidb (défaut)
- Sub = japonais ; `--dub` cherche la première langue disponible de `--dub-lang` (défaut `fre eng` : français puis anglais) avec message explicite.
- Sélecteur de qualité natif du site (best/worst/1080/720/…), compte à rebours `-N` via animeschedule.net.

---

## 📋 Toutes les options en ligne de commande

| Option | Description |
|---|---|
| `-c`, `--continue` | Reprendre depuis l'historique |
| `-d`, `--download` | Télécharger au lieu de lire |
| `-D`, `--delete` | Effacer l'historique |
| `-l`, `--logview` | Voir les logs de lecture |
| `-s`, `--syncplay` | Regarder à plusieurs via Syncplay (mpv) |
| `-S`, `--select-nth <n>` | Choisir directement le nième résultat (non interactif) |
| `-q`, `--quality <q>` | Qualité : best, worst, 360, 480, 720, 1080 |
| `-v`, `--vlc` | Lire avec VLC |
| `-V`, `--version` | Afficher la version |
| `-h`, `--help` | Aide |
| `-e`, `--episode`, `-r`, `--range <ep>` | Épisode(s) : `4`, `1-12`, `"3 7 9"` |
| `--dub` | Version doublée (anidb : `fre`→`eng` par défaut ; sama/franime : VF) |
| `-L`, `--dub-lang <langs>` | Langues de dub prioritaires, séparées par virgules (anidb). Codes ou noms : `fre,french,jpn,japanese…`. Implique `--dub` |
| `--site <nom>` | Source : `anidb`, `anime-sama`, `franime` |
| `--rofi` / `--dmenu` | Frontend de menu alternatif |
| `--skip` | Skip intro via ani-skip (mpv) |
| `--no-detach` | Lecteur au premier plan (mpv, pratique dans le terminal) |
| `--exit-after-play` | Quitter avec le code de retour du lecteur |
| `-N`, `--nextep-countdown` | Compte à rebours du prochain épisode (anidb uniquement) |
| `-U`, `--update [branche]` | Mettre à jour depuis le dépôt upstream GitHub |

---

## 🎛️ Menu pendant la lecture

| Entrée | Effet |
|---|---|
| `next` / `previous` / `replay` | Navigation séquentielle / rejouer |
| `select` | Multi-sélection d'épisodes (fzf/rofi) |
| `change_season` | Changer de saison/saga (toutes sources) |
| `change_language` | VF ↔ VOSTFR (sama/franime) ou langue audio exacte (anidb) |
| `change_quality` | Autre qualité (anidb uniquement) |
| `quit` | Sortir |

Raccourcis fzf utiles : `Tab` multi-sélection, `Entrée` valider, flèches/Ctrl+n/p naviguer.

---

## 🌐 Variables d'environnement

| Variable | Rôle | Défaut |
|---|---|---|
| `ANI_CLI_SITE` | Source par défaut (`anidb`, `anime-sama`, `franime`) | `anidb` |
| `ANI_CLI_MODE` | Mode de départ (`sub`, `dub`). `sub` force la VOSTFR stricte sur sama/franime | `sub` |
| `ANI_CLI_DUB_LANG` | Langues de dub prioritaires (anidb) | `fre eng` |
| `ANI_CLI_QUALITY` | Qualité | `best` |
| `ANI_CLI_DOWNLOAD_DIR` | Dossier de téléchargement | `.` |
| `ANI_CLI_PLAYER` | Lecteur : mpv, vlc, iina, syncplay, catt, debug, download… | auto-détecté |
| `ANI_CLI_PLAYER_FLAGS` | Options passées au lecteur | aucune |
| `ANI_CLI_MENU` | Frontend : fzf, rofi, dmenu | `fzf` |
| `ANI_CLI_MENU_FLAGS` | Options du frontend | aucune |
| `ANI_CLI_HIST_DIR` | Dossier de l'historique | `~/.local/state/ani-cli` |
| `ANI_CLI_CONFIG` | Chemin du fichier de config personnalisé | voir ci-dessous |
| `ANI_CLI_LOG` | Logger les épisodes vus (0/1) | `1` |
| `ANI_CLI_SKIP_INTRO` | Skip intro automatique (0/1) | `0` |
| `ANI_CLI_NO_DETACH` | Lecteur attaché au terminal (0/1) | `0` |
| `ANI_CLI_EXIT_AFTER_PLAY` | Quitter après la lecture (0/1) | `0` |
| `ANI_CLI_DEFAULT_SOURCE` | Démarrer sur `history` plutôt que la recherche | `search` |
| `ANI_CLI_BRANCH` | Branche utilisée par `-U` | `master` |

---

## 🗃️ Fichier de configuration

Chemin : `~/.config/ani-cli/ani-cli.conf` (personnalisable via `ANI_CLI_CONFIG`).

C'est un script shell sourcé au démarrage : chaque clé porte le nom de la variable interne **sans** le préfixe `ANI_CLI_`. Exemple complet :

```sh
# ~/.config/ani-cli/ani-cli.conf
site=sama                # anidb | sama | franime
quality=best             # best | worst | 360 | 480 | 720 | 1080
mode=dub                 # sub|dub — ANI_CLI_MODE reste prioritaire
dub_langs=fre eng        # priorités de dub (source anidb)
download_dir=~/Videos
menu_program=fzf         # fzf | rofi | dmenu
player_function=mpv      # mpv | vlc | iina | syncplay | debug | download…
skip_intro=0
log_episode=1
```

Priorité : **défauts intégrés < config < variables d'environnement < options CLI**.
Écrivez le fichier en fins de ligne Unix (LF). Les installateurs créent/mettent à jour la clé `site` proprement.

---

## 📁 Fichiers utilisés

| Fichier | Rôle |
|---|---|
| `~/.config/ani-cli/ani-cli.conf` | Configuration persistante |
| `~/.local/state/ani-cli/ani-hsts` | Historique (`épisode \t id \t titre`) ; les entrées mémorisent la source et la saison : `sama:naruto@saison1`, `franime:11@0` |
| `~/.local/state/ani-cli/franime-index.tsv` | Cache de recherche franime (24 h) |
| `~/.local/state/ani-cli/franime-<id>.json` | Détails d'un anime franime |

---

## 🧰 Dépendances

| Type | Paquets |
|---|---|
| Obligatoires | curl, sed, grep, awk, tput (ncurses) |
| Fortement conseillés | fzf (menus), mpv ou vlc (lecture) |
| Selon usage | yt-dlp **ou** ffmpeg (`-d`) · python3 **ou** jq (source franime) · rofi/dmenu · syncplay · ani-skip (`--skip`) |

💡 Sur anidb, en cas de « Blocked by cloudflare », installez `curl-impersonate` (ex. `curl-chrome116`) : ani-cli l'utilise automatiquement s'il est présent.

---

## 🛠️ Dépannage

| Symptôme | Solution |
|---|---|
| « Could not extract any playable stream » | Le lecteur web du moment est indisponible ; ani-cli essaie les suivants automatiquement — réessayez ou changez d'épisode/lecteur via `change_language` |
| « Blocked by cloudflare » (anidb) | Installer curl-impersonate (voir ci-dessus) |
| « FRAnime source requires python3 or jq » | `sudo apt install python3` (ou jq) |
| « No anime seasons found for this entry » | Résultat correspondant à un scan/manga ; lancez une recherche plus précise |
| Domaines anime-sama injoignables | Tous sont testés via `anime-sama.pw` ; vérifiez la connexion/DNS |
| La commande n'existe pas après installation | Ouvrez un nouveau terminal ou `source ~/.profile` |
| Historique cassé | `ani-cli -D` efface tout ; sauvegardez `~/.local/state/ani-cli/ani-hsts` avant manipulation |
| Windows : aucun son/lecteur | Installer mpv.exe et l'ajouter au PATH Windows, puis rouvrir Git Bash |

---

## ❓ FAQ

- **Puis-je regarder en VF ?** Oui : `--site anime-sama` ou `--site franime`, c'est même la langue par défaut (repli VOSTFR automatique).
- **Puis-je choisir la langue de dub sur anidb ?** Oui : `--dub-lang fre,eng,jpn` (ou noms : `french,japanese`), avec repli par épisode.
- **Comment changer la langue en cours de lecture ?** Menu → `change_language`.
- **Ça marche hors du dossier du projet ?** Oui, une fois installé : `ani-cli` partout. Après toute modification du code source, relancez `./install/modif-update.sh`.
- **Je peux changer la source de streaming ?** Non (sauf scraper vous-même), mais vous avez le choix entre trois sites.

---

## 📄 Crédits & licence

- Projet original : [pystardust/ani-cli](https://github.com/pystardust/ani-cli) — GPL-3.0 ([LICENSE](LICENSE))
- Extensions de ce fork : sources anime-sama & FRAnime (VF/VOSTFR auto), sélection multi-langues anidb, site par défaut via config, installateurs multi-OS, script de mise à jour locale, documentation française
