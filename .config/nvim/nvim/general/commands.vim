"set title " Show file name on terminal window, appears a sound like a bell!
set number " Set sidebar numbers for every row
set relativenumber " Activate relative numbers, count the amount of rows below and above the current
set mouse=a " Allow mouse integration (select text, move the cursor)

set nowrap " Don't cut the line if text is larger

set cursorline " Higlight the current line
"set cursorcolumn " Higlight the current column, over complete window
"set colorcolumn=120 " Show colum, max to 120 characters
set guicursor=n:blinkwait500-blink350-blinkoff200,i-ci-ve:ver25-Cursor,r-cr-o:hor20

" Identation to 2 spaces
set expandtab " Insert spaces instead of <Tab>s
set shiftround
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Set Backspace configuration
"set backspace=2 " To work equal to the tabs
"set backspace=indent,eol,start
 
" Wrapping
set breakindent
set breakindentopt=shift:2
set showbreak="↳ " " You also can use ↳

set hidden " Allow shift buffers without save it

set ignorecase " Ignore uppercase in a search
set smartcase " Don't ignore uppercase if the searching word have uppercase letters

set spelllang=en,es " Spellcheck words using dictionaries in english & spanish
 
set background=dark " Background theme: light or dark

set gdefault " This removes the need to tack on g at the end of substitute commands.

set wildmenu "The wildmenu option makes setting an option, or opening new files via :e, a breeze with TAB expansion.
set wildmode=full
set wildchar=<Tab>

if has('termguicolors')
  set termguicolors " Active colors in terminal
end

if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=filler,internal,algorithm:histogram,indent-heuristic
endif

filetype plugin on

" Default theme is evening. 
colorscheme evening

"If you need changes the colorscheme, I recomend you go to
"./plugin/themes-config.vim
silent! colorscheme everforest
