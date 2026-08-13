#!/usr/bin/env bash
# Toggle power-zoom + centered padding (like no-neck-pane.nvim) for the
# current pane: power-zoom breaks it into its own window, then this script
# adds blank filler panes on both sides so the content sits in a
# fixed-width column instead of stretching edge-to-edge. Pressing the same
# key again strips the padding and lets power-zoom restore the pane.
set -euo pipefail

TMUX_BIN=${TMUX_BIN:-tmux}
POWER_ZOOM_SH="$HOME/.tmux/plugins/tmux-power-zoom/scripts/power_zoom.sh"
PAD_TITLE="__centered_zoom_pad__"
# ponytail: idle filler process, not a real "empty pane" primitive in tmux
FILLER='while :; do sleep 86400; done'

current_title="$($TMUX_BIN display -p '#T')"
[[ "$current_title" == "$PAD_TITLE" ]] && exit 0 # ignore triggers from a pad pane

pad_panes="$($TMUX_BIN list-panes -F '#{pane_id} #{pane_title}' | awk -v t="$PAD_TITLE" '$2==t{print $1}')"

if [[ -n "$pad_panes" ]]; then
    # already centered: drop the padding, then let power-zoom restore the pane
    while read -r p; do $TMUX_BIN kill-pane -t "$p"; done <<<"$pad_panes"
    "$POWER_ZOOM_SH" || true
    exit 0
fi

"$POWER_ZOOM_SH" || true # no-op (with a message) if there was only one pane to zoom

max_width="$($TMUX_BIN show-option -gqv @centered_zoom_width)"
max_width="${max_width:-130}"
win_width="$($TMUX_BIN display -p '#{window_width}')"
pad_total=$((win_width - max_width - 2)) # -2 for the two new pane borders
((pad_total <= 1)) && exit 0             # window too narrow to bother centering

main_id="$($TMUX_BIN display -p '#D')"
left=$((pad_total / 2))
right=$((pad_total - left))

$TMUX_BIN split-window -hb -l "$left" -t "$main_id" "$FILLER"
$TMUX_BIN select-pane -T "$PAD_TITLE"
$TMUX_BIN split-window -h -l "$right" -t "$main_id" "$FILLER"
$TMUX_BIN select-pane -T "$PAD_TITLE"
$TMUX_BIN select-pane -t "$main_id"
