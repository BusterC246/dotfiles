local wezterm = require 'wezterm';

-- local scheme = wezterm.get_builtin_color_schemes()["Gruvbox Dark"];
-- scheme.background = "1d2021";

wezterm.on('mux-is-process-stateful', function() return false end);

return {
	-- color_schemes = {
		-- ["Gruvbox Darker"] = scheme,
	-- },
	enable_tab_bar = false,
	default_cursor_style = "SteadyBar",
	term = "xterm-color",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	freetype_load_target = "Normal",
	check_for_updates = false,
	animation_fps = 165,
	front_end = "OpenGL",
	prefer_egl = true,
	enable_wayland = true,
};
