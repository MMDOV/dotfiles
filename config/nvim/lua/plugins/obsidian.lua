return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "brain",
				path = "~/personal/brain",
			},
		},

		-- DAILY NOTES CONFIG
		daily_notes = {
			folder = "daily",
			date_format = "%Y-%m-%d",
			template = nil,
		},

		-- COMPLETION (The Magic Part)
		-- This allows you to type "[[Steam" and it auto-completes "Steam Commands.md"
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},

		-- KEYMAPPINGS
		-- <cr> (Enter) follows the link under your cursor
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<cr>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
	},
}
