vim.g.vimtex_view_method = "zathura"
-- be careful with 'has changed', it signifies when a definition is overwritten
vim.g.vimtex_quickfix_ignore_filters = {
	"Overfull",
	"Underfull",
	"has changed",
	"unicode-math",
	"Float too large",
	"float specifier",
	"headheight",
	"with utf8 based",
}
-- turn off continuous compilation
vim.cmd('let g:vimtex_compiler_latexmk = {"continuous": 0}')
vim.api.nvim_set_keymap("n", "<leader>p", ":VimtexCompile <CR>", {
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("n", "<leader>f", ":VimtexView <CR>", {
	noremap = true,
	silent = true,
})
