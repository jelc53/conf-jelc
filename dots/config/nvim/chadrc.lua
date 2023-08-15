-- override default_config.lua values here
local M = {}

local function termcodes(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

M.mappings = {
	user = {
		n = {
			["|"] = { "<cmd> vsplit <CR>", "vertical split" },
			["<leader>s"] = { "<cmd> ASToggle <CR>", "toggle autosave" },
			["<leader>i"] = { "<cmd> lua print(vim.inspect(packer_plugins)) <CR>", "packer plugin table" },
		},
		t = {
			["<Esc>"] = { termcodes("<C-\\><C-N>"), "   escape terminal mode" },
			["<C-p>"] = { termcodes("<C-\\><C-N>"), "   escape terminal mode" },
		},
	},
	telescope = {
		n = {
			["<C-p>"] = { "<cmd> Telescope git_files <CR>", "search git" },
			-- TODO(danj): how do you use file browser?
			["<C-b>"] = { "<cmd> Telescope file_browser <CR>", "search files" },
			-- NOTE: can't use spaces in arguments, even if they are lists
			["<C-f>"] = {
				'<cmd> Telescope find_files search_dirs=[".","/data"] <CR>',
				"search all files",
			},
			["<C-s>"] = {
				'<cmd> Telescope live_grep search_dirs=[".","/data"] <CR>',
				"grep all files",
			},
		},
	},
	lspconfig = {
		n = {
			["<leader>d"] = {
				function()
					vim.diagnostic.open_float()
				end,
				"floating diagnostic",
			},
		},
	},
}

M.plugins = require("custom.plugins")

M.ui = {
	theme = "gatekeeper",
	theme_toggle = { "gatekeeper", "everforest" },
}

return M
