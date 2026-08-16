-- Personal keybindings. See current bindings: omarchy menu keybindings --print

-- SUPER+SPACE toggles keyboard layouts (grp:win_space_toggle in hypr/input.lua),
-- so the Omarchy menu can't live there. It's on SUPER+` instead.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + grave", "Omarchy menu", "omarchy-menu toggle")

-- Launch apps with plain ALT+SPACE.
o.bind("ALT + SPACE", "Launch apps", "omarchy-menu toggle apps")

-- Cycle through windows with SUPER-[ and SUPER-].
o.bind("SUPER + bracketright", "Cycle to next window", hl.dsp.window.cycle_next())
o.bind("SUPER + bracketleft", "Cycle to prev window", hl.dsp.window.cycle_next({ next = false }))

-- Toggle monocle fullscreen (like split zoom) with SUPER-\.
o.bind("SUPER + backslash", "Maximize window", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Vim-like navigation for grouped windows.
hl.unbind("SUPER + CTRL + K") -- was: Herdr keybindings
o.bind("SUPER + CTRL + J", "Move grouped window focus left", hl.dsp.group.prev())
o.bind("SUPER + CTRL + K", "Move grouped window focus right", hl.dsp.group.next())

-- Control LG display brightness.
o.bind("CTRL + F1", "LG 5K brightness down", "gazarchy-cmd-lg-brightness -5")
o.bind("CTRL + F2", "LG 5K brightness up", "gazarchy-cmd-lg-brightness +5")
o.bind("SHIFT + CTRL + F2", "LG 5K full brightness", "gazarchy-cmd-lg-brightness +100")

-- Browser on SUPER+B (defaults only bind SUPER+SHIFT+B).
o.bind("SUPER + B", "Browser", { omarchy = "browser" })

-- Lock the computer with SUPER+CTRL+Q (also on the default SUPER+CTRL+L).
hl.unbind("SUPER + CTRL + Q") -- was: Calculator (still on XF86Calculator)
o.bind("SUPER + CTRL + Q", "Lock the computer", "omarchy-system-lock")

-- Per-monitor scaling. Omarchy's script persists every change into one shared
-- local, dragging the laptop panel's scale along whenever the external monitor
-- is scaled; gazarchy-cmd-monitor-scale persists per rule and shifts neighbors.
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")
o.bind("SUPER + SLASH", "Monitor scaling up", "gazarchy-cmd-monitor-scale up")
o.bind("SUPER + ALT + SLASH", "Monitor scaling down", "gazarchy-cmd-monitor-scale down")
