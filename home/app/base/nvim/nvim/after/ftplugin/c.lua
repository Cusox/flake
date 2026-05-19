local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	gh("J-Cowsert/classlayout.nvim"),
})
require("classlayout").setup()
