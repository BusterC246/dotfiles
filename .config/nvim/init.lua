-- Apearance
vim.cmd("colorscheme ayu");
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
vim.keymap.set({"n", "v"}, "t", "j", { silent = true });
vim.keymap.set({"n", "v"}, "T", "J", { silent = true });
vim.keymap.set({"n", "v"}, "n", "k", { silent = true });
vim.keymap.set({"n", "v"}, "N", "K", { silent = true });
vim.keymap.set({"n", "v"}, "s", "l", { silent = true });
vim.keymap.set({"n", "v"}, "S", "L", { silent = true });
vim.keymap.set({"n", "v"}, "l", "n", { silent = true });
vim.keymap.set({"n", "v"}, "L", "N", { silent = true });
vim.keymap.set({"n", "v"}, "j", "t", { silent = true });
vim.keymap.set({"n", "v"}, "J", "T", { silent = true });
vim.keymap.set({"n", "v"}, "k", "s", { silent = true });
vim.keymap.set({"n", "v"}, "K", "S", { silent = true });
vim.keymap.set({"n", "v"}, "-", "$", { silent = true });
vim.keymap.set({"n", "v"}, "_", "^", { silent = true });
