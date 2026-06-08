hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "-1920x0", scale = 1, vrr = 0 })
hl.monitor({ output = "DP-3", mode = "2560x1440@165.0", position = "0x0", scale = 1, vrr = 2 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2560x0", scale = 1, vrr = 0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1280x1024@60.0", position = "2560x0", scale = 1, vrr = 0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1024x768@75.0", position = "2560x0", scale = 1, vrr = 0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "800x600@85.0", position = "2560x0", scale = 1, vrr = 0 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-3", default = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", default = true })

hl.config({
  cursor = {
    no_break_fs_vrr = 1,
    min_refresh_rate = 48,
  },
})
