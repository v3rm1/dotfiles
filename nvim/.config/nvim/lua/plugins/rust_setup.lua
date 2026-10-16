-- rustaceanvim starts rust-analyzer itself (don't also enable it via
-- vim.lsp.enable) and reads this table when the first Rust buffer opens.
-- It uses the toolchain's rust-analyzer so it matches cargo/rust-toolchain.toml.
vim.g.rustaceanvim = {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                check = { command = "clippy" },
                cargo = { allFeatures = true },
                procMacro = { enable = true },
            },
        },
        on_attach = function(_, bufnr)
            local map = function(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "Rust: " .. desc })
            end
            map("<leader>rr", "<cmd>RustLsp runnables<cr>", "runnables")
            map("<leader>rd", "<cmd>RustLsp debuggables<cr>", "debuggables")
            map("<leader>rt", "<cmd>RustLsp testables<cr>", "testables")
            map("<leader>re", "<cmd>RustLsp explainError<cr>", "explain error")
            map("<leader>rc", "<cmd>RustLsp openCargo<cr>", "open Cargo.toml")
            map("<leader>rm", "<cmd>RustLsp expandMacro<cr>", "expand macro")
        end,
    },
}
