-- move whole line up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- center scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- chmod
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true })

-- rihgt to left text
vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("set rl")
end)
vim.keymap.set("n", "<leader>nrl", function()
	vim.cmd("set norl")
end)
