vim.g.snacks_animate = false

vim.o.updatetime = 50

vim.g.have_nerd_font = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.hlsearch = false
vim.o.incsearch = true
vim.opt.isfname:append("@-@")
vim.o.colorcolumn = "80"
vim.o.breakindent = true
vim.o.ttimeoutlen = 10
