#!/usr/bin/env bash
color="$1"
for _ in {1..2}; do
  tmux set -w window-active-style "bg=$color"
  sleep .05
  tmux set -w window-active-style ""
  sleep .05
done
