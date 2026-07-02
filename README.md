# tmux-conf

My tmux configuration, tracked in git. Plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) and are not part of this repo — they get cloned into `~/.tmux/plugins/` on demand.

## Setup on a new machine

1. Clone this repo:

   ```sh
   git clone <this-repo-url> ~/workspace/tmux-conf
   ```

2. Symlink the config into place:

   ```sh
   ln -sf ~/workspace/tmux-conf/.tmux.conf ~/.tmux.conf
   ```

3. Install TPM (tmux plugin manager):

   ```sh
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

4. Start tmux and install the plugins:

   ```sh
   tmux
   ```

   Then press `prefix + I` (capital i) inside tmux to fetch and install all plugins listed in `.tmux.conf`.

## Updating

- Edit `.tmux.conf` in this repo, then `tmux source-file ~/.tmux.conf` (or restart tmux) to apply changes.
- Commit and push changes as usual.
- To update plugins, press `prefix + U` inside tmux.
