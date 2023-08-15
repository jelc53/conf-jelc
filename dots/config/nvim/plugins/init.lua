-- see: https://github.com/wbthomason/packer.nvim
return {
	-- overrides
	["folke/which-key.nvim"] = {
		disable = false,
	},
	["neovim/nvim-lspconfig"] = {
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.plugins.lspconfig")
		end,
	},
	["williamboman/mason.nvim"] = {
		override_options = {
			-- NOTE: when adding to this list, update
			-- custom.plugins.lspconfig
			-- custom.plugins.null-ls
			ensure_installed = {
				-- lua stuff
				"lua-language-server",
				"stylua",

				-- python
				"black",
				"pyright",

				-- rust
				"rust-analyzer",

				-- JSON, javascript, typescript, etc
				"prettierd",

				-- markdown
				"write-good",
			},
		},
	},
	-- Custom autopairs
	-- ["windwp/nvim-autopairs"] = {
	-- 	config = function()
	-- 		require("plugins.configs.others").autopairs()
	-- 		local aps = require("nvim-autopairs")
	-- 		local Rule = require("nvim-autopairs.rule")
	-- 		aps.add_rules({
	-- 			Rule("$$", "$$", "markdown"),
	-- 		})
	-- 	end,
	-- },
	-- custom plugins
	["Vigemus/iron.nvim"] = {
		keys = "L",
		cmd = "IronRepl",
		config = function()
			require("custom.plugins.iron")
		end,
		ft = { "python", "r", "lua", "julia" },
	},
	["iamcco/markdown-preview.nvim"] = {
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
		ft = "markdown",
		config = function()
			require("custom.plugins.markdown-preview")
		end,
	},
	["preservim/vim-markdown"] = {
		ft = "markdown",
		config = function()
			require("custom.plugins.vim-markdown")
		end,
	},
	["lervag/vimtex"] = {
		config = function()
			require("custom.plugins.vimtex")
		end,
	},
	["elkowar/yuck.vim"] = {
		ft = "yuck",
	},
	["jose-elias-alvarez/null-ls.nvim"] = {
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.null-ls").setup()
		end,
	},
	["dhruvasagar/vim-table-mode"] = {
		config = function()
			require("custom.plugins.vim-table-mode")
		end,
	},
	["jbyuki/venn.nvim"] = {
		event = "VimEnter",
		keys = { { "n", "<leader>v" } },
		config = function()
			require("custom.plugins.venn").setup()
		end,
	},
	["derekelkins/agda-vim"] = {},
	["eigenfoo/stan-vim"] = {},
	["JuliaEditorSupport/julia-vim"] = {
		config = function()
			vim.g.latex_to_unicode_auto = 1
		end,
	},
}
