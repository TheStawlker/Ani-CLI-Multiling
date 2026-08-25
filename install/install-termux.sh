#!/bin/sh
# Installateur ani-cli pour Android (Termux)
#
# Dépendances suggérées :
#   pkg install -y curl sed grep gawk fzf mpv

set -u

SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_FILE="$SRC_DIR/ani-cli"
MAN_FILE="$SRC_DIR/ani-cli.1"

command -v curl >/dev/null || { echo "Erreur: curl est requis (pkg install curl)."; exit 1; }
[ -f "$BIN_FILE" ] || { echo "Erreur: ani-cli introuvable dans $SRC_DIR"; exit 1; }

BIN_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
echo "==> Installation d'ani-cli dans $BIN_DIR"
mkdir -p "$BIN_DIR"
cp "$BIN_FILE" "$BIN_DIR/ani-cli"
chmod 755 "$BIN_DIR/ani-cli"

echo "==> Installation de la page de manuel"
MAN_DIR="${PREFIX:-/data/data/com.termux/files/usr}/share/man/man1"
mkdir -p "$MAN_DIR" 2>/dev/null && cp "$MAN_FILE" "$MAN_DIR/ani-cli.1" 2>/dev/null || echo "   (man ignoré)"

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
echo ""
if ani-cli --version 2>/dev/null; then
    echo "Installation réussie ! Lancez simplement: ani-cli"
fi

command -v mpv >/dev/null || echo "Attention: mpv absent (pkg install mpv)."
command -v fzf >/dev/null || echo "Astuce: pkg install fzf pour les menus interactifs."
