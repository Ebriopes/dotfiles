" Fix files with prettier, and then ESLint.
let g:ale_fixers = ['prettier', 'eslint']
"let g:ale_fixers ={javascript: ['prettier', 'eslint']}
" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1
" Enable completion where available.
let g:ale_completion_enabled = 1
let g:ale_floating_preview = 1
let g:ale_hover_cursor = 1
"let g:ale_list_window_size = 5
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']
