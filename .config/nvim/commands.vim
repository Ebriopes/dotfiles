"set title " Show file name on terminal window, appears a sound like a bell!
set number " Set sidebar numbers for every row
set relativenumber " Activate relative numbers, count the amount of rows below and above the current
set mouse=a " Allow mouse integration (select text, move the cursor)

set nowrap " Don't cut the line if text is larger

set cursorline " Higlight the current line
set cursorcolumn " Higlight the current column, over complete window
set colorcolumn=120 " Show colum, max to 120 characters

" Identation to 2 spaces
set expandtab " Insert spaces instead of <Tab>s
set shiftround
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Wrapping
set breakindent
set breakindentopt=shift:2
set showbreak=\\\\\\ " You also can use ↳

set hidden " Allow shift buffers without save it

set ignorecase " Ignore uppercase in a search
set smartcase " Don't ignore uppercase if the searching word have uppercase letters

set spelllang=en,es " Spellcheck words using dictionaries in english & spanish
 
set termguicolors " Active colors in terminal
set background=dark " Background theme: light or dark

set gdefault " This removes the need to tack on g at the end of substitute commands.

set wildmenu "The wildmenu option makes setting an option, or opening new files via :e, a breeze with TAB expansion.
set wildmode=full
set wildchar=<Tab>

if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=filler,internal,algorithm:histogram,indent-heuristic
endif

filetype plugin on

colorscheme evening

" Everforest theme configuration
let g:everforest_background = 'soft'
let g:everforest_better_perfomance = 1
let g:everforest_enable_italic = 1
"let g:everforest_cursor = 'auto'
let g:everforest_transparent_background = 1
let g:everforest_sign_column_background = 'grey'
"let g:everforest_spell_foreground = 'colored'
"let g:everforest_ui_contrast = 'high'
let g:everforest_show_eob = 1
let g:everforest_diagnostic_text_highlight = 1
let g:everforest_diagnostic_line_highlight = 1
let g:everforest_diagnostic_virtual_text = 'colored'
"let g:everforest_current_word = 'italic'
"let g:everforest_disable_terminal_colors = 1
"let g:everforest_lightline_disable_bold = 1
"let g:everforest_colors_override = {'bg0': ['#202020', '234'], 'bg2': ['#282828', '235']}

silent! colorscheme everforest
