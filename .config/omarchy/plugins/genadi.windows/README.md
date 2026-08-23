# genadi.windows

A window switcher for the Omarchy bar. One icon; the list of open windows
lives in the popup, so the bar itself stays the same width no matter how many
windows are open.

## Interactions

| Where | Input | Effect |
|---|---|---|
| Bar icon | left click | open/close the list |
| Bar icon | right click | jump to the previously focused window (alt-tab) |
| Bar icon | hover | tooltip with the open-window count |
| Row | left click | focus that window, switching workspace if needed |
| Row | middle click | close that window |
| Row | hover the ✕ | close that window |
| Popup | `j` / `k` / ↑ / ↓ | move the cursor (wraps at both ends) |
| Popup | `Enter` / `Space` | focus the window under the cursor |
| Popup | `x` | close the window under the cursor |
| Popup | `1`–`9` | focus the nth window directly |
| Popup | `Esc` | dismiss |
| Popup | `Tab` | move to the neighbouring bar panel |

The focused window is drawn with the "selected" fill, so it is distinct from
wherever the keyboard/mouse cursor happens to be. A window Hyprland marks
urgent tints red, both in the row and on the bar icon.

## Settings

Set these inline on the widget's `bar.layout` entry in
`~/.config/omarchy/shell.json`, or through Setup > Plugins.

| Key | Type | Default | Meaning |
|---|---|---|---|
| `sortBy` | `workspace` \| `recent` | `workspace` | Group rows under workspace headers, or list them most-recently-focused first (workspace then shows as a badge on the row). |
| `showTitles` | boolean | `true` | Print the window title under the application name. Titles equal to the app name are skipped either way. |
| `icon` | string | `` | Nerd Font glyph drawn in the bar. |

```json
{ "id": "genadi.windows", "sortBy": "recent", "showTitles": false }
```

## Keybinding

The widget has no IPC target of its own — a bar widget is instantiated once
per monitor, and an IPC target only ever routes to one of those instances.
Summon it through the shell instead, which resolves to the bar on the focused
monitor:

```lua
o.bind("SUPER + W", "Window switcher", "omarchy-shell shell toggle genadi.windows")
```

## Implementation notes

- Windows come from `Hyprland.toplevels`, which carries the workspace, the
  urgent flag, and the Hyprland IPC payload (for the window class). Focus and
  close go through the wayland handle's `activate()` / `close()` — the
  foreign-toplevel requests — because Hyprland 0.56 dropped the classic
  `hyprctl dispatch` syntax in favour of Lua.
- Resolving a window class to an application is a cascade, because no single
  lookup covers everything installed here:
  1. Omarchy's web apps ship no `StartupWMClass`, so Chromium's
     `chrome-<host>__-<profile>` class is matched by finding the desktop entry
     whose `Exec` contains that host (Google Chat, WhatsApp, …).
  2. `DesktopEntries.heuristicLookup`, tried against the raw class, the class
     with Hyprland's instance suffix stripped
     (`com.transmissionbt.transmission_30_885319` → `…transmission`), and its
     last reverse-DNS segment.
  3. A web app whose entry launches through a handler script rather than a
     literal URL (`omarchy-webapp-handler-hey`) is matched on an exact
     case-insensitive `Name` match against its host label — `hey.com` → `HEY`.
  4. A desktop id that suffixes the class — `transmission` →
     `transmission-gtk`. Prefix match, so it cannot pull in an unrelated app.

  Anything still unmatched falls back to a tidied class name and the generic
  executable icon. Icons themselves resolve through the shell's app library
  when it is reachable (`bar.shell.appLibrary`), which keeps newly installed
  apps' icons live.
- Glyphs are written as `\uXXXX` escapes, not literal characters. Private-use
  codepoints do not survive every editing path, and a `text` of `""` makes the
  bar button `visible: false` — an invisible widget rather than a visible
  error.
- Rows are anchor-laid-out rather than using QtQuick.Layouts: a `RowLayout`
  inside the row surface feeds its content height back into the surface that
  sizes it, which Qt reports as a `polish()` loop.
- `rows` is rebuilt on window open/close and on focus changes. A window
  changing workspace while the popup is up will not re-sort until it
  reopens — the popup holds keyboard focus, so nothing can move a window
  out from under it.

## Hacking on it

`~/.config/omarchy/plugins/genadi.windows/` is what the shell actually loads,
so that is the copy to iterate on. It is versioned in
[gazarchy](https://github.com/gsamokovarov/gazarchy) at
`.config/omarchy/plugins/genadi.windows/`, alongside the `shell.json` entry
that puts it in the bar — copy changes back there when they settle, since
`make gazarchy` reinstalls over the live copy and would drop anything not
committed.

`shell.json` changes hot-reload, but **plugin QML does not** — the shell logs
`Local plugin changed, reloading` and re-reads the manifest without
recompiling the QML. After editing `Panel.qml` or `Model.js`:

```bash
omarchy restart shell
```

`Model.js` is plain functions with no QML dependencies, so it can be checked
without the shell at all:

```bash
node -e 'eval(require("fs").readFileSync("Model.js","utf8")); console.log(prettyAppId("chrome-web.whatsapp.com__-Default"))'
```
