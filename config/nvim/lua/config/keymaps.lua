-- move whole line up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- center scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- chmod
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = false })

-- lsp restart
vim.keymap.set("n", "<leader>ct", "<cmd>LspRestart<CR>", { silent = false })

-- right to left text (NEOVIM add bidi support and my life is yours)
vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("set rl")
end)
vim.keymap.set("n", "<leader>nrl", function()
	vim.cmd("set norl")
end)

-- I kept pressing the wrong keybind for line find so here we are
vim.keymap.set("n", "<leader>/", "/", { noremap = true, silent = false })
