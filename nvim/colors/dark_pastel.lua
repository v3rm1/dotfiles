-- Setup
vim.g.colors_name = "dark_pastel"
vim.o.termguicolors = true
vim.o.background = "dark"

local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- 1. THE PALETTE (25-Color)
local c = {
    bg         = "#000000",
    fg         = "#E0E0E0",
    surface    = "#1A1A1A",
    selection  = "#262626",
    grey       = "#666666",
    black      = "#000000",

    -- Core Syntax
    peach      = "#FFD1B3",
    tan        = "#F9F5D7",
    teal       = "#A9FFEB",
    blue       = "#B3E5FF",
    purple     = "#E2CFFF", 
    red        = "#FFB3B3",
    yellow     = "#FFF5B3", 
    periwinkle = "#B3C7FF",

    -- Extended & Plugin Colors
    deep_teal  = "#80E5CF", 
    seafoam    = "#C2FFE0", 
    sky_blue   = "#A3D5FF",
    lavender   = "#D1B3FF", 
    rose       = "#FFC4D6", 
    coral      = "#FFB3A1",
    sage       = "#D4FFD1", 
    mint       = "#98FFD9", 
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

-- 2. CORE UI
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = "#080808" })
hl("FloatBorder", { fg = c.surface, bg = "#080808" })
hl("CursorLine", { bg = "#0F0F0F" })
hl("Visual", { bg = c.selection })
hl("Search", { fg = c.black, bg = c.yellow, bold = true })
hl("IncSearch", { fg = c.black, bg = c.rose, bold = true })
hl("LineNr", { fg = "#444444" })
hl("CursorLineNr", { fg = c.peach, bold = true })
hl("WinSeparator", { fg = c.surface })

-- 3. STANDARD SYNTAX (Using Sage for Comments)
hl("Comment", { fg = c.grey, italic = true })
hl("Constant", { fg = c.peach, bold = true })
hl("String", { fg = c.tan })
hl("Identifier", { fg = c.blue })
hl("Function", { fg = c.periwinkle, bold = true })
hl("Statement", { fg = c.teal, bold = true })
hl("PreProc", { fg = c.purple })
hl("Type", { fg = c.deep_teal, italic = true })
hl("Special", { fg = c.rose })
hl("Error", { fg = c.red, bold = true })
hl("Todo", { fg = c.ice, bold = true })
hl("Underlined", { underline = true })

-- 4. TREESITTER (@Logic)
hl("@annotation", { fg = c.orchid })
hl("@attribute", { fg = c.plum })
hl("@boolean", { fg = c.seafoam, bold = true })
hl("@character", { fg = c.tan })
hl("@character.special", { fg = c.rose })
hl("@comment", { link = "Comment" })
hl("@comment.error", { fg = c.red })
hl("@comment.hint", { fg = c.sand }) -- Using Sand for Hints
hl("@comment.info", { fg = c.sky_blue })
hl("@comment.todo", { fg = c.ice, bold = true })
hl("@comment.warning", { fg = c.yellow })
hl("@constant", { link = "Constant" })
hl("@constant.builtin", { fg = c.rose })
hl("@constant.macro", { fg = c.purple })
hl("@constructor", { fg = c.orchid })
hl("@constructor.tsx", { fg = c.periwinkle })
hl("@diff.delta", { link = "DiffChange" })
hl("@diff.minus", { link = "DiffDelete" })
hl("@diff.plus", { link = "DiffAdd" })
hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.rose })
hl("@function.macro", { fg = c.purple })
hl("@keyword", { fg = c.teal, bold = true })
hl("@keyword.function", { fg = c.orchid })
hl("@keyword.import", { fg = c.purple })
hl("@keyword.operator", { fg = c.lavender })
hl("@keyword.return", { fg = c.teal, italic = true })
hl("@label", { fg = c.blue })
hl("@number", { fg = c.seafoam })
hl("@operator", { fg = c.lavender })
hl("@property", { fg = c.ice })
hl("@punctuation.bracket", { fg = c.steel })
hl("@punctuation.delimiter", { fg = c.lavender })
hl("@punctuation.special", { fg = c.lavender })
hl("@punctuation.special.markdown", { fg = c.peach })
hl("@string", { link = "String" })
hl("@string.documentation", { fg = c.yellow })
hl("@string.escape", { fg = c.orchid })
hl("@string.regexp", { fg = c.rose })
hl("@tag", { fg = c.teal })
hl("@tag.attribute", { fg = c.coral })
hl("@tag.delimiter", { fg = c.steel })
hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.periwinkle })
hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.red })
hl("@variable.member", { fg = c.sky_blue })
hl("@variable.parameter", { fg = c.sage })

-- LSP modification
hl("@lsp.mod.builtin", { fg = c.red, bold = true })
hl("@lsp.type.namespace", { link = "@namespace.builtin" })
hl("@lsp.type.selfParameter", { link = "@variable.builtin" })
hl("@lsp.type.variable", { fg = c.ice})
hl("@lsp.typemod.string.documentation", { link = "@string.documentation" })
hl("@lsp.typemod.variable.global", { fg = c.red })
hl("@lsp.typemod.variable.readonly", { fg = c.coral })
hl("@module", { fg = c.peach})
hl("@module.builtin", { fg = c.red })
hl("@namespace.builtin", { fg = c.tan})

