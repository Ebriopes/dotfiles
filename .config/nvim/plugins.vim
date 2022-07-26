call plug#begin()

" Tree
"Plug 'nvim-neo-tree/neo-tree.nvim'
"Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'kevinhwang91/rnvimr'

" Commenter
Plug 'preservim/nerdcommenter'

" Pairing
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

call plug#end()

let g:plug_window = 'botright new'
