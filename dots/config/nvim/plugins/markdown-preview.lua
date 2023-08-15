vim.g.mkdp_auto_close = 0
vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/markdown-preview/custom.css")
vim.api.nvim_set_keymap("n", "<leader>p", ":MarkdownPreview <CR>", {
	noremap = true,
	silent = true,
})
