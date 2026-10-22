--!nonstrict
-- File search launcher provider (replacement for DMS + dsearch).
--
-- `/f <text>`: fixed-string, smart-case search (hidden files included) with fd under the configured root.
-- Enter opens the match with xdg-open.

-- Hidden files are searched (dotfiles, ~/.config), minus caches and build junk.
local EXCLUDES = { ".git", ".cache", "node_modules", ".venv", "__pycache__", ".local/share/Trash", ".local/state", ".mozilla", ".var" }

local function basename(path)
  return path:match("([^/]+)/?$") or path
end

local function dirname(path)
  return path:match("^(.*)/[^/]+/?$") or ""
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  if text == "" then
    launcher.setResults(query, { { id = "", title = "Type to search files", glyph = "file-search" } })
    return
  end
  local root = noctalia.expandPath(noctalia.getConfig("root") or "~")
  local limit = tostring(noctalia.getConfig("max_results") or 40)
  local argv = { "fd", "--hidden", "--fixed-strings", "--absolute-path", "--max-results", limit }
  for _, pattern in EXCLUDES do
    table.insert(argv, "--exclude")
    table.insert(argv, pattern)
  end
  table.insert(argv, "--")
  table.insert(argv, text)
  table.insert(argv, root)
  noctalia.runAsync(argv, function(result)
    local rows = {}
    for line in (result.stdout or ""):gmatch("[^\n]+") do
      local isDir = line:sub(-1) == "/"
      table.insert(rows, {
        id = line,
        title = basename(line),
        subtitle = dirname(line),
        glyph = if isDir then "folder" else "file",
      })
    end
    if #rows == 0 then
      rows[1] = { id = "", title = "No matches", glyph = "mood-empty" }
    end
    launcher.setResults(query, rows)
  end)
end

function onActivate(id)
  if id ~= "" then
    noctalia.runAsync({ "xdg-open", id })
  end
end
