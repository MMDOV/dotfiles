return {
	{
		"neovim/nvim-lspconfig",
		---@class PluginLspOpts
		opts = {
			---@type lspconfig.options
			servers = {
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								useLibraryCodeForTypes = true,
								typeCheckingMode = "standard",
								diagnosticMode = "workspace",
								autoSearchPath = true,
								inlayHints = {
									callArgumentNames = true,
								},
								extraPaths = {},
							},
							python = {},
						},
					},
				},
				rust_analyzer = {},
				bashls = {},
				hyprls = {},
				ts_ls = {},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"bash",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"tsx",
				"typescript",
				"vim",
				"yaml",
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"stylua",
				"ruff",
			},
		},
	},
}
