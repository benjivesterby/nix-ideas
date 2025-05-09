local utils = require("core.utils")

return {
	{
		"neovim/nvim-lspconfig",
		event = "BufRead",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		keys = {
			{ "H", function() vim.diagnostic.open_float { border = "rounded" } end, desc = "Show diagnostics" },
			{ "<C-k>", vim.lsp.buf.signature_help, desc = "Interactive signature help" },
			{ "<space>n", vim.lsp.buf.rename, desc = "Interactive rename" },
			{ "<space>F", vim.lsp.buf.format, desc = "Format code with LSP" },
			{
				"<space>d",
				function() vim.diagnostic.jump { count = 1, float = { border = "rounded" } } end,
				desc = "Jump to next diagnostic",
			},
		},
		config = function()
			require("mason").setup { ui = { border = "rounded" } }
			require("mason-lspconfig").setup {
				ensure_installed = {},
				automatic_installation = false,
			}

			vim.lsp.enable {
				-- Lua
				"lua_ls",

				-- Python
				"ruff",
				"pyright",

				-- JavaScript/TypeScript
				"vtsls",

				-- Fish
				"fish_lsp",

				-- Nix
				"nil_ls",
				"nixd",

				-- QML
				"qmlls",
			}

			vim.lsp.config("*", {
				on_attach = function(_, bufnr) vim.lsp.document_color.enable(true, bufnr, { style = "virtual" }) end,
			})
		end,
	},

	{
		"rachartier/tiny-code-action.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "LspAttach",
		keys = {
			{
				"<space>a",
				function() require("tiny-code-action").code_action {} end,
				desc = "Code actions",
			},
		},
		opts = {
			backend = "delta",
			picker = "snacks",
			backend_opts = {
				delta = {
					args = {
						"--features=catppuccin",
					},
				},
			},
		},
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		dependencies = {
			"justinsgithub/wezterm-types",
			"Bilal2453/luvit-meta",
		},
		opts = {
			library = {
				"snacks.nvim",
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "wezterm-types", mods = { "wezterm" } },
				{ path = "~/.local/share/lua", mods = { "palette" } },
			},
		},
	},

	-- Rust-specific utilities and LSP configurations
	{
		"mrcjkb/rustaceanvim",
		ft = "rust",
		init = function()
			vim.g.rustaceanvim = {
				tools = { inlay_hints = { auto = false } },
				server = {
					standalone = false,
					on_attach = function(_, bufnr)
						utils.map {
							{
								"K",
								function() vim.cmd(":RustLsp hover range<CR>") end,
								desc = "Hover information",
								buffer = bufnr,
								mode = "x",
							},
						}
					end,
				},
			}
		end,
	},

	-- Tests
	{
		"nvim-neotest/neotest",
		dependencies = { "nvim-neotest/nvim-nio" },
		cmd = "Neotest",
		keys = function()
			utils.map {
				{ "<space>t", group = "tests", icon = "" },
			}
			return {
				{ "<space>tt", function() require("neotest").run.run() end, desc = "Run closest test" },
				{
					"<space>tf",
					function() require("neotest").run.run(vim.fn.expand("%")) end,
					desc = "Run all tests in file",
				},
				{ "<space>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
				{ "<space>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle output" },
			}
		end,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("neotest").setup {
				adapters = {
					require("rustaceanvim.neotest"),
				},
			}
		end,
	},

	-- Database explorer
	{
		"xemptuous/sqlua.nvim",
		cmd = "SQLua",
		opts = {},
	},

	{
		"jmbuhr/otter.nvim",
		opts = {},
	},
}
