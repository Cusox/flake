return {
	on_attach = function(client)
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end
	end,
}
