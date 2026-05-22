return {
	"mbbill/undotree",
	config = function()
		vim.g.undotree_WindowLayout = 2
		vim.g.undotree_SetFocusWhenToggle = 1
		vim.api.nvim_set_keymap("n", "<leader>uu", ":UndotreeToggle<CR>", { noremap = true, silent = true })
	end,
}
