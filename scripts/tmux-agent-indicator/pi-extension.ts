// tmux-agent-indicator extension for pi (github.com/earendil-works/pi).
// Installed to ~/.pi/agent/extensions/tmux-agent-indicator.ts (global auto-discovery).
// Tracks agent run state and calls agent-state.sh to update tmux pane visuals,
// the same way the plugin's native Claude/Codex/OpenCode hooks do.
//
// pi has no permission-prompt event (no permission popups by default — see
// docs/security.md), so this only distinguishes running vs done, unlike the
// three-state (running/needs-input/done) hooks for the other agents.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";

const DIR =
  process.env.TMUX_AGENT_INDICATOR_DIR ||
  `${process.env.HOME}/.tmux/plugins/tmux-agent-indicator`;
const SCRIPT = `${DIR}/scripts/agent-state.sh`;

export default function (pi: ExtensionAPI) {
  let lastState = "off";

  const setState = (state: "running" | "done") => {
    if (state === lastState) return;
    lastState = state;
    execFile("bash", [SCRIPT, "--agent", "pi", "--state", state], () => {});
  };

  pi.on("before_agent_start", async () => {
    setState("running");
  });

  pi.on("agent_settled", async () => {
    setState("done");
  });
}
