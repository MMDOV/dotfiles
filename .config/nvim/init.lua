vim.diagnostic.config({ virtual_text = false })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.mouse = "a"

vim.opt.showmode = false

vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ~/.local/bin/tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>st", function()
	vim.cmd("TodoTelescope")
end)

vim.keymap.set("n", "<leader>jq", function()
	vim.cmd("%!jq .")
end)
vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("set rl")
end)
vim.keymap.set("n", "<leader>nrl", function()
	vim.cmd("set norl")
end)

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
-- Start and attach to Jupyter server
map("n", "<leader>js", "<Cmd>JupyniumStartAndAttachToServer<CR>", opts)

-- Execute selected cells (Normal + Visual mode)
map("n", "<leader>je", "<Cmd>JupyniumExecuteSelectedCells<CR>", opts)
map("v", "<leader>je", "<Cmd>JupyniumExecuteSelectedCells<CR>", opts)

-- Execute all cells
map("n", "<leader>ja", "<Cmd>JupyniumExecuteAllCells<CR>", opts)

-- Start syncing between .ipynb ↔ .ju.py
map("n", "<leader>jy", "<Cmd>JupyniumStartSync<CR>", opts)

-- Show output window (if hidden)
map("n", "<leader>jo", "<Cmd>JupyniumShowCellOutput<CR>", opts)

-- Restart Jupyter server
map("n", "<leader>jr", "<Cmd>JupyniumRestartJupyterServer<CR>", opts)

-- Check Jupyter kernel status
map("n", "<leader>jk", "<Cmd>JupyniumKernelStatus<CR>", opts)

vim.keymap.set("n", "<leader>mi", function()
	local prefix = os.getenv("CONDA_PREFIX") or os.getenv("VIRTUAL_ENV")
	local env_name = nil
	if prefix then
		env_name = prefix:match(".*/envs/([^/]+)$") or "base"
		vim.cmd("MoltenInit " .. env_name)
	else
		vim.cmd("MoltenInit python3")
	end
end, { noremap = true, silent = true, desc = "MoltenInit with current env" })
map("n", "<leader>ml", "<cmd>MoltenEvaluateLine<CR>", { noremap = true, silent = true })
map("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>", { noremap = true, silent = true })
map("n", "<leader>mo", "<cmd>MoltenShowOutput<CR>", { noremap = true, silent = true })
map("n", "<leader>ms", "<cmd>MoltenSave<CR>", { noremap = true, silent = true })
map("n", "<leader>md", "<cmd>MoltenLoad<CR>", { noremap = true, silent = true })
map("n", "<leader>rr", "<cmd>MoltenReevaluateCell<CR><cmd>MoltenNext<CR>", { noremap = true, silent = true })
map("n", "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", { noremap = true, silent = true })
map("n", "<leader>mn", "<cmd>MoltenNext<CR>", { noremap = true, silent = true })

map("n", "<leader>ts", "<cmd>Speedtyper<CR>", { noremap = true, silent = true })

