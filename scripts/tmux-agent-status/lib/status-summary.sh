#!/usr/bin/env bash

[[ -n "${_STATUS_SUMMARY_LOADED:-}" ]] && return 0
_STATUS_SUMMARY_LOADED=1

# Local patch: recolored for the token-light theme (see
# ~/.tmux/themes/token-light/token-light.conf) instead of upstream's
# named ANSI colors, which don't track a light-terminal palette.
WORKING_FG="#9a4929"  # token-light accent orange
WAITING_FG="#527594"  # token-light blue
DONE_FG="#5b7d4f"     # muted sage green

format_working_segment() {
    local count="$1"
    if [ "$count" -eq 1 ]; then
        echo "#[fg=$WORKING_FG,bold]⚡ agent working#[default]"
    else
        echo "#[fg=$WORKING_FG,bold]⚡ $count working#[default]"
    fi
}

format_waiting_segment() {
    local count="$1"
    if [ "$count" -eq 1 ]; then
        echo "#[fg=$WAITING_FG,bold]⏸ 1 waiting#[default]"
    else
        echo "#[fg=$WAITING_FG,bold]⏸ $count waiting#[default]"
    fi
}

format_done_segment() {
    local count="$1"
    echo "#[fg=$DONE_FG]✓ $count done#[default]"
}

render_status_summary() {
    local working="$1"
    local waiting="$2"
    local done="$3"
    local total_agents="$4"
    local segments=()

    if [ "$total_agents" -eq 0 ]; then
        echo ""
    elif [ "$working" -eq 0 ] && [ "$waiting" -eq 0 ] && [ "$done" -gt 0 ]; then
        echo "#[fg=$DONE_FG,bold]✓ All agents ready#[default]"
    else
        [ "$working" -gt 0 ] && segments+=("$(format_working_segment "$working")")
        [ "$waiting" -gt 0 ] && segments+=("$(format_waiting_segment "$waiting")")
        [ "$done" -gt 0 ] && segments+=("$(format_done_segment "$done")")
        printf '%s\n' "${segments[*]}"
    fi
}

write_status_summary_cache() {
    local working="$1"
    local waiting="$2"
    local done="$3"
    local total_agents="$4"
    local summary

    summary="$(render_status_summary "$working" "$waiting" "$done" "$total_agents")"
    printf '%s\n' "$working:$waiting:$done:$total_agents" > "${STATUS_LINE_COUNTS_FILE}.tmp"
    mv -f "${STATUS_LINE_COUNTS_FILE}.tmp" "$STATUS_LINE_COUNTS_FILE"
    printf '%s\n' "$summary" > "${STATUS_LINE_CACHE_FILE}.tmp"
    mv -f "${STATUS_LINE_CACHE_FILE}.tmp" "$STATUS_LINE_CACHE_FILE"
}
