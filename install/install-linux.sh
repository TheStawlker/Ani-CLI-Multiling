#!/bin/sh
# Installateur ani-cli pour Linux
# Usage: ./install-linux.sh [--system]
#   --system : installe dans /usr/local/bin (sudo requis) au lieu de ~/.local/bin

set -u

SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_FILE="$SRC_DIR/ani-cli"
MAN_FILE="$SRC_DIR/ani-cli.1"

SYSTEM=0
[ "${1:-}" = "--system" ] && SYSTEM=1

if [ "$SYSTEM" = 1 ]; then
    BIN_DIR="/usr/local/bin"
    MAN_DIR="/usr/local/share/man/man1"
    SUDO="sudo"
else
    BIN_DIR="${HOME}/.local/bin"
    MAN_DIR="${HOME}/.local/share/man/man1"
    SUDO=""
fi

command -v curl >/dev/null || { echo "Erreur: curl est requis."; exit 1; }
[ -f "$BIN_FILE" ] || { echo "Erreur: ani-cli introuvable dans $SRC_DIR"; exit 1; }

echo "==> Installation d'ani-cli dans $BIN_DIR"
$SUDO mkdir -p "$BIN_DIR"
$SUDO cp "$BIN_FILE" "$BIN_DIR/ani-cli"
$SUDO chmod 755 "$BIN_DIR/ani-cli"

echo "==> Installation de la page de manuel dans $MAN_DIR"
$SUDO mkdir -p "$MAN_DIR"
$SUDO cp "$MAN_FILE" "$MAN_DIR/ani-cli.1" 2>/dev/null || echo "   (man ignoré)"

# --- PATH ---
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        echo "==> Ajout de $BIN_DIR au PATH"
        RC=""
        [ -f "$HOME/.bashrc" ] && RC="$HOME/.bashrc"
        [ -z "$RC" ] && [ -f "$HOME/.profile" ] && RC="$HOME/.profile"
        [ -z "$RC" ] && RC="$HOME/.profile"
        {
            echo ""
            echo "# ani-cli"
            echo "export PATH=\"$BIN_DIR:\$PATH\""
        } >>"$RC"
        echo "   écrit dans $RC (ouvrez un nouveau terminal ou: source $RC)"
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
    echo "Installé, mais rechargez votre shell d'abord (source $RC ou nouveau terminal)."
fi

command -v mpv >/dev/null || command -v vlc >/dev/null || \
    echo "Attention: aucun lecteur détecté (installez mpv: sudo apt install mpv)."
command -v fzf >/dev/null || echo "Astuce: installez fzf pour les menus interactifs."
