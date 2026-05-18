vim.g.mapleader = " "

vim.opt.breakindent = true
vim.opt.cmdheight = 0

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.clipboard = "unnamedplus"
if os.getenv("SSH_TTY") ~= nil then
	local osc52 = require("vim.ui.clipboard.osc52")

	local function paste()
		return {
			vim.fn.split(vim.fn.getreg(""), "\n"),
			vim.fn.getregtype(""),
		}
	end

	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = osc52.copy("+"),
			["*"] = osc52.copy("*"),
		},
		paste = {
			["+"] = paste,
			["*"] = paste,
		},
	}
end
