-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

hl.env("GDK_SCALE", "1")

-- Optimized for my Lenovo Thinkpad next to the LG 5K.
-- SUPER+/ and the Display panel persist per-monitor scales and positions here
-- through gazarchy-cmd-monitor-scale and gazarchy-cmd-monitor-arrange.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x342", scale = 1.25 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "1536x0", scale = 1.25 })
