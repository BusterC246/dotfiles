-- Monitor configuration — hardware-specific, replace with your own outputs
-- Example:
-- hl.monitor({ output = "DP-1", mode = "2560x1440@165.0", position = "0x0", scale = 1 })

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.config({
    cursor = {
        no_break_fs_vrr = 1,
        min_refresh_rate = 48,
    },
})
