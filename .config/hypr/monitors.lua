-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Omarchy's monitor tooling (SUPER+/ scaling, clamshell reconciler) reads and
-- rewrites these locals, so the laptop panel scale must live here, not inline.
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Optimized for my Lenovo Thinkpad next to the LG 5K.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x342", scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-1", mode = "preferred", position = "1200x0", scale = "auto" })
