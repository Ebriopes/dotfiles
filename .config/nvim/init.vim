" Author: Ebriopes
" Github: https://github.com/ebriopes
" License: GPLv3

" Compatibility with Vim
let g:is_nvim = has('nvim')
let g:is_vim8 = v:version >= 800 ? 1 : 0

" Reuse nvim's runtimepath and packpath in vim
if !g:is_nvim && g:is_vim8
  set runtimepath-=~/.vim
    \ runtimepath^=~/.local/share/nvim/site runtimepath^=~/.vim 
    \ runtimepath-=~/.vim/after
    \ runtimepath+=~/.local/share/nvim/site/after runtimepath+=~/.vim/after
  let &packpath = &runtimepath
endif     


let s:current_path = expand('<sfile>:p:h')
let s:list_files = [
      \'mapping',
      \'plugins',
      \'commands',
      \]

for s:item in s:list_files
  exec 'source ' . s:current_path . '/general/' . s:item . '.vim'
endfor

