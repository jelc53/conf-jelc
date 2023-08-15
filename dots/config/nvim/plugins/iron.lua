local present, iron = pcall(require, "iron")
if not present then
	return
end

iron.core.setup({
	config = {
		-- repl_open_cmd = "topleft vertical split",
		repl_open_cmd = "belowright 10 split",
		should_map_plug = false,
		repl_definition = {
			python = require("iron.fts.python").ipython,
			r = {
				command = "radian",
				format = require("iron.fts.common").bracketed_paste,
			},
		},
	},
	keymaps = {
		send_motion = "<leader><leader>",
		visual_send = "<leader><leader>",
	},
})

vim.api.nvim_set_keymap("n", "L", ":IronRepl <CR>", {
	noremap = true,
	silent = false,
})
