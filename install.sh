#!/usr/bin/env bash
# Set up this repo's tmux config and custom scripts on a machine.
#
# - Symlinks .tmux.conf into place.
# - Installs TPM if it isn't already present.
# - Copies custom scripts into ~/.tmux/.
# - Patches scripts/tmux-pop/pop.sh over the TPM-installed copy, since
#   TPM would otherwise overwrite our tweaked version with upstream's.
# - Patches tmux-agent-status's sidebar.sh and status-summary.sh over the
#   TPM-installed copy, for the same reason (token-light recolor).
# - Symlinks kanagawa-tmux/ into ~/.tmux/plugins/, since it's a custom
#   fork managed entirely in this repo rather than through TPM.
# - Wires tmux-agent-status's Claude Code hooks into ~/.claude/settings.json,
#   and a custom Copilot CLI hook into ~/.copilot/hooks/.
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

AGENT_STATUS_DIR="$TMUX_DIR/plugins/tmux-agent-status"
if [ -d "$AGENT_STATUS_DIR" ]; then
    install -m 755 "$REPO_DIR/scripts/tmux-agent-status/sidebar.sh" "$AGENT_STATUS_DIR/scripts/sidebar.sh"
    install -m 644 "$REPO_DIR/scripts/tmux-agent-status/lib/status-summary.sh" "$AGENT_STATUS_DIR/scripts/lib/status-summary.sh"
    echo "Patched tmux-agent-status's sidebar.sh and status-summary.sh (token-light colors) -> $AGENT_STATUS_DIR/scripts"

    CLAUDE_HOOK_SCRIPT="$AGENT_STATUS_DIR/hooks/better-hook.sh"
    python3 "$REPO_DIR/scripts/setup-claude-hooks.py" "$HOME/.claude/settings.json" "$CLAUDE_HOOK_SCRIPT"

    install -m 755 "$REPO_DIR/scripts/tmux-agent-status/hooks/copilot-hook.sh" "$AGENT_STATUS_DIR/hooks/copilot-hook.sh"
    echo "Installed copilot-hook.sh -> $AGENT_STATUS_DIR/hooks/copilot-hook.sh"

    COPILOT_HOOKS_DIR="$HOME/.copilot/hooks"
    mkdir -p "$COPILOT_HOOKS_DIR"
    COPILOT_HOOK_SCRIPT="$AGENT_STATUS_DIR/hooks/copilot-hook.sh"
    cat > "$COPILOT_HOOKS_DIR/tmux-agent-status.json" <<EOF
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "type": "command", "bash": "$COPILOT_HOOK_SCRIPT sessionStart" }
    ],
    "userPromptSubmitted": [
      { "type": "command", "bash": "$COPILOT_HOOK_SCRIPT userPromptSubmitted" }
    ],
    "preToolUse": [
      { "type": "command", "bash": "$COPILOT_HOOK_SCRIPT preToolUse" }
    ],
    "agentStop": [
      { "type": "command", "bash": "$COPILOT_HOOK_SCRIPT agentStop" }
    ]
  }
}
EOF
    echo "Wrote Copilot CLI hooks -> $COPILOT_HOOKS_DIR/tmux-agent-status.json"
else
    echo "tmux-agent-status not installed yet - run 'tmux' then prefix + I to install plugins,"
    echo "then re-run this script to patch its sidebar/status-line colors and wire up the"
    echo "Claude Code and Copilot CLI hooks."
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
