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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.termguicolors = true

vim.o.number = true
vim.o.relativenumber = true

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

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		-- Formatter
		{
			"stevearc/conform.nvim",
			event = { "BufReadPre", "BufNewFile" },
			cmd = "ConformInfo",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					typst = { "typstyle" },
					ocaml = { "ocamlformat" },
					bash = { "shfmt" },
					sh = { "shfmt" },
					rust = { "rustformat" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
					lsp_fallback = true,
				},
			},
		},

		-- Git
		{
			"lewis6991/gitsigns.nvim",
			event = { "BufReadPost", "BufNewFile" },
		},

		-- Treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			event = { "BufReadPost", "BufNewFile" },
			cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo", "TSUpdate" },
			build = ":TSUpdate",
			lazy = false,
		},

		-- Statusline
		{
			"nvim-lualine/lualine.nvim",
			event = "VeryLazy",
			config = function()
				require("lualine").setup()
			end,
		},

		-- Colorscheme
		{
			"ellisonleao/gruvbox.nvim",
			priority = 1000,
			config = true,
			opts = {
				terminal_colors = true,
				contrast = "hard",
			},
		},

		-- Linters/Formatters
		{
			"nvimtools/none-ls.nvim",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = { "nvimtools/none-ls-extras.nvim" },
		},

		-- LSP
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
		},
		{
			"mason-org/mason-lspconfig.nvim",
			lazy = false,
		},
		{
			"mason-org/mason.nvim",
			cmd = {
				"Mason",
				"MasonInstall",
				"MasonInstallAll",
				"MasonUninstall",
				"MasonUninstallAll",
				"MasonLog",
			},
		},

		-- Completions
		{
			"saghen/blink.cmp",
			version = "1.*",
			event = { "InsertEnter", "LspAttach" },
			dependencies = {
				"rafamadriz/friendly-snippets",
				{
					"L3MON4D3/LuaSnip",
					version = "v2.*",
					opts = { history = true, updateevents = "TextChanged,TextChangedI" },
				},
				{
					"windwp/nvim-autopairs",
					event = "InsertEnter",
					opts = {
						check_ts = true,
						ts_config = { lua = { "string" }, javascript = { "template_string" }, java = false },
						enable_check_bracket_line = false,
						ignored_next_char = "[%w%.]",
						fast_wrap = {},
						disable_filetype = { "MiniPick", "vim", "minifiles" },
					},
				},
			},

			opts = {
				keymap = { preset = "super-tab" },
				appearance = {
					nerd_font_variant = "mono",
				},

				completion = {
					documentation = {
						auto_show = false,
					},
					list = {
						selection = {
							preselect = true,
							auto_insert = true,
						},
					},
				},

				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},

				fuzzy = { implementation = "prefer_rust_with_warning" },
			},

			opts_extend = { "sources.default" },
		},
		{
			"kylechui/nvim-surround",
			version = "^4.0.0", -- Use for stability; omit to use `main` branch for the latest features
			event = "VeryLazy",
			-- Optional: See `:h nvim-surround.configuration` and `:h nvim-surround.setup` for details
			-- config = function()
			--     require("nvim-surround").setup({
			--         -- Put your configuration here
			--     })
			-- end
		},

		-- Files
		{
			"nvim-telescope/telescope.nvim",
		},
		{
			"chomosuke/typst-preview.nvim",
			lazy = false,
			opts = {},
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "gruvbox" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("hyprls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("ocamllsp")
vim.lsp.enable("pyright")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("tinymist")

vim.lsp.config["tinymist"] = {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	settings = {
		formatterMode = "typstyle",
	},
}

vim.diagnostic.config({
	virtual_text = false,
})
vim.o.updatetime = 250
vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
