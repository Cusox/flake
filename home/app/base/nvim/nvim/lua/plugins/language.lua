local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Rust
	vim.pack.add({
		gh("mrcjkb/rustaceanvim"),
	})
	-- C/C++
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "c", "cpp" },
		callback = function()
			vim.pack.add({
				gh("J-Cowsert/classlayout.nvim"),
			})
			require("classlayout").setup()
		end,
	})
end

return M
