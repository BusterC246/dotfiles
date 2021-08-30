call plug#begin()
  Plug 'morhetz/gruvbox'
  Plug 'vim-airline/vim-airline'
  Plug 'dense-analysis/ale'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'jiangmiao/auto-pairs'
  call plug#end()

set number relativenumber
set termguicolors
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark

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
