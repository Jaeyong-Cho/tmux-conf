#!/usr/bin/env bash
# Set up this repo's tmux config and custom scripts on a machine.
#
# - Symlinks .tmux.conf into place.
# - Installs TPM if it isn't already present.
# - Copies custom scripts into ~/.tmux/, including the centered-zoom toggle
#   (prefix+z: power-zoom a pane into its own window, padded to
#   @centered_zoom_width columns, like no-neck-pane.nvim).
# - Patches scripts/tmux-pop/pop.sh and tmux_pop.tmux over the TPM-installed
#   copies, since TPM would otherwise overwrite our tweaked versions with
#   upstream's. tmux_pop.tmux fixes a quoting bug where a hex color's
#   leading '#' gets parsed as a shell comment by run-shell.
# - Symlinks kanagawa-tmux/ into ~/.tmux/plugins/, since it's a custom
#   fork managed entirely in this repo rather than through TPM.
# - Runs tmux-agent-indicator's own installer to wire Claude/Codex/OpenCode
#   hooks, then installs a Copilot CLI hook file and a pi extension since
#   that plugin has no native Copilot or pi support upstream.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_DIR="$HOME/.tmux"
TPM_DIR="$TMUX_DIR/plugins/tpm"

ln -sf "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
echo "Linked .tmux.conf -> $HOME/.tmux.conf"

ln -sf "$REPO_DIR/wezterm.lua" "$HOME/.wezterm.lua"
echo "Linked wezterm.lua -> $HOME/.wezterm.lua"

mkdir -p "$TMUX_DIR"

if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "Installed TPM -> $TPM_DIR"
else
    echo "TPM already installed, skipping"
fi

TMUX_POP_DIR="$TMUX_DIR/plugins/tmux-pop"
if [ -d "$TMUX_POP_DIR" ]; then
    install -m 755 "$REPO_DIR/scripts/tmux-pop/pop.sh" "$TMUX_POP_DIR/scripts/pop.sh"
    install -m 755 "$REPO_DIR/scripts/tmux-pop/tmux_pop.tmux" "$TMUX_POP_DIR/tmux_pop.tmux"
    echo "Patched tmux-pop's pop.sh and tmux_pop.tmux -> $TMUX_POP_DIR"
else
    echo "tmux-pop not installed yet - run 'tmux' then prefix + I to install plugins,"
    echo "then re-run this script to patch scripts/tmux-pop/ files into place."
fi


mkdir -p "$TMUX_DIR/scripts/centered-zoom"
install -m 755 "$REPO_DIR/scripts/centered-zoom/toggle.sh" "$TMUX_DIR/scripts/centered-zoom/toggle.sh"
echo "Installed centered-zoom toggle -> $TMUX_DIR/scripts/centered-zoom/toggle.sh"

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

# Clean up old tmux-agent-status hooks
rm -f "$HOME/.copilot/hooks/tmux-agent-status.json"

# tmux-agent-indicator's installer wires its Claude/Codex/OpenCode hooks into
# shared config files (~/.claude/settings.json, ~/.codex/hooks.json,
# ~/.config/opencode/plugins/). It auto-skips agents that aren't installed
# and de-dupes its own hook entries on re-run, so it's safe to run every time.
if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/accessd/tmux-agent-indicator/main/install.sh | bash
else
    echo "curl not found, skipping tmux-agent-indicator's Claude/Codex/OpenCode hook setup"
fi

# tmux-agent-indicator has no native Copilot CLI integration, so install our
# own hook file. agent-state.sh resolves the plugin dir from the
# TMUX_AGENT_INDICATOR_DIR env var the plugin sets itself, so this file can
# be copied as-is.
mkdir -p "$HOME/.copilot/hooks"
cp "$REPO_DIR/scripts/tmux-agent-indicator/copilot-hooks.json" "$HOME/.copilot/hooks/tmux-agent-indicator.json"
echo "Installed Copilot CLI hooks -> $HOME/.copilot/hooks/tmux-agent-indicator.json"

# tmux-agent-indicator has no native pi (earendil-works/pi) integration
# either, so install our own extension. Global extensions at
# ~/.pi/agent/extensions/*.ts are auto-discovered; agent-state.sh resolves
# the plugin dir the same way as the Copilot hook above.
mkdir -p "$HOME/.pi/agent/extensions"
cp "$REPO_DIR/scripts/tmux-agent-indicator/pi-extension.ts" "$HOME/.pi/agent/extensions/tmux-agent-indicator.ts"
echo "Installed pi coding agent extension -> $HOME/.pi/agent/extensions/tmux-agent-indicator.ts"

echo "Done."
