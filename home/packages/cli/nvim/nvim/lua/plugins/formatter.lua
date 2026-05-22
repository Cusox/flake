local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.api.nvim_create_autocmd("BufReadPre", {
		once = true,
		callback = function()
			vim.pack.add({
				gh("stevearc/conform.nvim"),
			})

			vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

			require("conform").setup({
				log_level = vim.log.levels.INFO,
				formatters_by_ft = {
					sh = { "shfmt" },
					c = { "clang-format" },
					cmake = { "gersemi" },
					cpp = { "clang-format" },
					lua = { "stylua" },
					nix = { "nixfmt" },
					python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
					yaml = { "yamlfmt" },
				},
				formatters = {
					clang_format = {
						prepend_args = { "--style=file", "--fallback-style=LLVM" },
					},
					yamlfmt = {
						prepend_args = { "-formatter", "retain_line_breaks=true" },
					},
				},
				default_format_opts = {
					lsp_format = "fallback",
				},
				format_on_save = {
					timeout_ms = 500,
				},
			})

			vim.keymap.set("n", "<Leader>f", function()
				require("conform").format({ async = true })
			end, { desc = "Format buffer" })
		end,
	})
end

return M
