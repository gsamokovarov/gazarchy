var SPECIAL_SORT_BASE = 1e9
var UNKNOWN_SORT_KEY = 2e9
var UNASSIGNED_SORT_KEY = 3e9

function appIdOf(toplevel) {
  if (!toplevel) return ""
  var ipc = toplevel.lastIpcObject || {}
  var cls = String(ipc.class || ipc.initialClass || "")
  if (cls.length > 0) return cls
  return toplevel.wayland ? String(toplevel.wayland.appId || "") : ""
}

function webAppHost(appId) {
  var m = String(appId || "").match(/^chrome-(?:app\.)?(.+?)__/)
  return m ? m[1] : ""
}

function hostLabel(host) {
  var parts = String(host || "").split(".")
  if (parts.length <= 2) return parts[0] || ""
  var first = parts[0]
  if (first === "web" || first === "app" || first === "www") return parts[1] || ""
  return first
}

function lookupCandidates(appId) {
  var value = String(appId || "").trim()
  if (value.length === 0) return []
  if (webAppHost(value) !== "") return []
  var out = [value]
  var stripped = value.replace(/[-_]\d[\d_]*$/, "")
  if (stripped !== value && stripped.length > 0) out.push(stripped)
  var tail = stripped.split(".").pop()
  if (tail !== stripped && tail.length > 0) out.push(tail)
  return out
}

function prettyAppId(appId) {
  var value = String(appId || "").trim()
  if (value.length === 0) return "Unknown"
  var host = webAppHost(value)
  if (host !== "") return host
  var tail = value.split(".").pop().replace(/[-_]\d[\d_]*$/, "")
  tail = tail.replace(/[-_]+/g, " ").trim()
  if (tail.length === 0) tail = value
  return tail.charAt(0).toUpperCase() + tail.slice(1)
}

function workspaceLabel(toplevel) {
  var ws = toplevel ? toplevel.workspace : null
  if (!ws) return "Unassigned"
  var name = String(ws.name || "").replace(/^special:/, "")
  if (name.length > 0 && !/^-?\d+$/.test(name)) return name
  return "Workspace " + (ws.id !== undefined ? ws.id : name)
}

function workspaceBadge(toplevel) {
  var ws = toplevel ? toplevel.workspace : null
  if (!ws) return ""
  var name = String(ws.name || "").replace(/^special:/, "")
  if (name.length > 0 && !/^-?\d+$/.test(name)) return name
  return ws.id !== undefined ? String(ws.id) : name
}

function workspaceSortKey(toplevel) {
  var ws = toplevel ? toplevel.workspace : null
  if (!ws) return UNASSIGNED_SORT_KEY
  var id = Number(ws.id)
  if (!isFinite(id)) return UNKNOWN_SORT_KEY
  return id > 0 ? id : SPECIAL_SORT_BASE - id
}

function rowsFor(toplevels, mru, order) {
  var rows = []
  for (var i = 0; i < toplevels.length; i++) {
    var t = toplevels[i]
    if (!t) continue
    rows.push({
      toplevel: t,
      address: String(t.address || ""),
      appId: appIdOf(t),
      workspaceLabel: workspaceLabel(t),
      workspaceBadge: workspaceBadge(t),
      workspaceKey: workspaceSortKey(t)
    })
  }
  if (order === "recent") {
    var rank = ({})
    for (var m = 0; m < mru.length; m++) rank[mru[m]] = m
    rows.sort(function (a, b) {
      var ra = rank[a.address] === undefined ? Number.MAX_SAFE_INTEGER : rank[a.address]
      var rb = rank[b.address] === undefined ? Number.MAX_SAFE_INTEGER : rank[b.address]
      if (ra !== rb) return ra - rb
      return a.appId.localeCompare(b.appId)
    })
  } else {
    rows.sort(function (a, b) {
      if (a.workspaceKey !== b.workspaceKey) return a.workspaceKey - b.workspaceKey
      return a.appId.localeCompare(b.appId)
    })
  }
  return rows
}

function headerFor(rows, index, order) {
  if (order !== "workspace") return ""
  var row = rows[index]
  if (!row) return ""
  if (index === 0) return row.workspaceLabel
  return rows[index - 1].workspaceLabel === row.workspaceLabel ? "" : row.workspaceLabel
}

function pushMru(mru, address, limit) {
  var addr = String(address || "")
  if (addr.length === 0) return mru
  var next = [addr]
  for (var i = 0; i < mru.length && next.length < limit; i++) {
    if (mru[i] !== addr) next.push(mru[i])
  }
  return next
}

function previousAddress(mru, liveAddresses) {
  for (var i = 1; i < mru.length; i++) {
    if (liveAddresses[mru[i]]) return mru[i]
  }
  return ""
}

function countLabel(count) {
  if (count === 0) return "No open windows"
  return count === 1 ? "1 open window" : count + " open windows"
}
