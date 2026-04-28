local wezterm = require 'wezterm';

local scheme = wezterm.color.get_builtin_schemes()["Gruvbox Dark"];
scheme = {
	foreground = "#EBDBB2",
	background = "#1D2021",
	cursor_bg = "#EBDBB2",
	cursor_fg = "#1D2021",
	cursor_border = "#EBDBB2",
	selection_fg = "#0a0e14",
	selection_bg = "#cbccc6",
	scrollbar_thumb = "#928374",
	split = "#928374",
	ansi = {
		"#1D2021",
		"#CC241D",
		"#98971A",
		"#D79921",
		"#458588",
		"#B16286",
		"#689D6A",
		"#A89984",
	},
	brights = {
		"#928374",
		"#FB4934",
		"#B8BB26",
		"#FADB2F",
		"#83A598",
		"#D3869B",
		"#8EC07C",
		"#EBDBB2",
	},
};

wezterm.on('mux-is-process-stateful', function() return false end);

return {
	color_schemes = {
		["Gruvbox Dark"] = scheme,
	},
	color_scheme = "Gruvbox Dark",
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
