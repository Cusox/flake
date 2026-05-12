local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Treesitter
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name, kind = ev.data.spec.name, ev.data.kind
			if name == "nvim-treesitter" and kind == "update" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
			end
		end,
	})

	vim.pack.add({
		{
			src = gh("nvim-treesitter/nvim-treesitter"),
			version = "main",
		},
	})

	local parsers = {
		"bash",
		"c",
		"cmake",
		"cpp",
		"css",
		"cuda",
		"diff",
		"dockerfile",
		"git_config",
		"git_rebase",
		"gitcommit",
		"gitignore",
		"go",
		"gomod",
		"gosum",
		"gotmpl",
		"html",
		"java",
		"javascript",
		"json",
		"latex",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"ninja",
		"regex",
		"rust",
		"scss",
		"toml",
		"xml",
		"yaml",
	}

	local parsers_installed = require("nvim-treesitter").get_installed()
	local filetypes = vim.iter(parsers):map(vim.treesitter.language.get_filetypes):flatten():fold({}, function(tbl, v)
		tbl[v] = vim.tbl_contains(parsers_installed, v)
		return tbl
	end)

	local ts_enable = function(buffer, lang)
		local ok, hl = pcall(vim.treesitter.query.get, lang, "highlights")
		if ok and hl then
			vim.treesitter.start(buffer, lang)
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		desc = "enable treesitter",
		callback = function(event)
			local ft = event.match
			local available = filetypes[ft]
			if available == nil then
				return
			end

			local lang = vim.treesitter.language.get_lang(ft)
			if available then
				ts_enable(event.buf, lang)
				return
			end

			require("nvim-treesitter").install(lang):await(function()
				filetypes[ft] = true
				ts_enable(event.buf, lang)
			end)
		end,
	})

	-- Treesitter Context
	vim.api.nvim_create_autocmd("BufReadPre", {
		once = true,
		callback = function()
			vim.pack.add({
				gh("nvim-treesitter/nvim-treesitter-context"),
			})
		end,
	})
end

return M
