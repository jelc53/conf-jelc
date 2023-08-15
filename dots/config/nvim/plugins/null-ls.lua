local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
	-- [web] shell: sudo npm i -g @fsouza/prettierd
	b.formatting.prettierd,
	-- [R] R: install.packages('formatR')
	-- b.formatting.format_r,
	-- [rust] shell: cargo install rustfmt
	b.formatting.rustfmt,
	-- [lua] shell: cargo install stylua
	b.formatting.stylua,
	-- [python] shell: pip install black
	b.formatting.black,
	-- [python] shell: pip install isort
	b.formatting.isort,
	-- [markdown] shell: sudo npm i -g write-good (very wordy)
	-- b.diagnostics.write_good,
	-- spell check (built in)
	b.completion.spell,
}
-- format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end
end

local M = {}

M.setup = function()
	null_ls.setup({
		sources = sources,
		on_attach = on_attach,
	})
end

return M
