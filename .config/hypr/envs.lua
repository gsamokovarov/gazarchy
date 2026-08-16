-- Extra env variables.
-- Note: You must relaunch Hyprland after changing envs (use Super+Esc, then Relaunch).

-- Append ~/bin to the PATH of spawned apps (gazarchy-cmd-* lives there).
-- Omarchy's defaults prepend their bin dir with hl.env, which this overrides,
-- so keep it in front when the compositor's own PATH doesn't have it.
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
local omarchy_bin = (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin"
if not (":" .. path .. ":"):find(":" .. omarchy_bin .. ":", 1, true) then
  path = omarchy_bin .. ":" .. path
end
hl.env("PATH", path .. ":" .. (os.getenv("HOME") or "") .. "/bin")
