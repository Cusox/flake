local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	gh("MeanderingProgrammer/render-markdown.nvim"),
})

require("render-markdown").setup({
	quote = {
		repeat_linebreak = true,
	},
	win_options = {
		showbreak = {
			default = "",
			rendered = "  ",
		},
		breakindent = {
			default = false,
			rendered = true,
		},
		breakindentopt = {
			default = "",
			rendered = "",
		},
	},
	checkbox = {
		checked = {
			scope_highlight = "@markup.strikethrough",
		},
		custom = {
			todo = {
				rendered = "◯ ",
			},
		},
	},
	heading = {
		border = true,
		border_virtual = true,
	},
	indent = {
		enabled = true,
		skip_heading = true,
	},
})
