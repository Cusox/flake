local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.pack.add({
		gh("mrcjkb/rustaceanvim"),
	})
end

return M
