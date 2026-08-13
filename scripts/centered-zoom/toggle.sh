#!/usr/bin/env bash
# Toggle power-zoom + centered padding (like no-neck-pane.nvim) for the
# current pane: power-zoom breaks it into its own window, then this script
# adds filler panes on both sides so the content sits in a fixed-width
# column instead of stretching edge-to-edge: left pane gets tmux's own
# clock-mode (prefix+t), right pane gets a calendar by default. Pressing
# the same key again strips the padding and lets power-zoom restore the pane.
set -euo pipefail

TMUX_BIN=${TMUX_BIN:-tmux}
POWER_ZOOM_SH="$HOME/.tmux/plugins/tmux-power-zoom/scripts/power_zoom.sh"
# ponytail: fixed filler, not a real "empty pane" primitive in tmux.
# Override with `set -g @centered_zoom_right_cmd '...'` for something else
# (git log, weather, cpu/mem, ...). Must stay alive on its own (chain an
# idle loop) or tmux closes the pane as soon as the command exits.
RIGHT_DEFAULT='cal; while :; do sleep 86400; done'

# Pad panes are tagged with a pane-scoped option (not pane_title - a pane's
# shell can re-emit its own title on startup/resize, racing our tag).
is_pad="$($TMUX_BIN show-option -pqv @centered_zoom_pad)"
[[ "$is_pad" == "1" ]] && exit 0 # ignore triggers from a pad pane

pad_panes="$($TMUX_BIN list-panes -F '#{pane_id} #{@centered_zoom_pad}' | awk '$2==1{print $1}')"

if [[ -n "$pad_panes" ]]; then
    # already centered: drop the padding, then let power-zoom restore the pane
    while read -r p; do $TMUX_BIN kill-pane -t "$p"; done <<<"$pad_panes"
    "$POWER_ZOOM_SH" || true
    exit 0
fi

"$POWER_ZOOM_SH" || true # no-op (with a message) if there was only one pane to zoom

right_cmd="$($TMUX_BIN show-option -gqv @centered_zoom_right_cmd)"
right_cmd="${right_cmd:-$RIGHT_DEFAULT}"

max_width="$($TMUX_BIN show-option -gqv @centered_zoom_width)"
max_width="${max_width:-130}"
win_width="$($TMUX_BIN display -p '#{window_width}')"
pad_total=$((win_width - max_width - 2)) # -2 for the two new pane borders
((pad_total <= 1)) && exit 0             # window too narrow to bother centering

main_id="$($TMUX_BIN display -p '#D')"
left=$((pad_total / 2))
right=$((pad_total - left))

$TMUX_BIN split-window -hb -l "$left" -t "$main_id"
left_id="$($TMUX_BIN display -p '#D')"
$TMUX_BIN clock-mode

$TMUX_BIN split-window -h -l "$right" -t "$main_id" "$right_cmd"
right_id="$($TMUX_BIN display -p '#D')"

$TMUX_BIN set-option -p -t "$left_id" @centered_zoom_pad 1
$TMUX_BIN set-option -p -t "$right_id" @centered_zoom_pad 1
$TMUX_BIN select-pane -t "$main_id"
