return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/personal/brain/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/personal/brain/**.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-treesitter/nvim-treesitter",
		"ibhagwan/fzf-lua",
	},

	keys = {
		{ "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Obsidian: Open Today" },
		{ "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Obsidian: Search Files" },
		{ "<leader>of", "<cmd>FzfLua live_grep cwd=~/personal/brain<cr>", desc = "Obsidian: Find Content" },
		{ "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Obsidian: Insert Template" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian: Show Backlinks" },

		{
			"<leader>og",
			function()
				vim.fn.jobstart(vim.fn.expand("~") .. "/personal/scripts/sync_brain.sh", {
					on_exit = function(_, code)
						if code == 0 then
							vim.notify("Brain Synced", vim.log.levels.INFO)
						else
							vim.notify("Sync Failed", vim.log.levels.ERROR)
						end
					end,
				})
			end,
			desc = "Obsidian: Git Sync",
		},

		{
			"<leader>op",
			function()
				vim.ui.input({ prompt = "New Project Name: " }, function(input)
					if not input or input == "" then
						return
					end
					-- The plugin will now use 'input' exactly as the filename
					vim.cmd("ObsidianNew projects/" .. input)
				end)
			end,
			desc = "Obsidian: New Project",
		},

		{
			"<leader>ow",
			function()
				vim.ui.input({ prompt = "New Wiki Entry: " }, function(input)
					if not input or input == "" then
						return
					end
					vim.cmd("ObsidianNew wiki/" .. input)
				end)
			end,
			desc = "Obsidian: New Wiki",
		},

		{
			"<leader>om",
			function()
				vim.ui.input({ prompt = "Meeting Topic: " }, function(input)
					if not input or input == "" then
						return
					end
					local date = os.date("%Y-%m-%d")
					vim.cmd("ObsidianNew meetings/" .. date .. "-" .. input)
				end)
			end,
			desc = "Obsidian: New Meeting",
		},
	},

	opts = {
		picker = {
			name = "fzf-lua",
		},

		-- FIX: Force the filename to match the input title exactly
		note_id_func = function(title)
			return title or tostring(os.time())
		end,

		workspaces = {
			{
				name = "brain",
				path = "~/personal/brain",
			},
		},

		notes_subdir = "daily",

		daily_notes = {
			folder = "daily",
			date_format = "%Y-%m-%d",
			template = nil,
		},

		templates = {
			subdir = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			substitutions = {},
		},

		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},

		disable_frontmatter = true,

		ui = {
			enable = true,
		},

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
