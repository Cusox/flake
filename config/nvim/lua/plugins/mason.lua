local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.pack.add({
		gh("mason-org/mason.nvim"),
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("jay-babu/mason-nvim-dap.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})
	require("mason").setup({
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	})
	require("mason-lspconfig").setup()
	require("mason-nvim-dap").setup()

	local lsps = {
		"bashls",
		"clangd",
		"copilot",
		"docker_compose_language_service",
		"dockerls",
		"gopls",
		"harper_ls",
		"jsonls",
		"lua_ls",
		"neocmake",
		"ty",
	}

	local daps = {
		"codelldb",
	}

	local linters = {
		"shellcheck",
	}

	local formatters = {
		"shfmt",
		"clang-format",
		"gersemi",
		"ruff",
		"stylua",
		"yamlfmt",
	}

	local tools = {}
	vim.list_extend(tools, lsps)
	vim.list_extend(tools, daps)
	vim.list_extend(tools, linters)
	vim.list_extend(tools, formatters)
	require("mason-tool-installer").setup({
		ensure_installed = tools,
		auto_update = true,
	})
end

return M
