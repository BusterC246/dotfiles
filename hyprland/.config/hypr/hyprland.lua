hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("ELECTRON_PLATFORM_HINT", "wayland")
hl.env("ELM_DISPLAY", "wl")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("KITTY_ENABLE_WAYLAND", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("MOZ_WAYLAND_USE_VAAPI", "1")
hl.env("PROTON_NO_WM_DECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("WINE_NO_WM_DECORATION", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --all")
  hl.exec_cmd("mako")
  hl.exec_cmd("wl-clip-persist --clipboard both")
  hl.exec_cmd("/usr/libexec/hyprpolkitagent")
  hl.exec_cmd("gentoo-pipewire-launcher")
  hl.exec_cmd("hypridle")
  hl.exec_cmd('"${XDG_CONFIG_HOME}"/hypr/scripts/wallpaper.sh')
  hl.exec_cmd('"${XDG_CONFIG_HOME}"/hypr/scripts/xdg-portal.sh')
  hl.exec_cmd("xrandr --output DP-3 --primary")
end)

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    col = {
      active_border = "rgb(FE8019)",
      inactive_border = "rgb(1D2021)",
    },
    layout = "master",
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,

    allow_session_lock_restore = true,

    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,

    enable_swallow = false,
    swallow_regex = "^([aA]lacritty|[kK]itty|foot|footclient|[gG]hostty)$",

    middle_click_paste = false,
  },

  xwayland = {
    use_nearest_neighbor = false,
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },

  debug = {
    disable_logs = false,
  },

  master = {
    mfact = 0.5,
    smart_resizing = false,
    allow_small_split = true,
  },

  decoration = {
    blur = {
      enabled = false,
    },
    shadow = {
      enabled = false,
    },
  },

  animations = {
    enabled = false,
  },

  input = {
    kb_layout = "us,us",
    kb_variant = "dvorak,basic",
    -- kb_model =
    kb_options = "grp:alts_toggle,caps:escape",
    -- kb_rules =
    numlock_by_default = true,

    touchpad = {
      natural_scroll = true,
    },

    sensitivity = 0.0, -- -1.0 - 1.0, 0 means no modification.
    accel_profile = "flat",
    force_no_accel = false,
  },
})

-- Make app runner always focused
hl.window_rule({ match = { class = "^(tofi)" }, stay_focused = true })

-- Fix Steam menus
hl.window_rule({ match = { class = "^(steam)", float = true }, stay_focused = true })
hl.window_rule({ match = { class = "^(steam)" }, min_size = { 1, 1 } })

-- Disable idle on fullscreen
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "focus" })

-- Screensharing
hl.window_rule({
  name = "xwayland-video-bridge-fixes",
  match = { class = "xwaylandvideobridge" },
  no_initial_focus = true,
  no_focus = true,
  no_anim = true,
  no_blur = true,
  max_size = { 1, 1 },
  opacity = "0.0",
})

-- Fix Ghidra
hl.window_rule({ match = { class = "^(ghidra)" }, stay_focused = true })
hl.window_rule({ match = { class = "^(ghidra)" }, min_size = { 1, 1 } })

-- Fix IntelliJ
hl.window_rule({ match = { class = "^(jetbrains)" }, float = true, center = true })
hl.window_rule({ match = { class = "^(jetbrains)" }, float = true, no_focus = true })
hl.window_rule({ match = { class = "^(jetbrains)" }, float = true, border_size = 0 })
hl.window_rule({ match = { class = "^(jetbrains)", title = "^(win)" }, float = true, no_focus = true })

local mainMod = "SUPER"
local term = "kitty"
local menu = "eval $(tofi-drun --font /usr/share/fonts/jetbrains-mono/JetBrainsMono-Regular.ttf --ascii-input true)"
local browser = "librewolf"

hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + semicolon", hl.dsp.exit())
-- bind = $mainMod, P, fakefullscreen
-- bind = $mainMod, P, pseudo, # dwindle
-- bind = $mainMod, J, togglesplit, # dwindle

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + T", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + H", hl.dsp.window.cycle_next({ next = false }))

hl.bind(mainMod .. " + C", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + G", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + return", hl.dsp.layout("swapwithmaster auto"))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("ddcutil setvcp 10 + 15 || brightnessctl set 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil setvcp 10 - 15 || brightnessctl set 5%-"),
  { locked = true, repeating = true })

hl.bind("xF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 33%+"),
  { locked = true, repeating = true })
hl.bind("xF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 33%-"),
  { locked = true, repeating = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86audiostop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)"'))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp -d)"'))


require("env")
require("autostart")
require("input")
require("window_rules")
require("monitors")
