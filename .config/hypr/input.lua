-- Personal input settings.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    -- US and Bulgarian phonetic layouts, toggled with SUPER+SPACE.
    kb_layout = "us,bg(phonetic)",
    kb_options = "ctrl:nocaps,grp:win_space_toggle,altwin:swap_lalt_lwin",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 300,

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      clickfinger_behavior = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.2,
    },
  },
})

-- Don't switch Super on my US Apple keyboard.
hl.device({
  name = "apple-inc.-magic-keyboard",
  kb_options = "ctrl:nocaps,grp:win_space_toggle",
})

-- Switch Super and Alt on my Lenovo laptop keyboard.
hl.device({
  name = "at-translated-set-2-keyboard",
  kb_options = "ctrl:nocaps,grp:win_space_toggle,altwin:swap_lalt_lwin",
})

-- Workspace navigation with a 4-finger trackpad swipe.
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
