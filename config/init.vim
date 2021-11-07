call plug#begin()
  Plug 'gruvbox-community/gruvbox'
  Plug 'vim-airline/vim-airline'
  Plug 'tpope/vim-surround'
  Plug 'jiangmiao/auto-pairs'
call plug#end()

let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
set termguicolors

set number relativenumber

" dvorak remap
noremap h h
noremap t j
noremap n k
noremap s l
noremap l n
noremap L N

" easy access to beginning and end of line
noremap - $
noremap _ ^
