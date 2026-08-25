#!/bin/sh
# Installateur ani-cli pour Windows
#
# A exécuter depuis un environnement POSIX sous Windows :
#   - Git Bash   (recommandé, fournit sh/curl/sed/grep)
#   - MSYS2
#   - WSL        (dans ce cas comportement identique à Linux)
#
# Le lecteur vidéo (mpv.exe ou vlc.exe) et curl doivent être installés et
# accessibles dans le PATH Windows.

set -u

SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_FILE="$SRC_DIR/ani-cli"

command -v curl >/dev/null || { echo "Erreur: curl est requis."; exit 1; }
[ -f "$BIN_FILE" ] || { echo "Erreur: ani-cli introuvable dans $SRC_DIR"; exit 1; }

BIN_DIR="${HOME}/bin"
echo "==> Installation d'ani-cli dans $BIN_DIR"
mkdir -p "$BIN_DIR"
cp "$BIN_FILE" "$BIN_DIR/ani-cli"
chmod 755 "$BIN_DIR/ani-cli"

# --- PATH ---
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        echo "==> Ajout de $BIN_DIR au PATH"
        RC=""
        [ -f "$HOME/.bashrc" ] && RC="$HOME/.bashrc"
        [ -z "$RC" ] && RC="$HOME/.bash_profile"
        {
            echo ""
            echo "# ani-cli"
            echo "export PATH=\"\$HOME/bin:\$PATH\""
        } >>"$RC"
        echo "   écrit dans $RC (redémarrez le terminal Git Bash)"
        ;;
esac

# --- Site par défaut ---
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/ani-cli/ani-cli.conf"
DEFAULT_SITE="${ANI_INSTALL_SITE:-}"
if [ -z "$DEFAULT_SITE" ]; then
    printf "Site par défaut ? [anidb/anime-sama/franime] (anidb): "
    read -r DEFAULT_SITE || DEFAULT_SITE=""
fi
case "$DEFAULT_SITE" in
    "" | anidb | A | a) DEFAULT_SITE="anidb" ;;
    sama | anime-sama | S | s) DEFAULT_SITE="sama" ;;
    franime | fr | F | f) DEFAULT_SITE="franime" ;;
    *) echo "Site inconnu '$DEFAULT_SITE', anidb conservé."; DEFAULT_SITE="anidb" ;;
esac

mkdir -p "$(dirname "$CONF")"
if [ -f "$CONF" ] && grep -q "^site=" "$CONF"; then
    sed "s|^site=.*|site=$DEFAULT_SITE|" "$CONF" >"${CONF}.tmp" && mv "${CONF}.tmp" "$CONF"
elif [ -f "$CONF" ]; then
    printf "site=%s\n" "$DEFAULT_SITE" >>"$CONF"
else
    {
        echo "# Configuration ani-cli"
        echo "# Sources possibles: anidb, sama (anime-sama), franime"
        echo "site=$DEFAULT_SITE"
    } >"$CONF"
fi
echo "==> Site par défaut: $DEFAULT_SITE ($CONF)"

# --- Vérification ---
export PATH="$BIN_DIR:$PATH"
echo ""
if ani-cli --version 2>/dev/null; then
    echo "Installation réussie ! Lancez simplement: ani-cli"
else
    echo "Installé, mais redémarrez votre terminal d'abord."
fi

command -v mpv >/dev/null || command -v mpv.exe >/dev/null || \
    command -v vlc >/dev/null || command -v vlc.exe >/dev/null || \
    echo "Attention: aucun lecteur détecté. Installez mpv (https://mpv.io) et ajoutez-le au PATH."
command -v fzf >/dev/null || echo "Astuce: installez fzf pour les menus interactifs."
