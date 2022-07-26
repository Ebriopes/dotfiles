" Author: Ebriopes
" Github: https://github.com/ebriopes
" License: GPLv3

let s:current_path = expand('<sfile>:p:h')

let s:list_files = [
      \'commands',
      \'mapping',
      \'plugins',
      \]

for s:item in s:list_files
  exec 'source ' . s:current_path . '/' . s:item . '.vim'
endfor

source $HOME/.config/nvim/plug-config/rnvimr.vim
