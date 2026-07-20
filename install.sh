#!/usr/bin/env bash
# Set up this repo's tmux config and custom scripts on a machine.
#
# - Symlinks .tmux.conf into place.
# - Installs TPM if it isn't already present.
# - Copies custom scripts into ~/.tmux/.
# - Patches scripts/tmux-pop/pop.sh over the TPM-installed copy, since
#   TPM would otherwise overwrite our tweaked version with upstream's.
# - Symlinks kanagawa-tmux/ into ~/.tmux/plugins/, since it's a custom
#   fork managed entirely in this repo rather than through TPM.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_DIR="$HOME/.tmux"
TPM_DIR="$TMUX_DIR/plugins/tpm"

ln -sf "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
echo "Linked .tmux.conf -> $HOME/.tmux.conf"

mkdir -p "$TMUX_DIR"

if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "Installed TPM -> $TPM_DIR"
else
    echo "TPM already installed, skipping"
fi

install -m 755 "$REPO_DIR/scripts/ensure-agent-sidebar.sh" "$TMUX_DIR/ensure-agent-sidebar.sh"
echo "Installed ensure-agent-sidebar.sh -> $TMUX_DIR/ensure-agent-sidebar.sh"

TMUX_POP_SCRIPT="$TMUX_DIR/plugins/tmux-pop/scripts/pop.sh"
if [ -d "$TMUX_DIR/plugins/tmux-pop" ]; then
    install -m 755 "$REPO_DIR/scripts/tmux-pop/pop.sh" "$TMUX_POP_SCRIPT"
    echo "Patched tmux-pop's pop.sh -> $TMUX_POP_SCRIPT"
else
    echo "tmux-pop not installed yet - run 'tmux' then prefix + I to install plugins,"
    echo "then re-run this script to patch scripts/tmux-pop/pop.sh into place."
fi

KANAGAWA_DIR="$TMUX_DIR/plugins/kanagawa-tmux"
if [ -L "$KANAGAWA_DIR" ]; then
    rm "$KANAGAWA_DIR"
elif [ -d "$KANAGAWA_DIR" ]; then
    rm -rf "$KANAGAWA_DIR"
fi
mkdir -p "$TMUX_DIR/plugins"
ln -sf "$REPO_DIR/kanagawa-tmux" "$KANAGAWA_DIR"
echo "Linked kanagawa-tmux -> $KANAGAWA_DIR"

# copy ./token-light to the $TMUX_DIR/themes/
mkdir -p "$TMUX_DIR/themes"
cp -rf "$REPO_DIR/token-light" "$TMUX_DIR/themes/token-light"

echo "Done."
