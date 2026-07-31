#!/usr/bin/env python3
"""Idempotently merge tmux-agent-status's Claude Code hooks into settings.json."""
import json
import sys
from pathlib import Path

EVENTS = ["UserPromptSubmit", "PreToolUse", "Stop", "Notification"]


def main() -> None:
    settings_path = Path(sys.argv[1]).expanduser()
    hook_script = sys.argv[2]

    settings = json.loads(settings_path.read_text()) if settings_path.exists() else {}
    hooks = settings.setdefault("hooks", {})

    changed = False
    for event in EVENTS:
        command = f"{hook_script} {event}"
        entries = hooks.setdefault(event, [])
        already_present = any(
            h.get("command") == command
            for entry in entries
            for h in entry.get("hooks", [])
        )
        if not already_present:
            entries.append({"hooks": [{"type": "command", "command": command}]})
            changed = True

    if changed:
        settings_path.parent.mkdir(parents=True, exist_ok=True)
        settings_path.write_text(json.dumps(settings, indent=2) + "\n")
        print(f"Updated {settings_path} with tmux-agent-status Claude Code hooks")
    else:
        print(f"{settings_path} already has tmux-agent-status Claude Code hooks")


if __name__ == "__main__":
    main()
