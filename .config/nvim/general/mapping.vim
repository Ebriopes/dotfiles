"let g:mapleader = ' ' " Space key like leader

" Add a second leader key, that can be useful to latam layout
nmap , <leader>

nnoremap <leader>q :q<CR>" Quit current window
nnoremap <leader>w :w<CR>" Save current file
nnoremap <leader>R :so $MYVIMRC<CR>" Save current file
nnoremap <leader>e :e $MYVIMRC<CR>" Open init vim file

" Copy selection to system clipboard
vnoremap <leader>y "+y
nnoremap <leader>y "+y
inoremap <C-c> <ESC>"+ya

" Paste from system clipboard
vnoremap <leader>p "+p
nnoremap <leader>p "+p
" P uppercase
nnoremap <leader>P "+P
vnoremap <leader>P "+P
inoremap <C-v> <ESC>"+pa

" Cut selection to system clipboard
vnoremap <leader>d "+d
nnoremap <leader>d "+d

" Buffers
nnoremap <leader>l :bnext<CR>
nnoremap <leader>j :bprevious<CR>
nnoremap <leader><Tab> :buffer<Space><Tab>

" Buffers
nnoremap <leader>bq :bd<CR>

" add empty line before/after the current line
"nnoremap <leader><Enter> o<ESC>
"nnoremap <leader><Enter> O<ESC>
