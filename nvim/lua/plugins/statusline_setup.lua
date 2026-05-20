-- Colors pulled from dark_pastel palette
local p = {
    surface  = "#1A1A1A",
    grey     = "#666666",
    mint     = "#98FFD9",
    sky      = "#A3D5FF",
    lavender = "#D1B3FF",
    gold     = "#FFE0B3",
    coral    = "#FFB3A1",
    teal     = "#A9FFEB",
    emerald  = "#B3FFB3",
    yellow   = "#FFF5B3",
    red      = "#FFB3B3",
}

local modes = {
    n       = { glyph = "🅝 ", hl = "SLModeNormal" },
    i       = { glyph = "🅘 ", hl = "SLModeInsert" },
    v       = { glyph = "🅥 ", hl = "SLModeVisual" },
    c       = { glyph = "🅒 ", hl = "SLModeCommand" },
    r       = { glyph = "🅡 ", hl = "SLModeReplace" },
    s       = { glyph = "🅢 ", hl = "SLModeVisual" },
    t       = { glyph = "🅣 ", hl = "SLModeTerminal" },
}

local function setup_hls()
    vim.api.nvim_set_hl(0, "SLModeNormal",   { fg = p.lavender , bg = p.surface, bold = true })
    vim.api.nvim_set_hl(0, "SLModeInsert",   { fg = p.emerald , bg = p.surface, bold = true })
    vim.api.nvim_set_hl(0, "SLModeVisual",   { fg = p.sky , bg = p.surface, bold = true })
    vim.api.nvim_set_hl(0, "SLModeCommand",  { fg = p.gold , bg = p.surface, bold = true })
    vim.api.nvim_set_hl(0, "SLModeReplace",  { fg = p.teal , bg = p.surface, bold = true })
    vim.api.nvim_set_hl(0, "SLModeTerminal", { fg = p.coral , bg = p.surface, bold = true })
    vim.api.nvim_set_hl(0, "SLGitAdd",    { fg = p.emerald })
    vim.api.nvim_set_hl(0, "SLGitChange", { fg = p.yellow })
    vim.api.nvim_set_hl(0, "SLGitDelete", { fg = p.red })
    vim.api.nvim_set_hl(0, "SLDimmed", { fg = p.grey })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_hls })
setup_hls()

-- Helpers

local function get_mode()
    return modes[vim.fn.mode()] or modes["n"]
end

local function file_icon_name()
    local fname = vim.fn.expand("%:t")
    if fname == "" then return "[No Name]" end
    local icon = require("mini.icons").get("file", fname)
    return icon .. " " .. vim.fn.expand("%:~:.")
end

local function git_branch()
    local ok, head = pcall(vim.fn.FugitiveHead)
    if not ok or head == "" then return "" end
    return " " .. head
end

local function git_hunks()
    local gs = vim.b.gitsigns_status_dict
    if not gs then return "" end
    local parts = {}
    if (gs.added   or 0) > 0 then parts[#parts+1] = "%#SLGitAdd#󰐕 "    .. gs.added   .. "%*" end
    if (gs.changed or 0) > 0 then parts[#parts+1] = "%#SLGitChange#󰏭 " .. gs.changed .. "%*" end
    if (gs.removed or 0) > 0 then parts[#parts+1] = "%#SLGitDelete#󰍴 " .. gs.removed .. "%*" end
    return table.concat(parts, " ")
end

local function filetype_icon()
    local ft = vim.bo.filetype
    if ft == "" then return "󰈔 plain" end
    local icon = require("mini.icons").get("filetype", ft)
    return icon .. " " .. ft
end

local function location()
    return string.format("%d:%d", vim.fn.line("."), vim.fn.virtcol(".") - 1)
end

local function char_count()
    return vim.fn.wordcount().chars .. " chars"
end

-- Build statusline string
local function build()
    local mode    = get_mode()
    local hunks   = git_hunks()
    local branch  = git_branch()

    local function hl(group, text)
        return "%#" .. group .. "#" .. text .. "%*"
    end

    local left = table.concat({
        hl(mode.hl, "  " .. mode.glyph .. "  "),
        "  ",
        file_icon_name(),
        hl("SLDimmed", "  " .. location() .. "  " .. char_count()),
    }, "")

    local right_parts = {}
    if hunks  ~= "" then right_parts[#right_parts+1] = hunks end
    if branch ~= "" then right_parts[#right_parts+1] = branch end
    right_parts[#right_parts+1] = filetype_icon()

    local right = table.concat(right_parts, hl("SLDimmed", "   ")) .. "  "

    return left .. "%=" .. right
end

vim.o.statusline = "%{%v:lua.require('plugins.statusline_setup').build()%}"

require("gitsigns").setup({
    signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        vim.keymap.set("n", "]h", gs.next_hunk,     { buffer = bufnr, desc = "Next hunk" })
        vim.keymap.set("n", "[h", gs.prev_hunk,     { buffer = bufnr, desc = "Prev hunk" })
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk,   { buffer = bufnr, desc = "Stage hunk" })
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk,   { buffer = bufnr, desc = "Reset hunk" })
    end,
})

return { build = build }
