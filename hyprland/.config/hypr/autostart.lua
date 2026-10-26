hl.on("hyprland.start", function()
  hl.exec_cmd("v4l2-ctl --set-parm=30 --set-fmt-video=width=1920,height=1080,pixelformat=MJPG --device /dev/video0")
  -- hl.exec_cmd("gentoo-pipewire-launcher")  -- Gentoo-only; enable if needed
end)
