-- vim.pack.add({
-- 	{ src = "https://github.com/ellisonleao/gruvbox.nvim" },
-- })

-- Apearance
vim.opt.number = true;
vim.opt.relativenumber = true;
vim.opt.wrap = true;
vim.opt.autoindent = true;

-- require("gruvbox").setup({
--   terminal_colors = true, -- add neovim terminal colors
--   undercurl = true,
--   underline = true,
--   bold = true,
--   italic = {
--     strings = true,
--     emphasis = true,
--     comments = true,
--     operators = false,
--     folds = true,
--   },
--   strikethrough = true,
--   invert_selection = false,
--   invert_signs = false,
--   invert_tabline = false,
--   inverse = true, -- invert background for search, diffs, statuslines and errors
--   contrast = "hard", -- can be "hard", "soft" or empty string
--   palette_overrides = {},
--   overrides = {},
--   dim_inactive = false,
--   transparent_mode = false,
-- })
-- vim.cmd([[colorscheme gruvbox]])

-- Tab Control
vim.opt.smarttab = true;
vim.opt.tabstop = 4;
vim.opt.softtabstop = 4;
vim.opt.shiftwidth = 4;

