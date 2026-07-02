#!/usr/bin/env bash

# Keep the tmux-agent-status sidebar visible in a window whenever a new
# pane is split into it. Runs from the after-split-window hook.
#
# Skip when the pane that was just split *is* the sidebar itself (created
# by sidebar-toggle.sh below) — otherwise this hook would retrigger on its
# own split-window call.
cmd=$(tmux display-message -p '#{pane_start_command}')
case "$cmd" in
    */tmux-agent-status/scripts/sidebar.sh) exit 0 ;;
esac

# sidebar-toggle.sh focuses whatever sidebar pane it finds/creates, so
# remember the pane the user just split to and restore focus to it after.
active_pane=$(tmux display-message -p '#{pane_id}')
"$HOME/.tmux/plugins/tmux-agent-status/scripts/sidebar-toggle.sh"
tmux select-pane -t "$active_pane" 2>/dev/null || true
