"=============================================================================
" FILE: plugin/niconicomment.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_niconicomment
endif
if exists('g:loaded_niconicomment')
  finish
endif
let g:loaded_niconicomment = 1
let s:save_cpo = &cpo
set cpo&vim

let g:niconicomment_auto = get(g:, 'niconicomment_auto', 0)
let g:niconicomment_loop = get(g:, 'niconicomment_loop', 0)

command! NiconiComment call niconicomment#go()

if g:niconicomment_auto
  augroup plugin-niconicomment
    autocmd!
    autocmd CursorHold * call niconicomment#go(winwidth(0), &filetype, g:niconicomment_loop)
  augroup END
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