map("n", "<leader>u", ":UndotreeToggle<CR>", { noremap = true, silent = true })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]] To check the current status of your plugins, run :Lazy You can press `?` in this menu for help. Use `:q` to close the window To update plugins you can run :Lazy update
require("lazy").setup({
	{
		"mbbill/undotree",
		config = function()
			vim.g.undotree_WindowLayout = 2
			vim.g.undotree_SetFocusWhenToggle = 1
		end,
	},

	{ "glacambre/firenvim", build = ":call firenvim#install(0)" },
	{
		"mfussenegger/nvim-dap",
		event = "User BaseFile",
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets" },

		-- use a release tag to download pre-built binaries
		version = "1.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "default" },

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = { documentation = { auto_show = false } },

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	"brenoprata10/nvim-highlight-colors",
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		"ellisonleao/glow.nvim",
		config = true,
		cmd = "Glow",
	},
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {},
	},
	{
		"kiyoon/jupynium.nvim",
		build = "pip install jupyter",
		config = function()
			vim.g.jupynium_auto_start_server = true
			vim.g.jupynium_format_output = true
			vim.g.jupynium_disable_default_keybindings = true
		end,
	},
	{
		"NStefan002/speedtyper.nvim",
		branch = "v2",
		lazy = false,
	},
	{
		"3rd/image.nvim",
		enabled = not vim.g.started_by_firenvim,
		opts = {},
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		config = function()
			require("tiny-inline-diagnostic").setup({
				options = {
					-- Enable diagnostic message on all lines.
					multilines = true,
				},
			})
		end,
	},
	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},
	{
		"theprimeagen/harpoon",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = true,
		keys = {
			{ "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = "mark file with harpoon" },
			{ "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "go to next harpoon mark" },
			{ "<leader>hp", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "go to previous harpoon mark" },
			{ "<leader>hm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "show harpoon marks" },
		},
	},
	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				build = "make",

				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				gopls = {},
				pyright = {},
				ts_ls = {},
				bashls = {},
				hyprls = {},
				ruff = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		--		config = function()
		--			-- See `:help cmp`
		--			local cmp = require("cmp")
		--			local luasnip = require("luasnip")
		--			luasnip.config.setup({})
		--
		--			cmp.setup({
		--				snippet = {
		--					expand = function(args)
		--						luasnip.lsp_expand(args.body)
		--					end,
		--				},
		--				completion = { completeopt = "menu,menuone,noinsert" },
		--
		--				-- For an understanding of why these mappings were
		--				-- chosen, you will need to read `:help ins-completion`
		--				--
		--				-- No, but seriously. Please read `:help ins-completion`, it is really good!
		--				mapping = cmp.mapping.preset.insert({
		--					-- Select the [n]ext item
		--					["<C-n>"] = cmp.mapping.select_next_item(),
		--					-- Select the [p]revious item
		--					["<C-p>"] = cmp.mapping.select_prev_item(),
		--
		--					-- Scroll the documentation window [b]ack / [f]orward
		--					["<C-b>"] = cmp.mapping.scroll_docs(-4),
		--					["<C-f>"] = cmp.mapping.scroll_docs(4),
		--
		--					-- Accept ([y]es) the completion.
		--					--  This will auto-import if your LSP supports it.
		--					--  This will expand snippets if the LSP sent a snippet.
		--					["<C-y>"] = cmp.mapping.confirm({ select = true }),
		--
		--					-- If you prefer more traditional completion keymaps,
		--					-- you can uncomment the following lines
		--					--['<CR>'] = cmp.mapping.confirm { select = true },
		--					--['<Tab>'] = cmp.mapping.select_next_item(),
		--					--['<S-Tab>'] = cmp.mapping.select_prev_item(),
		--
		--					-- Manually trigger a completion from nvim-cmp.
		--					--  Generally you don't need this, because nvim-cmp will display
		--					--  completions whenever it has completion options available.
		--					["<C-Space>"] = cmp.mapping.complete({}),
		--
		--					-- Think of <c-l> as moving to the right of your snippet expansion.
		--					--  So if you have a snippet that's like:
		--					--  function $name($args)
		--					--    $body
		--					--  end
		--					--
		--					-- <c-l> will move you to the right of each of the expansion locations.
		--					-- <c-h> is similar, except moving you backwards.
		--					["<C-l>"] = cmp.mapping(function()
		--						if luasnip.expand_or_locally_jumpable() then
		--							luasnip.expand_or_jump()
		--						end
		--					end, { "i", "s" }),
		--					["<C-h>"] = cmp.mapping(function()
		--						if luasnip.locally_jumpable(-1) then
		--							luasnip.jump(-1)
		--						end
		--					end, { "i", "s" }),
		--
		--					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
		--					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
		--				}),
		--				sources = {
		--					{
		--						name = "lazydev",
		--						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
		--						group_index = 0,
		--					},
		--					{ name = "nvim_lsp" },
		--					{ name = "luasnip" },
		--					{ name = "path" },
		--				},
		--			})
		--		end,
	},

	{ -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		"folke/tokyonight.nvim",
		transparent = true,
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			vim.cmd.colorscheme("tokyonight-night")

			-- You can configure highlights by doing something like:
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
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })

			require("mini.surround").setup()

			-- Simple and easy statusline.
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		opts = {
			ensure_installed = {
				"python",
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({ timeout = 2000 })
		end,
	},

	-- 4. Aerial for code outline
	{
		"stevearc/aerial.nvim",
		opts = {},
	},

	-- 5. TWcmd.vim
	"yssl/TWcmd.vim",

	-- 6. nvim-unception
	"samjwill/nvim-unception",

	-- 7. Mason-nvim-dap with custom handler
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim", "nvim-neotest/nvim-nio" },
		init = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "cppdbg" },
				automatic_installation = true,
				handlers = {
					function(config)
						require("mason-nvim-dap").default_setup(config)
					end,
					cppdbg = function(config)
						config.configurations = {
							{
								name = "launch with CLI args",
								type = "cppdbg",
								request = "launch",
								program = function()
									return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/bin/", "file")
								end,
								args = function()
									return { vim.fn.input("CLI arguments (optional): ", "", "file") }
								end,
								cwd = "${workspaceFolder}",
								runInTerminal = false,
								stopOnEntry = true,
							},
						}
						require("mason-nvim-dap").default_setup(config)
					end,
				},
			})
		end,
	},

	-- 8. LSP-zero
	{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },

	-- 9. Nerdy.nvim
	{
		"2kabhishek/nerdy.nvim",
		dependencies = { "stevearc/dressing.nvim", "nvim-telescope/telescope.nvim" },
		cmd = "Nerdy",
	},

	-- 10. Markdown-preview.nvim
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 0
		end,
		ft = { "markdown" },
	},

	-- 11. Preservim vim-markdown (if not already present)
	"preservim/vim-markdown",

	-- 12. Markdown.nvim with custom mapping
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		opts = { mappings = { link_follow = "<C-Enter>" } },
	},

	-- 13. Render-markdown.nvim (for beautifying markdown)
	{
		"MeanderingProgrammer/render-markdown.nvim",
		name = "render-markdown",
		main = "render-markdown",
		opts = {
			-- (your render-markdown options go here)
		},
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
	},

	-- 14. Various text objects (if not already added)
	"chrisgrieser/nvim-various-textobjs",

	-- 15. Screenkey.nvim (if not already added)
	"NStefan002/screenkey.nvim",

	-- 16. Molten-nvim from second block (forked version)
	--
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_auto_init_behavior = "init"
			vim.g.molten_enter_output_behavior = "open_and_enter"
			vim.g.molten_auto_image_popup = false
			vim.g.molten_auto_open_output = false
			vim.g.molten_output_crop_border = false
			vim.g.molten_output_virt_lines = true
			vim.g.molten_output_win_max_height = 50
			vim.g.molten_output_win_style = "minimal"
			vim.g.molten_output_win_hide_on_leave = false
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
			vim.g.molten_virt_text_max_lines = 10000
			vim.g.molten_cover_empty_lines = false
			vim.g.molten_copy_output = true
			vim.g.molten_output_show_exec_time = false
		end,
	},
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
require("lspconfig").ruff.setup({})
vim.opt.termguicolors = true
require("nvim-highlight-colors").setup({})
require("jupynium").setup({
	use_default_keybindings = false, -- disable all default keymaps
})
if not vim.g.started_by_firenvim then
	require("image").setup({
		backend = "kitty", -- kitty will provide the best experience, but you need a compatible terminal
		integrations = {}, -- do whatever you want with image.nvim's integrations
		max_width = 100, -- tweak to preference
		max_height = 12, -- ^
		max_height_window_percentage = math.huge, -- this is necessary for a good experience
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true,
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
	})
end
vim.api.nvim_create_autocmd({ "bufread", "bufnewfile" }, {
	pattern = { "*.ju.py" },
	callback = function()
		vim.bo.filetype = "python"
	end,
})

vim.g.magma_image_provider = "kitty"
if vim.g.started_by_firenvim then
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "www.kaggle.com_*.txt",
		command = "set filetype=markdown",
	})
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "kkb-production.jupyter-proxy.kaggle.net_*.txt",
		command = "set filetype=python",
	})
end
