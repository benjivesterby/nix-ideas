local utils = require("core.utils")

return {
	-- Plugins manager
	-- Defined and pinned here so that it's excluded from updates
	{
		"folke/lazy.nvim",
		pin = true,
	},
	-- Session management
	{
		"olimorris/persisted.nvim",
		lazy = false,
		init = function()
			vim.opt.sessionoptions = {
				"buffers",
				"curdir",
				"folds",
				"globals",
				"help",
				"tabpages",
				"winpos",
				"winsize",
			}
			local group = vim.api.nvim_create_augroup("PersistedHooks", {})
			local ignored_file_types = { "Trouble", "neo-tree", "noice" }

			utils.user_aucmd("PersistedSavePre", function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local file_type = vim.api.nvim_get_option_value("filetype", { buf = buf })
					if vim.tbl_contains(ignored_file_types, file_type) then
						vim.api.nvim_command("silent! bwipeout! " .. buf)
					end
				end
			end, { group = group })
		end,
		opts = {
			use_git_branch = true,
			autosave = true,
			autoload = false,
			follow_cwd = false,
		},
	},
	-- Startup time analyzer
	{
		"dstein64/vim-startuptime",
		lazy = false,
		enabled = false,
	},
	-- Floating terminal window
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		keys = {
			{
				"<C-h>",
				function() require("toggleterm").toggle(1, 0, "", "vertical") end,
				desc = "Toggle floating terminal",
				mode = { "n", "t" },
			},
			{
				"<C-f>",
				function() require("toggleterm").toggle(1, 0, "", "float") end,
				desc = "Toggle floating terminal",
				mode = { "n", "t" },
			},
			{
				"<C-S-g>",
				function() require("toggleterm").toggle(1, 0, "", "tab") end,
				desc = "Open floating terminal",
				mode = { "n", "t" },
			},
		},
		opts = {
			direction = "vertical",
			float_opts = { border = "rounded" },
			size = function() return vim.o.columns * 0.3 end,
			highlights = {
				Normal = { link = "Normal" },
				FloatBorder = { link = "TermFloatBorder" },
			},
			persist_mode = false,
			on_open = function(term)
				vim.wo[term.window].foldmethod = "manual"
				vim.wo[term.window].statuscolumn = ""
			end,
		},
	},
	-- Auto close buffers
	{
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = { retirementAgeMins = 10 },
	},
	{
		"glacambre/firenvim",
		lazy = not vim.g.started_by_firenvim,
		priority = 100,
		build = function() vim.fn["firenvim#install"](0) end,
		init = function()
			vim.g.firenvim_config = {
				localSettings = {
					[".*"] = {
						cmdline = "neovim",
						takeover = "never",
					},
				},
			}
		end,
	},
	-- Direnv sync
	{
		"direnv/direnv.vim",
		lazy = false,
	},
}
