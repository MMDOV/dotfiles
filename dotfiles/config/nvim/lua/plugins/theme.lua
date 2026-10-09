local fallback = {
	bg = "#1a1b26",
	bg_alt = "#16161e",
	surface = "#292e42",
	border = "#3b4261",
	fg = "#c0caf5",
	fg_dim = "#a9b1d6",
	accent = "#7aa2f7",
	accent_alt = "#7dcfff",
	selection = "#33467c",
}

local ok, look = pcall(require, "config.look")
if not ok then
	look = fallback
end

return {
	"folke/tokyonight.nvim",
	opts = {
		transparent = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
		on_colors = function(colors)
			colors.bg = look.bg
			colors.bg_dark = look.bg_alt
			colors.bg_dark1 = look.bg_alt
			colors.bg_highlight = look.surface
			colors.bg_popup = look.bg_alt
			colors.bg_search = look.selection
			colors.bg_sidebar = look.bg
			colors.bg_statusline = look.bg
			colors.bg_visual = look.selection
			colors.border = look.border
			colors.blue = look.accent
			colors.cyan = look.accent_alt
			colors.fg = look.fg
			colors.fg_dark = look.fg_dim
			colors.green = look.ok or colors.green
			colors.orange = look.warn or colors.orange
			colors.red = look.danger or colors.red
		end,
		on_highlights = function(_, colors)
			return {
				CursorLine = { bg = look.surface },
				Visual = { bg = look.selection },
				FloatBorder = { fg = colors.border },
			}
		end,
	},
	init = function()
		vim.cmd.colorscheme("tokyonight-night")

		vim.cmd.hi("Comment gui=none")
		vim.cmd.hi("Normal guibg=none")
		vim.cmd.hi("NormalNC guibg=none")
		vim.cmd.hi("NormalSB guibg=none")
		vim.cmd.hi("CursorLine guibg=" .. look.surface)
		vim.cmd.hi("Visual guibg=" .. look.selection)
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
