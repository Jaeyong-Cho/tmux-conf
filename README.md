# tmux-conf

My tmux configuration, tracked in git. Plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) and are not part of this repo — they get cloned into `~/.tmux/plugins/` on demand.

`wezterm.lua` is my [WezTerm](https://wezterm.org/) config: the `token-light` theme (translated from [ThorstenRhau/token](https://github.com/ThorstenRhau/token)'s kitty palette, since wezterm has no native version) and JetBrainsMono Nerd Font. Requires `brew install --cask font-jetbrains-mono-nerd-font`.

`scripts/` holds custom scripts and local patches to plugin files that TPM would otherwise overwrite.

`kanagawa-tmux/` is a custom fork of the [kanagawa-tmux](https://github.com/Jaeyong-Cho/kanagawa-tmux) theme, managed entirely in this repo rather than through TPM.

## Setup on a new machine

1. Clone this repo:

   ```sh
   git clone <this-repo-url> ~/workspace/tmux-conf
   ```

2. Run the installer. It symlinks `.tmux.conf` and `wezterm.lua` into place, installs TPM if needed, copies the custom scripts into `~/.tmux/`, symlinks `kanagawa-tmux/` into `~/.tmux/plugins/`, runs tmux-agent-indicator's own installer (wires Claude Code/Codex/OpenCode hooks, auto-skipping agents not present), and installs the Copilot CLI hook and pi extension:

   ```sh
   ~/workspace/tmux-conf/install.sh
   ```

3. Start tmux and install the plugins:

   ```sh
   tmux
   ```

   Then press `prefix + I` (capital i) inside tmux to fetch and install all plugins listed in `.tmux.conf`.

4. Re-run `install.sh` once more. The first run can't patch `tmux-pop`'s `pop.sh` until TPM has installed it — this second pass copies our tweaked version over the upstream one:

   ```sh
   ~/workspace/tmux-conf/install.sh
   ```

## Custom scripts

- `scripts/tmux-pop/pop.sh` — installed over `~/.tmux/plugins/tmux-pop/scripts/pop.sh`. A local tweak to the pane-flash duration/style; upstream TPM updates would otherwise clobber it, so `install.sh` re-patches it back in.
- `scripts/tmux-agent-indicator/copilot-hooks.json` — installed to `~/.copilot/hooks/tmux-agent-indicator.json`. [tmux-agent-indicator](https://github.com/accessd/tmux-agent-indicator) has native hooks for Claude Code, Codex, and OpenCode but not Copilot CLI, so this wires `agent-state.sh` into Copilot's own hook events (`userPromptSubmitted`, `permissionRequest`, `agentStop`) the same way the plugin does for the others. `install.sh` also runs the plugin's own installer (via `curl | bash`) to wire up Claude Code/Codex/OpenCode, since merging into those shared config files is already handled safely upstream.
- `scripts/tmux-agent-indicator/pi-extension.ts` — installed to `~/.pi/agent/extensions/tmux-agent-indicator.ts` (pi's global auto-discovered extension location). tmux-agent-indicator has no native pi ([earendil-works/pi](https://github.com/earendil-works/pi)) integration either, so this hooks pi's `before_agent_start` and `agent_settled` extension events into `agent-state.sh`. pi has no permission-prompt event (no permission popups by default), so only `running`/`done` are wired — no `needs-input`.

## Updating

- Edit `.tmux.conf` in this repo, then `tmux source-file ~/.tmux.conf` (or restart tmux) to apply changes.
- Edit `wezterm.lua` in this repo — WezTerm watches its config file and reloads automatically.
- Edit scripts under `scripts/`, then re-run `install.sh` to re-copy them into `~/.tmux/`.
- Edit files under `kanagawa-tmux/` directly — `~/.tmux/plugins/kanagawa-tmux` is a symlink to it, so changes apply immediately without re-running `install.sh`.
- Commit and push changes as usual.
- To update plugins, press `prefix + U` inside tmux. Since this overwrites `tmux-pop/scripts/pop.sh` with upstream's version, re-run `install.sh` afterward to reapply the local patch. `kanagawa-tmux` is untouched by `prefix + U` since it isn't a TPM-managed plugin.
