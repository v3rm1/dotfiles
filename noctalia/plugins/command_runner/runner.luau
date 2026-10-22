--!nonstrict
-- Command runner launcher provider (port of the DMS commandRunner plugin).
--
-- `/run <command>`: Enter runs it in a terminal, the second row runs it detached.
-- With an empty query the provider lists previous commands, most recent first.

local history = {}
local historyFile = nil

local function split(str)
  local words = {}
  for word in str:gmatch("%S+") do
    table.insert(words, word)
  end
  return words
end

local function loadHistory()
  local dir = noctalia.pluginDataDir()
  if not dir then
    return
  end
  noctalia.mkdirAll(dir)
  historyFile = dir .. "/history.json"
  local raw = noctalia.readFile(historyFile)
  local decoded = raw and noctalia.json.decode(raw)
  if type(decoded) == "table" then
    history = decoded
  end
end

local function remember(cmd)
  local index = table.find(history, cmd)
  if index then
    table.remove(history, index)
  end
  table.insert(history, 1, cmd)
  local limit = noctalia.getConfig("history_size") or 50
  while #history > limit do
    table.remove(history)
  end
  if historyFile then
    noctalia.writeFile(historyFile, noctalia.json.encode(history) or "[]")
  end
end

loadHistory()

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}
  if text ~= "" then
    table.insert(rows, { id = "term:" .. text, title = text, subtitle = "Run in terminal", glyph = "terminal" })
    table.insert(rows, { id = "bg:" .. text, title = text, subtitle = "Run in background", glyph = "player-play" })
  end
  local needle = text:lower()
  for _, cmd in history do
    if cmd ~= text and (needle == "" or cmd:lower():find(needle, 1, true)) then
      table.insert(rows, { id = "term:" .. cmd, title = cmd, subtitle = "History", glyph = "history" })
    end
  end
  if #rows == 0 then
    rows[1] = { id = "", title = "Type a command to run", glyph = "terminal" }
  end
  launcher.setResults(query, rows)
end

function onActivate(id)
  local mode, cmd = id:match("^(%a+):(.+)$")
  if not cmd then
    return
  end
  remember(cmd)
  if mode == "bg" then
    noctalia.runAsync({ "sh", "-c", cmd })
    return
  end
  local argv = split(noctalia.getConfig("terminal") or "kitty --hold")
  table.insert(argv, "sh")
  table.insert(argv, "-c")
  table.insert(argv, cmd)
  noctalia.runAsync(argv)
end
