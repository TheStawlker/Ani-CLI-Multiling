#!/bin/sh
# modif-update : déploie la version du dossier source vers la commande installée
#
# Usage:
#   ./install/modif-update.sh            met à jour l'installation utilisateur
#   ./install/modif-update.sh --check    affiche uniquement s'il y a des changements
#   ./install/modif-update.sh --system   cible /usr/local/bin (sudo requis)
#
# Note: `ani-cli -U` est différent — il récupère la version officielle upstream
# et patche la copie installée. Ce script, lui, propage VOS modifications locales.

set -u

SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_FILE="$SRC_DIR/ani-cli"
MAN_FILE="$SRC_DIR/ani-cli.1"

CHECK=0
SYSTEM=0
for _arg in "$@"; do
    case "$_arg" in
        --check) CHECK=1 ;;
        --system) SYSTEM=1 ;;
        *) echo "Option inconnue: $_arg (valides: --check, --system)"; exit 1 ;;
    esac
done

[ -f "$BIN_FILE" ] || { echo "Erreur: $BIN_FILE introuvable."; exit 1; }

# garde-fou : ne jamais déployer un script cassé
if ! sh -n "$BIN_FILE" 2>/dev/null; then
    echo "Erreur: le script source contient une erreur de syntaxe, mise à jour annulée."
    sh -n "$BIN_FILE"
    exit 1
fi

# --- localisation de l'installation ---
if [ "$SYSTEM" = 1 ]; then
    BIN_DIR="/usr/local/bin"
    MAN_DIR="/usr/local/share/man/man1"
    SUDO="sudo"
else
    BIN_DIR=""
    for _d in "${HOME}/.local/bin" "${PREFIX:-}/bin" "${HOME}/bin" "/usr/local/bin"; do
        [ -n "$_d" ] && [ -f "$_d/ani-cli" ] && { BIN_DIR="$_d"; break; }
    done
    [ -z "$BIN_DIR" ] && BIN_DIR="${HOME}/.local/bin"
    MAN_DIR="${HOME}/.local/share/man/man1"
    SUDO=""
fi

INSTALLED="$BIN_DIR/ani-cli"
if [ ! -f "$INSTALLED" ]; then
    echo "ani-cli n'est pas encore installé dans $BIN_DIR."
    echo "Lancez d'abord: ./install/install-$(uname -s | tr '[:upper:]' '[:lower:]').sh  (ou installez manuellement)"
    exit 1
fi

# --- comparaison ---
if cmp -s "$BIN_FILE" "$INSTALLED"; then
    echo "Déjà à jour ($INSTALLED == source). Rien à faire."
    exit 0
fi

OLD_VER="$(grep -m1 '^version_number=' "$INSTALLED" | tr -d '"' | cut -d '=' -f 2)"
NEW_VER="$(sh -c "sh -n '$BIN_FILE' && sed -nE 's|^version_number=\"([^\"]+)\"\$|\\1|p' '$BIN_FILE'")"

if [ "$CHECK" = 1 ]; then
    echo "Changements détectés :"
    echo "  installée : v$OLD_VER ($(cmp -s "$MAN_FILE" "$MAN_DIR/ani-cli.1" 2>/dev/null && echo 'man identique' || echo 'man différent ou absent'))"
    echo "  source    : v${NEW_VER:-?}"
    echo "Relancez sans --check pour appliquer."
    exit 0
fi

# --- déploiement ---
$SUDO cp "$BIN_FILE" "$INSTALLED" || exit 1
$SUDO chmod 755 "$INSTALLED"
if [ -f "$MAN_FILE" ]; then
    $SUDO mkdir -p "$MAN_DIR" 2>/dev/null
    $SUDO cp "$MAN_FILE" "$MAN_DIR/ani-cli.1" 2>/dev/null || true
fi

echo "Commande mise à jour :"
[ "$OLD_VER" != "$NEW_VER" ] && echo "  version : v$OLD_VER -> v${NEW_VER:-?}" || echo "  version : v$NEW_VER (contenu modifié)"
echo "  cible   : $INSTALLED"

# --- vérification finale ---
if command -v ani-cli >/dev/null 2>&1; then
    ani-cli --version >/dev/null 2>&1 && echo "OK: ani-cli opérationnel." \
        || echo "Attention: ani-cli ne répond pas (rechargez votre shell ?)."
else
    echo "Rechargez votre shell (source ~/.profile) puis testez: ani-cli --version"
fi
