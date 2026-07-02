#!/usr/bin/env bash
tmux set -w window-active-style "bg=$1"
sleep .02 && tmux set -w window-active-style ""
