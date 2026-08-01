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

4. Re-run `install.sh` once more. The first run can't patch `tmux-pop`'s `pop.sh` until TPM has installed it — this second pass copies our tweaked version over the upstream one:

   ```sh
   ~/workspace/tmux-conf/install.sh
   ```

## Custom scripts

- `scripts/tmux-pop/pop.sh` — installed over `~/.tmux/plugins/tmux-pop/scripts/pop.sh`. A local tweak to the pane-flash duration/style; upstream TPM updates would otherwise clobber it, so `install.sh` re-patches it back in.

## Updating

- Edit `.tmux.conf` in this repo, then `tmux source-file ~/.tmux.conf` (or restart tmux) to apply changes.
- Edit scripts under `scripts/`, then re-run `install.sh` to re-copy them into `~/.tmux/`.
- Edit files under `kanagawa-tmux/` directly — `~/.tmux/plugins/kanagawa-tmux` is a symlink to it, so changes apply immediately without re-running `install.sh`.
- Commit and push changes as usual.
- To update plugins, press `prefix + U` inside tmux. Since this overwrites `tmux-pop/scripts/pop.sh` with upstream's version, re-run `install.sh` afterward to reapply the local patch. `kanagawa-tmux` is untouched by `prefix + U` since it isn't a TPM-managed plugin.
