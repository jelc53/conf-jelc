-- REMEMBER TO RUN :PackerSync or :PackerCompile after editing

-- global options
vim.g.mapleader = ";"
vim.g.luasnippets_path = "~/.config/snippets"
vim.opt.tabstop = 2
vim.opt.conceallevel = 2
vim.opt.shell = "/bin/bash"
vim.opt.mouse = "nv" -- `:h mouse`

-- auto close file explorer when quiting incase a single buffer is left
vim.cmd('autocmd BufEnter * if (winnr("$") == 1 && &filetype == "nvimtree") | q | endif')
-- spell check markdown and tex files
vim.cmd([[
  augroup spellCheck
    autocmd!
    autocmd Filetype plaintext,markdown setlocal spell
    autocmd BufRead,BufNewFile *.md,*.rmd,*.Rmd,*.tex setlocal spell
  augroup END
]])
-- make panes same size
vim.cmd("autocmd VimResized * wincmd = ")
-- allow terminal width to dynamically adjust, useful with iron.nvim
vim.cmd('autocmd BufLeave * if &buftype == "terminal" | :set nowfw | endif')
-- wrap text at 80 columns for markdown; to add tex: "*.tex,*.md" with no spaces
vim.cmd("autocmd BufRead,BufNewFile *.md setlocal textwidth=80")
-- Use internal formatting for bindings like gq.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.bo[args.buf].formatexpr = nil
	end,
})
