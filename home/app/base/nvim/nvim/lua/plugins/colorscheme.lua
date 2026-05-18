local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.pack.add({
		gh("alexvzyl/nordic.nvim"),
	})
	vim.cmd.colorscheme("nordic")
end

return M
