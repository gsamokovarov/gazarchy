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
- `rows` is a binding over `Hyprland.toplevels`. QML captures property
  reads through the call into `Model.js`, so it already tracks every
  window's workspace, class, and address without naming them — a window
  moved to another workspace re-sorts on its own.
- That capture is also why the MRU is read **only** in `recent` order:
  `root.order === "recent" ? root.mru : []`. The MRU changes on every
  focus change, and in `workspace` order it cannot affect the sort, so
  reading it unconditionally rebuilt every row on every alt-tab — on
  every monitor's bar, popup open or not, each row re-running the
  desktop-entry cascade over the whole `DesktopEntries` list. A
  conditional read registers no dependency while the branch is not
  taken, and reconnects when `sortBy` flips. The focused row does not
  need this rebuild either: `isActive` binds `toplevel.activated`
  directly.
- `workspaceSortKey` sorts in tiers — numbered workspaces by id, then
  specials at `SPECIAL_SORT_BASE - id` (their ids are negative), then
  unknown, then unassigned. The tier bases are deliberately small: an
  earlier version offset from `Number.MAX_SAFE_INTEGER`, which pushed
  specials past 2^53 where doubles step by 2, so workspaces -98 and -99
  produced the same key and could not be ordered.

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

`Model.js` is plain functions and constants with no QML dependencies, so it
can be checked without the shell at all:

```bash
node -e 'eval(require("fs").readFileSync("Model.js","utf8")); console.log(prettyAppId("chrome-web.whatsapp.com__-Default"))'
```
