local map = require("core.utils").map

return {
	{
		"zbirenbaum/copilot.lua",
		enabled = true,
		event = "VeryLazy",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<M-CR>",
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					next = "<M-Right>",
					prev = "<M-Left>",
					dismiss = "<C-:>",
				},
			},
			filetypes = {
				yaml = true,
				gitcommit = true,
				markdown = true,
			},
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		cmd = "CopilotChat",
		opts = {
			question_header = "##   User ",
			answer_header = "##   Copilot ",
			error_header = "##   Error ",
			separator = "―――――――",
			show_folds = false,
			context = "buffer",
			window = {
				layout = "vertical",
				width = 120,
				height = 0.8,
				relative = "editor",
				border = "rounded",
				zindex = 50,
			},
			prompts = {
				CommitStaged = {
					prompt = [[
Write commit message for the change with commitizen convention.
MAKE SURE the title has MAXIMUM 50 characters (INCLUDING the conventional commits prefix) and message is WRAPPED at 72 characters.
The message should only contain SUCCINT, terse bullet points starting with '-'.
You should strive to avoid being redundant across bulletpoints.
One feature should most times have only one bullet point.
When writing a bullet point about neovim plugins, make sure to mention the name of the plugin.
Wrap the whole message in code block with language gitcommit.
Once you're done with the bullet points, DO NOT write anything else.
Very important points to remember: be SUCCINT, make sure the title is under 50 characters, and that the bullet points are wrapped at 72 characters.
]],
					selection = function(source) return require("CopilotChat.select").gitdiff(source, true) end,
				},
			},
		},
		init = function()
			local function pick_with_selection(selection)
				return function()
					require("CopilotChat")
					local actions = require("CopilotChat.actions")
					actions.pick(actions.prompt_actions { selection = require("CopilotChat.select")[selection] })
				end
			end
			map({
				["<leader>c"] = {
					name = "copilot",
					c = { function() require("CopilotChat").toggle() end, "Toggle Copilot Chat" },
					b = { pick_with_selection("buffer"), "Actions on buffer" },
					a = { pick_with_selection("buffers"), "Actions on all buffers" },
					s = { pick_with_selection("visual"), "Actions on selection" },
				},
			}, { mode = { "n", "v", "x" } })
		end,
		config = function(opts)
			require("CopilotChat").setup(opts.opts) -- FIXME: upstream bug in lazy.nvim
			require("core.utils").make_sidebar(
				"copilot-chat",
				function() return vim.fn.bufname() == "copilot-chat" and vim.fn.win_gettype() ~= "popup" end
			)
		end,
	},
	{
		"supermaven-inc/supermaven-nvim",
		enabled = false, -- Bugged for now
		opts = {
			keymaps = {
				accept_suggestion = "<M-CR>",
				clear_suggestion = "<C-]>",
			},
		},
	},
	{
		"Exafunction/codeium.vim",
		enabled = false, -- Bugged for now
		event = "VeryLazy",
		config = function()
			vim.g.codeium_disable_bindings = 1
			map {
				["<M-CR>"] = { "call codeium#Accept()", "Accept suggestion", mode = "i" },
			}
		end,
	},
}
