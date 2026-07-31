# tmux-conf

My tmux configuration, tracked in git. Plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) and are not part of this repo — they get cloned into `~/.tmux/plugins/` on demand.

`scripts/` holds custom scripts and local patches to plugin files that TPM would otherwise overwrite.

`kanagawa-tmux/` is a custom fork of the [kanagawa-tmux](https://github.com/Jaeyong-Cho/kanagawa-tmux) theme, managed entirely in this repo rather than through TPM.

## Setup on a new machine

1. Clone this repo:

   ```sh
   git clone <this-repo-url> ~/workspace/tmux-conf
   ```

2. Run the installer. It symlinks `.tmux.conf` into place, installs TPM if needed, copies the custom scripts into `~/.tmux/`, and symlinks `kanagawa-tmux/` into `~/.tmux/plugins/`:

   ```sh
   ~/workspace/tmux-conf/install.sh
   ```

3. Start tmux and install the plugins:

   ```sh
   tmux
   ```

   Then press `prefix + I` (capital i) inside tmux to fetch and install all plugins listed in `.tmux.conf`.

4. Re-run `install.sh` once more. The first run can't patch `tmux-pop`'s `pop.sh` or `tmux-agent-status`'s sidebar/status-line until TPM has installed those plugins — this second pass copies our tweaked versions over the upstream ones and wires up the Claude Code and Copilot CLI hooks:

   ```sh
   ~/workspace/tmux-conf/install.sh
   ```

5. `install.sh` wires up Claude Code hooks in `~/.claude/settings.json` and Copilot CLI hooks in `~/.copilot/hooks/tmux-agent-status.json` automatically. For Codex, follow [the plugin's Codex CLI setup](https://github.com/samleeney/tmux-agent-status#codex-cli-setup) manually.

## Custom scripts

- `scripts/ensure-agent-sidebar.sh` — installed to `~/.tmux/ensure-agent-sidebar.sh`. Keeps the tmux-agent-status sidebar visible when a pane is split, intended to be wired up via an `after-split-window` hook.
- `scripts/tmux-pop/pop.sh` — installed over `~/.tmux/plugins/tmux-pop/scripts/pop.sh`. A local tweak to the pane-flash duration/style; upstream TPM updates would otherwise clobber it, so `install.sh` re-patches it back in.
- `scripts/tmux-agent-status/sidebar.sh` and `scripts/tmux-agent-status/lib/status-summary.sh` — installed over the matching files in `~/.tmux/plugins/tmux-agent-status/scripts/`. Recolors the sidebar and status-line segments to the token-light palette instead of upstream's dark-terminal colors; re-patched by `install.sh` after `prefix + U` updates.
- `scripts/tmux-agent-status/hooks/copilot-hook.sh` — installed to `~/.tmux/plugins/tmux-agent-status/hooks/copilot-hook.sh`. tmux-agent-status ships no native Copilot integration, so this is a custom hook script (modeled on the plugin's own `codex-hook.sh`) that writes working/done pane status using [GitHub Copilot CLI's hooks](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks) (`sessionStart`, `userPromptSubmitted`, `preToolUse`, `agentStop`). `install.sh` also writes the hook registration to `~/.copilot/hooks/tmux-agent-status.json`.
- `scripts/setup-claude-hooks.py` — run by `install.sh` (not installed elsewhere). Idempotently merges tmux-agent-status's Claude Code hooks (`UserPromptSubmit`, `PreToolUse`, `Stop`, `Notification`) into `~/.claude/settings.json` without touching existing settings.

## Updating

- Edit `.tmux.conf` in this repo, then `tmux source-file ~/.tmux.conf` (or restart tmux) to apply changes.
- Edit scripts under `scripts/`, then re-run `install.sh` to re-copy them into `~/.tmux/`.
- Edit files under `kanagawa-tmux/` directly — `~/.tmux/plugins/kanagawa-tmux` is a symlink to it, so changes apply immediately without re-running `install.sh`.
- Commit and push changes as usual.
- To update plugins, press `prefix + U` inside tmux. Since this overwrites `tmux-pop/scripts/pop.sh` and tmux-agent-status's `sidebar.sh`/`status-summary.sh` with upstream's versions, re-run `install.sh` afterward to reapply the local patches. `kanagawa-tmux` is untouched by `prefix + U` since it isn't a TPM-managed plugin.
