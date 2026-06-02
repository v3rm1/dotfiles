local M = {}

-- ── Bib Picker ───────────────────────────────────────────────────────────────

local function find_bib_files()
    local vt = vim.b.vimtex
    if vt and vt.sources then
        local bibs = vim.tbl_filter(function(s)
            return s:match("%.bib$") and vim.fn.filereadable(s) == 1
        end, vt.sources)
        if #bibs > 0 then return bibs end
    end
    return vim.fn.globpath(vim.fn.getcwd(), "**/*.bib", false, true)
end

local function get_field(body, name)
    local v = body:match(name .. "%s*=%s*{{([^}]*)}}")
           or body:match(name .. "%s*=%s*{([^{}]-)}")
           or body:match(name .. '%s*=%s*"([^"]*)"')
    return v and vim.trim(v:gsub("%s+", " ")) or ""
end

local function parse_bib(path)
    local entries = {}
    local lines = vim.fn.readfile(path)
    local i = 1
    while i <= #lines do
        local etype, key = lines[i]:match("^@(%a+)%s*{%s*([^,]+)%s*,")
        local skip = etype and (etype:lower() == "string" or etype:lower() == "preamble" or etype:lower() == "comment")
        if etype and not skip then
            local body_lines = { lines[i] }
            local depth = select(2, lines[i]:gsub("{", "")) - select(2, lines[i]:gsub("}", ""))
            i = i + 1
            while i <= #lines and depth > 0 do
                depth = depth + select(2, lines[i]:gsub("{", "")) - select(2, lines[i]:gsub("}", ""))
                table.insert(body_lines, lines[i])
                i = i + 1
            end
            local body = table.concat(body_lines, "\n")
            table.insert(entries, {
                key    = vim.trim(key),
                title  = get_field(body, "title"),
                author = get_field(body, "author"),
                year   = get_field(body, "year"),
            })
        else
            i = i + 1
        end
    end
    return entries
end

