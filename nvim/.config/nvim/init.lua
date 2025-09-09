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

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		{
			"nvim-telescope/telescope.nvim",
		},
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = { lua = { "stylua" }, typst = { "typstyle" } },
			},
		},
		{
			"nvim-lualine/lualine.nvim",
			event = "VeryLazy",
			config = function()
				require("lualine").setup()
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "master",
			lazy = false,
			build = ":TSUpdate",
		},
		{
			"mason-org/mason.nvim",
			cmd = { "Mason", "MasonInstall", "MasonUpdate" },
			opts = {},
		},
		{
			"neovim/nvim-lspconfig",
			event = "User FilePost",
		},
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				{
					-- snippet plugin
					"L3MON4D3/LuaSnip",
					dependencies = "rafamadriz/friendly-snippets",
					opts = { history = true, updateevents = "TextChanged,TextChangedI" },
				},
				-- autopairing of (){}[] etc
				{
					"windwp/nvim-autopairs",
					opts = {
						fast_wrap = {},
						disable_filetype = { "TelescopePrompt", "vim" },
					},
					config = function(_, opts)
						require("nvim-autopairs").setup(opts)

						-- setup cmp for autopairs
						local cmp_autopairs = require("nvim-autopairs.completion.cmp")
						require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
					end,
				},

				-- cmp sources plugins
				{
					"saadparwaiz1/cmp_luasnip",
					"hrsh7th/cmp-nvim-lua",
					"hrsh7th/cmp-nvim-lsp",
					"hrsh7th/cmp-buffer",
					"https://codeberg.org/FelipeLema/cmp-async-path.git",
				},
			},
			{
				"chomosuke/typst-preview.nvim",
				lazy = false,
				opts = {},
			},
			{
				"jayli/vim-easycomplete",
			},
			{
				"nvim-tree/nvim-tree.lua",
				cmd = { "NvimTreeToggle", "NvimTreeFocus" },
			},
			{
				"lewis6991/gitsigns.nvim",
				event = "User FilePost",
			},
			{
				"ellisonleao/gruvbox.nvim",
				priority = 1000,
				config = true,
			},
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "default" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

vim.opt.termguicolors = true

vim.o.number = true
vim.o.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0

require("gruvbox").setup({
	terminal_colors = true,
	contrast = "hard",
})

vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

require("lspconfig")["tinymist"].setup({
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onType",
	},
})

require("conform").setup({
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
