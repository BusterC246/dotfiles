-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ---------------------------
-- Core options
-- ---------------------------

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0

vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.spell = true
vim.opt.spelllang = { "en" }
vim.opt.spellsuggest = "best,5"

vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"

-- ---------------------------
-- Plugins
-- ---------------------------

require("lazy").setup({
	spec = {
		-- ---------------------------
		-- Colorscheme
		-- ---------------------------
		{
			"ellisonleao/gruvbox.nvim",
			lazy = false,
			priority = 1000,
			opts = {
				terminal_colors = true,
				contrast = "hard",
			},
			config = function(_, opts)
				require("gruvbox").setup(opts)
				vim.o.background = "dark"
				vim.cmd.colorscheme("gruvbox")
			end,
		},

		-- ---------------------------
		-- Statusline
		-- ---------------------------
		{
			"nvim-lualine/lualine.nvim",
			event = "VeryLazy",
			opts = {},
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},

		-- ---------------------------
		-- Git
		-- ---------------------------
		{ "lewis6991/gitsigns.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

		-- ---------------------------
		-- Formatting
		-- ---------------------------
		{
			"stevearc/conform.nvim",
			event = { "BufReadPre", "BufNewFile" },
			cmd = "ConformInfo",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					rust = { "rustfmt" },
					typst = { "typstyle" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			},
		},

		-- ---------------------------
		-- Treesitter
		-- ---------------------------
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			build = ":TSUpdate",
			config = function()
				local nvim_ts = require("nvim-treesitter")
				local parser_configs = require("nvim-treesitter.parsers")

				local installing = {}

				vim.api.nvim_create_autocmd("FileType", {
					group = vim.api.nvim_create_augroup("TS_AutoInstallAndStart", { clear = true }),
					callback = function(ev)
						local ft = ev.match
						local lang = vim.treesitter.language.get_lang(ft)
						if not lang or lang == "" then
							return
						end

						-- If parser is available, start treesitter highlighting.
						do
							local ok = vim.treesitter.language.add(lang) -- returns (bool, err)
							if ok then
								pcall(vim.treesitter.start, ev.buf, lang)
								installing[lang] = nil
								return
							end
						end

						-- If this language isn't in nvim-treesitter's known parser table,
						-- don't try to install it automatically.
						if parser_configs[lang] == nil then
							return
						end

						-- Avoid duplicate installs
						if installing[lang] then
							return
						end
						installing[lang] = true

						vim.notify(("Installing treesitter parser: %s"):format(lang), vim.log.levels.INFO)

						-- Install parser + queries (async; no-op if already installed)
						nvim_ts.install({ lang })

						-- Retry start (best-effort) until parser becomes loadable
						local tries = 40
						local function retry()
							if not vim.api.nvim_buf_is_valid(ev.buf) then
								installing[lang] = nil
								return
							end

							local ok = vim.treesitter.language.add(lang)
							if ok then
								pcall(vim.treesitter.start, ev.buf, lang)
								installing[lang] = nil
								return
							end

							tries = tries - 1
							if tries > 0 then
								vim.defer_fn(retry, 250)
							else
								installing[lang] = nil
							end
						end
						retry()

						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.wo.foldmethod = "expr"

						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end,
				})
			end,
		},

		-- ---------------------------
		-- LSP
		-- ---------------------------
		{
			"mason-org/mason-lspconfig.nvim",
			lazy = false,
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"neovim/nvim-lspconfig",
			},
			opts = {
				ensure_installed = {
					"bashls",
					"clangd",
					"hyprls",
					"lua_ls",
					"pyright",
					"rust_analyzer",
					"tinymist",
				},
				automatic_enable = false,
			},
			config = function(_, opts)
				require("mason-lspconfig").setup(opts)

				vim.lsp.config("tinymist", {
					settings = {
						formatterMode = "typstyle",
					},
				})

				for _, server in ipairs(opts.ensure_installed or {}) do
					vim.lsp.enable(server)
				end
			end,
		},

		-- ---------------------------
		-- Completion
		-- ---------------------------
		{
			"saghen/blink.cmp",
			version = "1.*",
			event = "InsertEnter",
			dependencies = {
				"rafamadriz/friendly-snippets",
				{
					"L3MON4D3/LuaSnip",
					version = "v2.*",
					opts = {
						update_events = { "TextChanged", "TextChangedI" },
					},
				},

				{
					"windwp/nvim-autopairs",
					event = "InsertEnter",
					opts = {
						check_ts = true,
						enable_check_bracket_line = false,
						ignored_next_char = "[%w%.]",
						disable_filetype = { "TelescopePrompt", "vim" },
					},
				},
			},
			opts = {
				keymap = { preset = "super-tab" },
				appearance = { nerd_font_variant = "mono" },
				completion = { documentation = { auto_show = false } },
				sources = { default = { "lsp", "path", "snippets", "buffer" } },
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" },
		},

		-- ---------------------------
		-- Surround
		-- ---------------------------
		{ "kylechui/nvim-surround", version = "^4.0.0", event = "VeryLazy", opts = {} },

		-- ---------------------------
		-- Telescope
		-- ---------------------------
		{
			"nvim-telescope/telescope.nvim",
			version = "*",
			cmd = "Telescope",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
			opts = {},
		},

		-- ---------------------------
		-- Typst
		-- ---------------------------
		{
			"chomosuke/typst-preview.nvim",
			ft = "typst",
			version = "1.*",
			opts = {},
		},
	},

	install = { colorscheme = { "gruvbox" } },
	checker = { enabled = true },
})

-- ---------------------------
-- Diagnostics
-- ---------------------------

vim.diagnostic.config({ virtual_text = false })

vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = vim.api.nvim_create_augroup("DiagFloat", { clear = true }),
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

-- ---------------------------
-- Keymaps
-- ---------------------------

-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Telescope find files" })

vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Telescope live grep" })

vim.keymap.set("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Telescope buffers" })

vim.keymap.set("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Telescope help tags" })

-- Format key
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format (Conform)" })

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gr", vim.lsp.buf.references, "References")
		map("n", "K", vim.lsp.buf.hover, "Hover")
		map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
	end,
})
