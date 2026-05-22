return {
	"folke/tokyonight.nvim",
	opts = {
		transparent = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
	},
	init = function()
		vim.cmd.colorscheme("tokyonight-night")

		vim.cmd.hi("Comment gui=none")
		vim.cmd.hi("Normal guibg=none")
		vim.cmd.hi("NormalNC guibg=none")
		vim.cmd.hi("NormalSB guibg=none")
		vim.cmd.hi("CursorLine guibg=#2A2F41")
		vim.cmd.hi("Visual guibg=#2A2F41")
		vim.cmd.hi("MiniStatuslineModeNormal guibg=none")
		vim.cmd.hi("StatusLine guibg=none")
		vim.cmd.hi("SignColumn guibg=none")
		vim.cmd.hi("TelescopeNormal guibg=none")
		vim.cmd.hi("TelescopePreviewNormal guibg=none")
		vim.cmd.hi("TelescopeResultsNormal guibg=none")
		vim.cmd.hi("TelescopePromptNormal guibg=none")
		vim.cmd.hi("Telescope guibg=none")
	end,
}
