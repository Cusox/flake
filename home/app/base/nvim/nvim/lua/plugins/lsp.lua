local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
	})

	vim.lsp.enable("bashls")
	vim.lsp.enable("clangd")
	vim.lsp.enable("copilot")
	vim.lsp.enable("docker_compose_language_service")
	vim.lsp.enable("docker_language_server")
	vim.lsp.enable("gopls")
	vim.lsp.enable("harper_ls")
	vim.lsp.enable("jsonls")
	vim.lsp.enable("lua_ls")
	vim.lsp.enable("neocmake")
	vim.lsp.enable("nixd")
	vim.lsp.enable("ty")
end

return M
