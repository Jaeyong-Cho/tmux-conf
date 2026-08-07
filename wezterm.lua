-- token-light theme + JetBrainsMono Nerd Font for WezTerm
-- Palette translated from https://github.com/ThorstenRhau/token
-- (contrib/kitty/token-light.conf) since wezterm has no native token theme.

local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_schemes = {
	["token-light"] = {
		foreground = "#2a2920",
		background = "#faf9f5",
		cursor_bg = "#2a2920",
		cursor_fg = "#faf9f5",
		cursor_border = "#2a2920",
		selection_fg = "#2a2920",
		selection_bg = "#dddcd6",
		ansi = {
			"#2a2920",
			"#b05555",
			"#3f643c",
			"#6e5c20",
			"#527594",
			"#7c619a",
			"#2d6c6c",
			"#b5b2ab",
		},
		brights = {
			"#6c675f",
			"#9a4929",
			"#3a5e37",
			"#876032",
			"#486a88",
			"#6f578c",
			"#286363",
			"#faf9f5",
		},
	},
}
config.color_scheme = "token-light"

config.use_fancy_tab_bar = false
config.colors = {
	tab_bar = {
		background = "#f0efeb",
		active_tab = {
			bg_color = "#faf9f5",
			fg_color = "#527594",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#f0efeb",
			fg_color = "#6c675f",
		},
		inactive_tab_hover = {
			bg_color = "#dddcd6",
			fg_color = "#2a2920",
		},
		new_tab = {
			bg_color = "#f0efeb",
			fg_color = "#6c675f",
		},
		new_tab_hover = {
			bg_color = "#dddcd6",
			fg_color = "#2a2920",
		},
	},
}

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 16.0

return config
