return {
	on_init = function(client, _)
		-- Turn off semantic tokens until they're more consistent
		client.server_capabilities.semanticTokensProvider = nil
	end,
	settings = {
		["nil"] = {
			formatting = {
				command = "nix fmt",
			},
		},
	},
}
