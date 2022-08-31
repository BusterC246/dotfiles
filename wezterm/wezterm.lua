term = "wezterm";

local wezterm = require 'wezterm';

local scheme = wezterm.get_builtin_color_schemes()["Gruvbox Dark"];
scheme.background = "1d2021";

wezterm.on('mux-is-process-stateful', function() return false end);

return {
	color_schemes = {
		["Gruvbox Darker"] = scheme,
	},
	color_scheme = "Gruvbox Darker",
	enable_tab_bar = false,
	default_cursor_style = "SteadyBar",
	animation_fps = 60,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	check_for_updates = false,
};
