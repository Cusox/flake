local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		once = true,
		callback = function()
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
		end,
	})
end

return M
