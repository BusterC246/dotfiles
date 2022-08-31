local Plug = vim.fn['plug#'];
vim.g.gruvbox_contrast_dark = 'hard';

-- Plugins
vim.call('plug#begin', '~/.config/nvim/plugged');
	Plug 'gruvbox-community/gruvbox';
	Plug 'vim-airline/vim-airline';
	Plug 'tpope/vim-surround';
vim.call('plug#end');

-- Apearance
vim.cmd("colorscheme gruvbox");
vim.o.termguicolors = true;
vim.o.number = true;
vim.o.relativenumber = true;
vim.opt.wrap = true;
vim.opt.autoindent = true;
vim.opt.ttyfast = true;

-- Tab Control
vim.opt.smarttab = true;
vim.opt.tabstop = 4;
vim.opt.softtabstop = 4;
vim.opt.shiftwidth = 4;

-- Key Remaps
vim.keymap.set({"n", "v"}, "t", "j");
vim.keymap.set({"n", "v"}, "T", "J");
vim.keymap.set({"n", "v"}, "n", "k");
vim.keymap.set({"n", "v"}, "N", "K");
vim.keymap.set({"n", "v"}, "s", "l");
vim.keymap.set({"n", "v"}, "S", "L");
vim.keymap.set({"n", "v"}, "l", "n");
vim.keymap.set({"n", "v"}, "L", "N");
vim.keymap.set({"n", "v"}, "j", "t");
vim.keymap.set({"n", "v"}, "J", "T");
vim.keymap.set({"n", "v"}, "k", "s");
vim.keymap.set({"n", "v"}, "K", "S");
vim.keymap.set({"n", "v"}, "-", "$");
vim.keymap.set({"n", "v"}, "_", "^");