-- Markup
hl("@markup.emphasis", { italic = true })
hl("@markup.heading", { fg = c.periwinkle, bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.link", { fg = c.mint })
hl("@markup.link.label", { fg = c.peach })
hl("@markup.link.url", { fg = c.sky_blue, underline = true })
hl("@markup.list.markdown", { fg = c.peach, bold = true })
hl("@markup.raw.markdown_inline", { bg = c.surface, fg = c.ice })
hl("@markup.strong", { bold = true })

-- Treesitter context
hl("TreesitterContext", { bg = "#0D0D0D" })

-- 5. NEOGIT
hl("NeogitBranch", { fg = c.orchid })
hl("NeogitRemote", { fg = c.purple })
hl("NeogitHunkHeader", { bg = c.surface, fg = c.fg })
hl("NeogitHunkHeaderHighlight", { bg = "#2A2A2A", fg = c.blue })
hl("NeogitDiffContextHighlight", { bg = "#0D0D0D", fg = c.steel })
hl("NeogitDiffDeleteHighlight", { fg = c.crimson, bg = "#220000" })
hl("NeogitDiffAddHighlight", { fg = c.emerald, bg = "#002200" })

-- 6. BLINK.CMP & COPILOT 
hl("BlinkCmpDoc", { fg = c.fg, bg = "#080808" })
hl("BlinkCmpDocBorder", { fg = c.surface, bg = "#080808" })
hl("BlinkCmpGhostText", { fg = c.clay })
hl("BlinkCmpKindCodeium", { fg = c.teal })
hl("BlinkCmpKindCopilot", { fg = c.teal })
hl("BlinkCmpKindDefault", { fg = c.steel })
hl("BlinkCmpLabel", { fg = c.fg })
hl("BlinkCmpLabelDeprecated", { fg = c.grey, strikethrough = true })
hl("BlinkCmpLabelMatch", { fg = c.periwinkle, bold = true })
hl("BlinkCmpMenu", { fg = c.fg, bg = "#080808" })
hl("BlinkCmpMenuBorder", { fg = c.surface, bg = "#080808" })
hl("BlinkCmpSignatureHelp", { fg = c.fg, bg = "#080808" })
hl("BlinkCmpSignatureHelpBorder", { fg = c.surface, bg = "#080808" })
hl("CopilotAnnotation", { fg = c.clay })
hl("CopilotSuggestion", { fg = c.clay, italic = true })

-- 7. MINI.NVIM 
hl("MiniFilesBorder", { link = "FloatBorder" })
hl("MiniFilesDirectory", { fg = c.gold, bold = true })
hl("MiniFilesFile", { fg = c.fg })
hl("MiniFilesNormal", { link = "NormalFloat" })
hl("MiniFilesTitleFocused", { fg = c.peach, bg = "#080808", bold = true })
hl("MiniIconsGrey", { fg = c.fg })
hl("MiniIconsPurple", { fg = c.purple })
hl("MiniIconsBlue", { fg = c.blue })
hl("MiniIconsCyan", { fg = c.teal })
hl("MiniIconsGreen", { fg = c.emerald })
hl("MiniIconsYellow", { fg = c.yellow })
hl("MiniIconsOrange", { fg = c.peach })
hl("MiniIconsRed", { fg = c.red })
hl("MiniSurround", { bg = c.peach, fg = c.black })

-- 8. RENDER-MARKDOWN
hl("RenderMarkdownBullet", { fg = c.peach })
hl("RenderMarkdownCode", { bg = "#0A0A0A" })
hl("RenderMarkdownDash", { fg = c.peach })
hl("RenderMarkdownTableHead", { fg = c.red })
hl("RenderMarkdownTableRow", { fg = c.peach })

-- 9. SNACKS.NVIM
hl("SnacksNotifierError", { fg = c.fg })
hl("SnacksNotifierIconError", { fg = c.red })
hl("SnacksNotifierTitleError", { fg = c.red })
hl("SnacksNotifierWarn", { fg = c.fg })
hl("SnacksNotifierIconWarn", { fg = c.yellow })
hl("SnacksNotifierInfo", { fg = c.fg })
hl("SnacksNotifierIconInfo", { fg = c.sky_blue })
hl("SnacksDashboardHeader", { fg = c.blue })
hl("SnacksDashboardIcon", { fg = c.periwinkle })
hl("SnacksDashboardKey", { fg = c.peach })
hl("SnacksDashboardDesc", { fg = c.mint })
hl("SnacksDashboardSpecial", { fg = c.purple })
hl("SnacksIndent", { fg = "#121212", nocombine = true })
hl("SnacksIndentScope", { fg = c.periwinkle, nocombine = true })
hl("SnacksInputTitle", { fg = c.yellow })
hl("SnacksPickerInputBorder", { fg = c.peach, bg = "#080808" })
hl("SnacksPickerSelected", { fg = c.orchid })

-- 10. TROUBLE & WHICH-KEY
hl("TroubleNormal", { fg = c.fg, bg = "NONE" })
hl("TroubleText", { fg = c.steel })
hl("TroubleCount", { fg = c.orchid, bg = c.surface })
hl("WhichKey", { fg = c.mint })
hl("WhichKeyGroup", { fg = c.blue })
hl("WhichKeyDesc", { fg = c.orchid })
hl("WhichKeySeparator", { fg = c.grey })

-- Diagnostics (Squiggles/Undercurls)
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.periwinkle })
hl("DiagnosticHint", { fg = c.sand })

-- Use 'sp' to set the color of the squiggle
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.periwinkle })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.sand })
