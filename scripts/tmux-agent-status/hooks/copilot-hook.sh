#!/usr/bin/env bash

# Copilot CLI hook for tmux-agent-status.
# Modeled on hooks/codex-hook.sh from the plugin, since tmux-agent-status
# ships no native Copilot integration. Event name is passed as $1 by the
# hook commands registered in ~/.copilot/hooks/tmux-agent-status.json.
# The JSON payload on stdin is drained and ignored — only the event name
# is needed to update session/pane state.

STATUS_DIR="$HOME/.cache/tmux-agent-status"
WAIT_DIR="$STATUS_DIR/wait"
PARKED_DIR="$STATUS_DIR/parked"
PANE_DIR="$STATUS_DIR/panes"
REFRESH_FILE="$STATUS_DIR/.sidebar-refresh"
mkdir -p "$STATUS_DIR" "$WAIT_DIR" "$PARKED_DIR" "$PANE_DIR"
[ -f "$REFRESH_FILE" ] || : > "$REFRESH_FILE"

cat >/dev/null 2>&1 || true

get_tmux_session() {
    local tmux_session=""
    if [ -n "${TMUX:-}" ]; then
        tmux_session=$(tmux display-message -p '#{session_name}' 2>/dev/null)
    fi
    [ -n "$tmux_session" ] || return 1
    printf '%s\n' "$tmux_session"
}

set_status() {
    local tmux_session="$1"
    local requested_status="$2"
    local session_status="$requested_status"
    local status_file="$STATUS_DIR/${tmux_session}.status"

    if [ -n "${TMUX_PANE:-}" ]; then
        local pane_file="$PANE_DIR/${tmux_session}_${TMUX_PANE}.status"
        local agent_file="$PANE_DIR/${tmux_session}_${TMUX_PANE}.agent"
        echo "$requested_status" > "$pane_file"
        echo "copilot" > "$agent_file"

        session_status="done"
        local existing_pane_file=""
        for existing_pane_file in "$PANE_DIR/${tmux_session}_"*.status; do
            [ -f "$existing_pane_file" ] || continue
            case "$(cat "$existing_pane_file" 2>/dev/null || echo "")" in
                working)
                    session_status="working"
                    break
                    ;;
                wait)
                    [ "$session_status" != "working" ] && session_status="wait"
                    ;;
            esac
        done
    fi

    echo "$session_status" > "$status_file"
}

clear_interaction_overrides() {
    local tmux_session="$1"
    rm -f "$WAIT_DIR/${tmux_session}.wait" "$PARKED_DIR/${tmux_session}.parked" 2>/dev/null
    if [ -n "${TMUX_PANE:-}" ]; then
        rm -f "$WAIT_DIR/${tmux_session}_${TMUX_PANE}.wait" "$PARKED_DIR/${tmux_session}_${TMUX_PANE}.parked"
    fi
}

mark_refresh() {
    touch "$REFRESH_FILE" 2>/dev/null || true
}

TMUX_SESSION=$(get_tmux_session) || exit 0
HOOK_TYPE="${1:-}"
WAIT_FILE="$WAIT_DIR/${TMUX_SESSION}.wait"
PARKED_FILE="$PARKED_DIR/${TMUX_SESSION}.parked"

case "$HOOK_TYPE" in
    sessionStart)
        if [ ! -f "$WAIT_FILE" ] && [ ! -f "$PARKED_FILE" ]; then
            set_status "$TMUX_SESSION" "done"
            mark_refresh
        fi
        ;;
    userPromptSubmitted)
        clear_interaction_overrides "$TMUX_SESSION"
        set_status "$TMUX_SESSION" "working"
        mark_refresh
        ;;
    preToolUse)
        rm -f "$WAIT_FILE"
        if [ ! -f "$PARKED_FILE" ]; then
            set_status "$TMUX_SESSION" "working"
        fi
        mark_refresh
        ;;
    agentStop)
        set_status "$TMUX_SESSION" "done"
        mark_refresh
        ;;
esac

exit 0
