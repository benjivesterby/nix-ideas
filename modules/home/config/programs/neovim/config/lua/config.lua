---------- Settings
-- Search
vim.o.ignorecase = true
vim.o.inccommand = "nosplit"
vim.o.smartcase = true

-- Edit
vim.g.mapleader = ","
vim.o.colorcolumn = "120"
vim.o.concealcursor = "nc"
vim.o.textwidth = 120
vim.o.virtualedit = "block"
vim.o.undofile = true

-- GUI
vim.o.background = "dark"
vim.o.cursorline = true
vim.o.guicursor = "a:blinkwait300-blinkoff300-blinkon300"
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumblend = 0
vim.o.scrolloff = 4
vim.o.shortmess = "c"
vim.o.termguicolors = true
vim.o.winblend = 0
vim.o.wrap = false
vim.opt.fillchars = {
	eob = " ",
	fold = " ",
	foldopen = "󰅀",
	foldclose = "󰅂",
	foldsep = " ",
	diff = "╳",
}
vim.opt.listchars = {
	tab = "→ ",
	nbsp = "␣",
	trail = "~",
	precedes = "«",
	extends = "»",
}

-- Indentation
vim.o.autoindent = true
vim.o.expandtab = false
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true

-- Mouse
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.mousemoveevent = true
vim.o.mousescroll = "ver:2,hor:2"
vim.o.smoothscroll = true

-- Neovide configuration
vim.g.neovide_floating_blur_amount_x = 1.5
vim.g.neovide_floating_blur_amount_y = 1.5
vim.g.neovide_scroll_animation_length = 0.13
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5
vim.g.neovide_unlink_border_highlights = true
vim.g.neovide_refresh_rate = 60
vim.g.neovide_cursor_smooth_blink = true

if vim.g.neovide == true then
	local function change_neovide_scale_factor(delta)
		if delta then
			vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
		else
			vim.g.neovide_scale_factor = 1
		end
		vim.cmd.redraw()
	end

	vim.keymap.set("n", "<C-+>", function() change_neovide_scale_factor(0.1) end)
	vim.keymap.set("n", "<C-->", function() change_neovide_scale_factor(-0.1) end)
	vim.keymap.set("n", "<C-0>", function() change_neovide_scale_factor(nil) end)
end

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", numhl = "" })

vim.fn.sign_define("GitSignsAdd", { text = "▋", texthl = "GitSignsAdd", numhl = "" })
vim.fn.sign_define("GitSignsChange", { text = "▋", texthl = "GitSignsChange", numhl = "" })
vim.fn.sign_define("GitSignsDelete", { text = "▋", texthl = "GitSignsDelete", numhl = "" })

require("core.utils").make_sidebar("*.txt", function() return vim.bo.buftype == "help" end)

-- Full line error highlights
local utils = require("plugins.ui.utils")
local lines_ns = vim.api.nvim_create_namespace("diag_lines")

local function clear_highlights(buf)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_clear_namespace(buf, lines_ns, 0, -1)
	end
end

local function update_highlights(buf, diagnostics)
	clear_highlights(buf)

	for _, diagnostic in ipairs(diagnostics) do
		local lnum = diagnostic.lnum
		-- I have no idea why this check is necessary, but somehow sometimes the diagnostic is out of range
		if lnum >= 0 and lnum < vim.api.nvim_buf_line_count(buf) then
			vim.api.nvim_buf_set_extmark(buf, lines_ns, diagnostic.lnum, 0, {
				line_hl_group = utils.diags_lines()[diagnostic.severity],
				priority = 14 - diagnostic.severity,
			})
		end
	end
end

vim.diagnostic.handlers.diagnostic_lines = {
	show = function(_, bufnr, diagnostics, _) update_highlights(bufnr, diagnostics) end,
	hide = function(_, bufnr) clear_highlights(bufnr) end,
}

require("lazy").setup("plugins", {
	ui = { border = "rounded" },
	dev = {
		fallback = true,
		path = "~/projects",
	},
})
