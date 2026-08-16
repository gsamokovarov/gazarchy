-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Optimized for my Lenovo Thinkpad next to the LG 5K.
hl.env("GDK_SCALE", "2")
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x544", scale = "auto" })
hl.monitor({ output = "DP-1", mode = "preferred", position = "1280x0", scale = "auto" })
