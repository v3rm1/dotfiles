local M = {}

M.ts_textobj_delimiter_miniai = function(ai_captures)
    return function(ai_type, _, _)
        local target_captures = ai_captures[ai_type]

        local ts_queries = require("nvim-treesitter.query")
        local matches = ts_queries.get_capture_matches_recursively(0, target_captures, "textobjects")

        ---@param node TSNode
        local get_match_range = function(node, metadata)
            return (metadata or {}).range and metadata.range or { node:range() }
        end

        local matched_ranges = vim.tbl_map(function(m)
            return get_match_range(m.node, m.metadata)
        end, matches)

        local ret = {}

        for i = 1, #matched_ranges - 1 do
            local cur_row = matched_ranges[i][1] + 1
            local next_row = matched_ranges[i + 1][1] + 1
            if ai_type == "i" then
                ret[i] = {
                    from = { line = cur_row + 1, col = 1 },
                    to = {
                        line = next_row - 1,
                        col = #vim.api.nvim_buf_get_lines(0, next_row - 2, next_row - 1, false)[1] + 1,
                    },
                }
            elseif ai_type == "a" then
                ret[i] = {
                    from = { line = cur_row, col = 1 },
                    to = {
                        line = next_row,
                        col = #vim.api.nvim_buf_get_lines(0, next_row - 1, next_row, false)[1] + 1,
                    },
                }
            end
        end

        local last_line = vim.api.nvim_buf_line_count(0)
        if ai_type == "i" then
            local last_row = matched_ranges[#matched_ranges][1] + 1
            ret[#ret + 1] = {
                from = { line = last_row + 1, col = 1 },
                to = {
                    line = last_line,
                    col = #vim.api.nvim_buf_get_lines(0, last_line - 1, last_line, false)[1] + 1,
                },
            }
        elseif ai_type == "a" then
            local last_row = matched_ranges[#matched_ranges][1] + 1
            ret[#ret + 1] = {
                from = { line = last_row, col = 1 },
                to = {
                    line = last_line,
                    col = #vim.api.nvim_buf_get_lines(0, last_line - 1, last_line, false)[1] + 1,
                },
            }
        end
        return ret
    end
end

return M
