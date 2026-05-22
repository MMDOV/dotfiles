return {
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				sources = {
					explorer = {
						auto_close = true,
						layout = {
							{ preview = true },
							layout = {
								box = "horizontal",
								width = 0.999,
								height = 0.999,
								{
									box = "vertical",
									border = "rounded",
									title = "{source} {live} {flags}",
									title_pos = "center",
									{ win = "input", height = 1, border = "bottom" },
									{ win = "list", border = "none" },
								},
								{ win = "preview", border = "rounded", width = 0.7, title = "{preview}" },
							},
						},
					},
				},
			},
		},
	},
}
