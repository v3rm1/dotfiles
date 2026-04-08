-- Modern Classic: Optimized for #000000
local highlight = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- 1. The Palette (High-Luminance for Pure Black)
local c = {
    bg = "NONE", -- True Black
    fg = "#e0e0e0", -- Crisp White
    dark = "#121212", -- For subtle UI elements
    surface = "#2a2a2a", -- For selection/visual mode
    grey = "#666666", -- Comments (kept low to stay out of the way)

    -- Group 1: Core
    peach      = "#FFD1B3", 
    tan        = "#F9F5D7", 
    teal       = "#A9FFEB",
    blue       = "#B3E5FF", 
    purple     = "#E2CFFF", 
    red        = "#FFB3B3",
    yellow     = "#FFF5B3", 
    periwinkle = "#B3C7FF",

    -- Group 2: Extended Syntax (Treesitter)
    deep_teal  = "#80E5CF", 
    seafoam    = "#C2FFE0", 
    sky_blue   = "#A3D5FF",
    lavender   = "#D1B3FF", 
    rose       = "#FFC4D6", 
    coral      = "#FFB3A1",
    sage       = "#D4FFD1", 
    mint       = "#98FFD9",

    -- Group 3: UI & Plugins
    steel      = "#A3B8CC", 
    gold       = "#FFE0B3", 
    plum       = "#EBB3FF",
    emerald    = "#B3FFB3", 
    crimson    = "#FFB3C1", 
    clay       = "#D9B3A3",
    ice        = "#E0F5FF", 
    orchid     = "#F5B3FF", 
    sand       = "#E6DFB3",


}

-- 2. Setup
vim.g.colors_name = "modern_classic"
vim.o.termguicolors = true
vim.o.background = "dark"

-- 3. CORE UI (Standard Neovim Groups)
highlight("Normal", { fg = c.fg, bg = c.bg }) -- bg is "NONE" for Ghostty transparency
highlight("NormalFloat", { fg = c.fg, bg = "#080808" }) 
highlight("FloatBorder", { fg = c.surface, bg = "#080808" })
highlight("ColorColumn", { bg = "#0f0f0f" })
highlight("CursorLine", { bg = "#0f0f0f" })
highlight("Visual", { bg = c.selection })
highlight("WinSeparator", { fg = c.surface })
highlight("Search", { fg = "#000000", bg = c.yellow, bold = true })
highlight("IncSearch", { fg = "#000000", bg = c.rose, bold = true })
highlight("LineNr", { fg = "#444444" })
highlight("CursorLineNr", { fg = c.peach, bold = true })

-- 4. SYNTAX (Standard Neovim & Treesitter)
highlight("Comment", { fg = c.sage, italic = true })
highlight("Constant", { fg = c.peach, bold = true })
highlight("String", { fg = c.tan })
highlight("Identifier", { fg = c.blue })
highlight("Function", { fg = c.periwinkle, bold = true })
highlight("Statement", { fg = c.teal, bold = true })
highlight("PreProc", { fg = c.purple })
highlight("Type", { fg = c.deep_teal, italic = true })
highlight("Special", { fg = c.rose })
highlight("Underlined", { underline = true, sp = c.sky_blue })
highlight("Error", { fg = c.red, bold = true })

-- Treesitter Refinement
highlight("@namespace.builtin", { fg = c.red })
highlight("@variable", { fg = c.fg })
highlight("@variable.builtin", { fg = c.coral })
highlight("@keyword", { link = "Statement" })
highlight("@function", { link = "Function" })
highlight("@string", { link = "String" })
highlight("@constant", { link = "Constant" })
highlight("@constant.builtin", { fg = c.seafoam, bold = true })
highlight("@parameter", { fg = c.sky_blue, italic = true })
highlight("@property", { fg = c.blue })
highlight("@field", { fg = c.blue })
highlight("@constructor", { fg = c.deep_teal })
highlight("@operator", { fg = c.lavender })

-- 5. PLUGIN CONSISTENCY

-- Completion (Blink.cmp / CoPilot)
highlight("BlinkCmpMenu", { link = "NormalFloat" })
highlight("BlinkCmpMenuBorder", { link = "FloatBorder" })
highlight("BlinkCmpLabelMatch", { fg = c.ice, bold = true })
highlight("CopilotSuggestion", { fg = c.clay, italic = true })

-- Git (Fugitive / Neogit / Gitsigns / Diffview)
highlight("DiffAdd", { bg = "#002200", fg = c.emerald })
highlight("DiffChange", { bg = "#111100", fg = c.tan })
highlight("DiffDelete", { bg = "#220000", fg = c.crimson })
highlight("DiffText", { bg = "#222200", fg = c.tan, bold = true })
highlight("NeogitSectionHeader", { fg = c.orchid, bold = true })
highlight("NeogitDiffAddHighlight", { link = "DiffAdd" })
highlight("NeogitDiffDeleteHighlight", { link = "DiffDelete" })

-- Navigation & Files (Oil / Snacks / Telescope)
highlight("Directory", { fg = c.gold, bold = true }) -- Oil folders now "glow" gold
highlight("OilDir", { link = "Directory" })
highlight("OilDirIcon", { link = "Directory" })
highlight("SnacksPickerMatch", { fg = c.ice, bold = true })
highlight("SnacksIndent", { fg = "#121212" })
highlight("SnacksIndentScope", { fg = "#2a2a2a" })

-- Diagnostics (Trouble / LSP / Rustacean)
highlight("DiagnosticError", { fg = c.red })
highlight("DiagnosticWarn", { fg = c.yellow })
highlight("DiagnosticInfo", { fg = c.periwinkle })
highlight("DiagnosticHint", { fg = c.sand })
highlight("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
highlight("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
highlight("DiagnosticUnderlineInfo", { undercurl = true, sp = c.periwinkle })
highlight("DiagnosticUnderlineHint", { undercurl = true, sp = c.sand })

-- Markdown & Docs (Render-markdown / Vimtex)
highlight("RenderMarkdownH1", { fg = c.orchid, bold = true })
highlight("RenderMarkdownCode", { bg = "#0a0a0a" })
highlight("texTitle", { fg = c.periwinkle, bold = true })
highlight("texSection", { fg = c.mint, bold = true })

-- Utility (Which-key / Lazy / Mason / Fidget)
highlight("WhichKey", { fg = c.teal, bold = true })
highlight("WhichKeyGroup", { fg = c.orchid })
highlight("WhichKeyDesc", { fg = c.peach })
highlight("FidgetTitle", { fg = c.ice })
highlight("FidgetTask", { fg = c.steel })