local function insert_cite(key)
    local cite = "\\cite{" .. key .. "}"
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { cite })
    vim.api.nvim_win_set_cursor(0, { row, col + #cite })
end

function M.bib_pick()
    local bib_files = find_bib_files()
    if #bib_files == 0 then
        vim.notify("latex_tools: no .bib files found", vim.log.levels.WARN)
        return
    end

    local all_entries = {}
    for _, path in ipairs(bib_files) do
        vim.list_extend(all_entries, parse_bib(path))
    end
    if #all_entries == 0 then
        vim.notify("latex_tools: no bib entries found", vim.log.levels.WARN)
        return
    end

    local fzf = require("fzf-lua")
    local lines, entry_map = {}, {}
    for _, e in ipairs(all_entries) do
        local author = (e.author:match("^([^,]+)") or e.author):sub(1, 20)
        local title  = #e.title > 48 and (e.title:sub(1, 48) .. "…") or e.title
        local line   = string.format("%-28s  %-20s  %-4s  %s", e.key, author, e.year, title)
        table.insert(lines, line)
        entry_map[line] = e
    end

    fzf.fzf_exec(lines, {
        prompt   = "Cite❯ ",
        winopts  = { height = 0.45, width = 0.85, border = "single" },
        fzf_opts = { ["--no-sort"] = true },
        actions  = {
            ["default"] = function(selected)
                if selected and selected[1] and entry_map[selected[1]] then
                    insert_cite(entry_map[selected[1]].key)
                end
            end,
        },
    })
end

-- ── Equation Preview ─────────────────────────────────────────────────────────

local function strip_delimiters(s)
    s = vim.trim(s)
    return s:match("^%$%$(.-)%$%$$")
        or s:match("^%\\%[(.-)%\\%]$")
        or s:match("^%$(.-)%$$")
        or s:match("^%\\%((.-)%\\%)$")
        or s
end

local function get_visual_selection()
    local s  = vim.fn.getpos("'<")
    local e  = vim.fn.getpos("'>")
    local ls = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
    if #ls == 0 then return nil end
    if #ls == 1 then return ls[1]:sub(s[3], e[3]) end
    ls[1]    = ls[1]:sub(s[3])
    ls[#ls]  = ls[#ls]:sub(1, e[3])
    return table.concat(ls, "\n")
end

local function math_at_cursor()
    local line = vim.api.nvim_get_current_line()
    local col  = vim.api.nvim_win_get_cursor(0)[2] + 1
    local s = 1
    while true do
        local ds, de, cap = line:find("%$(.-)%$", s)
        if not ds then break end
        if ds <= col and col <= de then return cap end
        s = de + 1
    end
end

local function compile_and_show(expr)
    local tmpdir  = vim.fn.tempname()
    vim.fn.mkdir(tmpdir, "p")
    local texfile = tmpdir .. "/eq.tex"
    local pdffile = tmpdir .. "/eq.pdf"
    local pngfile = tmpdir .. "/eq.png"

    vim.fn.writefile(vim.split(table.concat({
        "\\documentclass[12pt,border=8pt]{standalone}",
        "\\usepackage{amsmath,amssymb,amsfonts,mathtools}",
        "\\usepackage[T1]{fontenc}",
        "\\begin{document}",
        "$\\displaystyle " .. expr .. "$",
        "\\end{document}",
    }, "\n"), "\n"), texfile)

    local err = function(msg)
        vim.schedule(function() vim.notify("latex_tools: " .. msg, vim.log.levels.ERROR) end)
    end

    vim.fn.jobstart(
        { "pdflatex", "-interaction=nonstopmode", "-halt-on-error",
          "-output-directory=" .. tmpdir, texfile },
        {
            stdout_buffered = true,
            stderr_buffered = true,
            on_exit = function(_, code)
                if code ~= 0 then err("pdflatex failed (check expression syntax)") return end
                vim.fn.jobstart(
                    { "magick", "-density", "220", "-background", "white",
                      "-alpha", "remove", "-trim", "+repage", pdffile, pngfile },
                    {
                        on_exit = function(_, code2)
                            if code2 ~= 0 then err("magick conversion failed") return end
                            vim.schedule(function()
                                require("plugins.image_setup").open(pngfile)
                            end)
                        end,
                    }
                )
            end,
        }
    )
end

function M.eq_preview()
    local mode = vim.fn.mode()
    local expr

    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
        expr = get_visual_selection()
    else
        expr = get_visual_selection()
        if not expr or vim.trim(expr) == "" then expr = math_at_cursor() end
    end

    if not expr or vim.trim(expr) == "" then
        vim.notify("latex_tools: no math selected (visual select or cursor inside $...$)", vim.log.levels.WARN)
        return
    end

    expr = strip_delimiters(expr)
    vim.notify("latex_tools: compiling…", vim.log.levels.INFO)
    compile_and_show(expr)
end

-- ── Word Count ───────────────────────────────────────────────────────────────

local function parse_texcount(data)
    local text = table.concat(data, "\n")
    local function n(pat) return tonumber(text:match(pat)) or 0 end
    return {
        words        = n("Words in text:%s*(%d+)"),
        headers      = n("Words in headers:%s*(%d+)"),
        captions     = n("Words outside text[^:]*:%s*(%d+)"),
        math_inline  = n("Number of math inlines:%s*(%d+)"),
        math_display = n("Number of math displayed:%s*(%d+)"),
    }
end

local function wc_float(r)
    local total = r.words + r.headers + r.captions
    local lines = {
        string.format("  Words (text):     %5d", r.words),
        string.format("  Words (headers):  %5d", r.headers),
        string.format("  Words (captions): %5d", r.captions),
        "  ─────────────────────",
        string.format("  Total text:       %5d", total),
        string.format("  Math inline:      %5d", r.math_inline),
        string.format("  Math display:     %5d", r.math_display),
    }
    local sw, sh = vim.o.columns, vim.o.lines
    local width, height = 28, #lines

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local win = vim.api.nvim_open_win(buf, false, {
        relative  = "editor",
        width     = width,
        height    = height,
        col       = sw - width - 3,
        row       = sh - height - 4,
        style     = "minimal",
        border    = "single",
        title     = " Word Count ",
        title_pos = "center",
        zindex    = 60,
    })

    vim.api.nvim_create_autocmd(
        { "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" },
        {
            buffer   = vim.api.nvim_get_current_buf(),
            once     = true,
            callback = function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end,
        }
    )
end

function M.word_count()
    local filepath = vim.fn.expand("%:p")
    if not filepath:match("%.tex$") then
        vim.notify("latex_tools: not a .tex file", vim.log.levels.WARN)
        return
    end
    if vim.fn.executable("texcount") == 0 then
        vim.notify("latex_tools: texcount not found (brew install texcount)", vim.log.levels.ERROR)
        return
    end

    vim.fn.jobstart({ "texcount", filepath }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then vim.schedule(function() wc_float(parse_texcount(data)) end) end
        end,
        on_exit = function(_, code)
            if code ~= 0 then
                vim.schedule(function() vim.notify("latex_tools: texcount failed", vim.log.levels.ERROR) end)
            end
        end,
    })
end

return M
