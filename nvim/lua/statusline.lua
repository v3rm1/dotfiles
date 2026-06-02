--Default statusline
local default =
    "%<%f %h%w%m%r %{% v:lua.require('vim._core.util').term_exitcode() %}%=%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &busy > 0 ? '◐ ' : '' %}%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"

local modes = setmetatable({
    ["n"] = { short = " ", hl = "String" },
    ["i"] = { short = "󰫶 ", hl = "DiagnosticInfo" },
    ["v"] = { short = " ", hl = "Statement" },
    ["V"] = { short = " ", hl = "Statement" },
    ["\22"] = { short = " ", hl = "Statement" },
    ["R"] = { short = " ", hl = "DiagnosticError" },
    ["c"] = { short = "󱗿 ", hl = "DiagnosticWarn" },
    ["s"] = { short = " ", hl = "DiagnosticWarn" },
    ["S"] = { short = " ", hl = "DiagnosticWarn" },
    ["\19"] = { short = " ", hl = "DiagnosticWarn" },
    ["r"] = { short = "󰰙 ", hl = "DiagnosticWarn" },
    ["!"] = { short = " ", hl = "DiagnosticError" },
    ["t"] = { short = " ", hl = "DiagnosticWarn" },
}, {
    __index = function()
        return { short = "[U]", hl = "DiagnosticOk" }
    end,
})

local function section_mode()
    local m = modes[vim.fn.mode()]
    return "%#" .. m.hl .. "#" .. m.short .. "%*"
end

local function section_filesize()
    local size = vim.fn.getfsize(vim.fn.expand("%"))
    if size <= 0 then
        return ""
    end
    if size < 1024 then
        return "%#Conceal#" .. size .. "B%* "
    end
    if size < 1024 * 1024 then
        return "%#Conceal#" .. string.format("%.1fk", size / 1024) .. "%* "
    end
    return "%#Conceal#" .. string.format("%.1fM", size / 1024 / 1024) .. "%* "
end

local function section_file()
    local fname = vim.fn.expand("%:t")
    local mi = package.loaded["mini.icons"]
    local icon = mi and mi.get("file", fname) or ""
    local hl = "htmlH1"
    if vim.bo.modified then
        hl = "CursorLineNr"
    elseif vim.bo.buftype == "help" then
        hl = "DiagnosticOk"
    elseif not vim.bo.modifiable or vim.bo.readonly then
        hl = "MiniTestFail"
    end
    return "%#" .. hl .. "#" .. (icon ~= "" and icon .. " " or "") .. fname .. "%h%w%m%r%*"
end

local function section_alt()
    local alt = vim.fn.expand("#:t")
    if alt == "" then
        return ""
    end
    return "%#Comment#" .. "％" .. alt .. "%* "
end

local function section_location()
    return "%2l:%-2v %P%*"
end

local function section_hunks()
    local s = vim.b.minidiff_summary
    if not s then
        return ""
    end
    local parts = {}
    if (s.add or 0) > 0 then
        parts[#parts + 1] = "%#DiagnosticHint#+" .. s.add .. "%*"
    end
    if (s.change or 0) > 0 then
        parts[#parts + 1] = "%#DiagnosticWarn#~" .. s.change .. "%*"
    end
    if (s.delete or 0) > 0 then
        parts[#parts + 1] = "%#DiagnosticError#-" .. s.delete .. "%*"
    end
    return "" .. table.concat(parts, " ") .. " "
end

local function section_branch()
    local ok, head = pcall(vim.fn.FugitiveHead)
    if not ok or head == "" then
        head = ""
    else
        head = "%#DiagnosticInfo#" .. "󰘬 " .. head .. "%*"
    end
    return " " .. head
end

local function section_filetype()
    local ft = vim.bo.filetype
    if ft == "" then
        return "plain"
    end
    local mi = package.loaded["mini.icons"]
    if mi then
        local icon, hl = mi.get("filetype", ft)
        return "%#" .. hl .. "#" .. icon .. " " .. ft .. "%* "
    end
    return ft .. " "
end

local function section_busy()
    if vim.bo.busy > 0 then
        return "◐"
    end
    return ""
end

local function section_diag()
    if not package.loaded["vim.diagnostic"] then
        return ""
    end
    if not next(vim.diagnostic.count()) then
        return ""
    end
    return vim.diagnostic.status()
end

local function section_exitcode()
    return require("vim._core.util").term_exitcode()
end

local function build()
    local function join(parts)
        local filtered = {}
        for _, v in ipairs(parts) do
            if v ~= "" then
                filtered[#filtered + 1] = v
            end
        end
        return table.concat(filtered, " ")
    end

    local left = join({
        section_mode(),
        section_filesize(),
        section_file(),
        section_alt(),
        section_location(),
        section_exitcode(),
    })

    local right = join({
        section_diag(),
        section_branch(),
        section_hunks(),
        section_filetype(),
        section_busy(),
    })

    return "%#Title#▌%* " .. left .. "%=" .. right .. "%#Title#▐%*"
end

vim.o.statusline = "%{%v:lua.require('statusline').build()%}"

return { build = build }
