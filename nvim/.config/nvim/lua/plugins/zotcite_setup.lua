-- zotcite: Zotero citation completion (type @ then author/title), reference
-- info and opening PDFs, via <leader>z* maps on a citation key.
-- Not enabled for LaTeX: zotcite rewrites the \addbibresource .bib on save,
-- which would clobber the curated .bib files in the Overleaf paper repos.
require("zotcite").setup({
    key_type = "better-bibtex",
    filetypes = { "markdown", "pandoc", "quarto", "rmd" },
})
