"=============================================================================
" FILE: autoload/niconicomment.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('niconicomment')
let s:Random = s:V.import('Random')

function! niconicomment#go(...) abort
  " 可変長引数の処理〜
  "     <- いや直訳コメントとか書く必要ないでしょwwww
  let winwidth = get(a:, 1, winwidth(0))
  let filetype = get(a:, 2, &filetype)
  let is_loop = get(a:, 3, 0)
  let millsec = get(a:, 4, 30)
  " 一行コメントのコメント文字
  let scomment = s:get_oneline_scomment(filetype)
  if scomment is# ''
    " 一行コメントない．帰れ!!!!
    echom 'Not supported filetype'
    return
  endif
  " コメントがある行をゲット...!
  let cls = s:get_comment_lines(scomment)
  let max_len = max(map(copy(cls), 'v:val.comment_len'))
  " 少なくとも最初だけは実行する．ループであっても何か入力されたら終わってくれる
  let is_first = 1
  let rt = reltime()
  while is_loop || is_first
    try
      " コメント流していく...!
      for i in range(max_len * 2)  " <- ちょっと雑すぎてウケるwwwwwww もっとしっかりしろよ...!wwwwwwwwwww
        " 入力確認! getchar(1) だと入力が消費されず，このあと押されたとみなされるので便利
        if getchar(1)
          return
        endif
        for cl in cls
          " コメント表示〜
          call cl.show_line(i)
        endfor
        redraw
        let ds = float2nr(millsec - str2float(reltimestr(reltime(rt))) * 1000.0)
        if ds > 0
          " 安らかに眠れ.....
          execute 'sleep' printf('%sm', ds)
        endif
        let rt = reltime()
      endfor
    finally
      " ちゃんとバッファを戻します!
      for cl in cls
        call cl.reset()
      endfor
    endtry
    let is_first = 0
  endwhile
endfunction

" comment line
let s:cline = {
\   'lnum': -1,
\   'orig_line': '',
\   'solToComment': '',
\   'commentToEol': ''
\ }

function! s:make_cline(lnum, scomment) abort
  let r = deepcopy(s:cline)
  let r.lnum = a:lnum
  let r.orig_line = getline(a:lnum)
  let [r.solToComment, r.commentToEol] = s:parse_comment(r.orig_line, a:scomment)
  let r.commentToEol = repeat(' ', s:Random.range(0, 50)) . r.commentToEol
  let r.comment_len = strdisplaywidth(r.commentToEol)
  return r
endfunction

function! s:cline.reset() abort
  call setline(self.lnum, self.orig_line)
endfunction

function! s:cline.make_line(i, ...) abort
  let winwidth = get(a:, 1, winwidth(0) - 5)
  let rest = winwidth - strdisplaywidth(self.solToComment)
  let spaces = repeat(' ', rest - a:i)
  let parse_pattern = a:i < rest ? printf('.*\%%<%sv', a:i) : printf('\%%%sv.*', a:i - rest)
  let comment = matchstr(self.commentToEol, parse_pattern)
  let l = self.solToComment . (comment =~# '\m^\s*$' ? '' : spaces . comment)
  return l
endfunction

function! s:cline.show_line(...) abort
  return setline(self.lnum, call(self.make_line, a:000, self))
endfunction

function! s:get_comment_lines(scomment) abort
  let ffunc = printf('s:is_comment(v:val, "%s")', escape(a:scomment, '"'))
  let mfunc = printf('s:make_cline(v:val, "%s")', escape(a:scomment, '"'))
  return map(filter(range(line('w0'), line('w$')), ffunc), mfunc)
endfunction

function! s:comment_pattern(scomment) abort
  return printf('\v(^.{-}%s)(.*$)', a:scomment)
endfunction

function! s:is_comment(lnum, scomment) abort
  return match(getline(a:lnum), s:comment_pattern(a:scomment)) isnot# -1
endfunction

function! s:parse_comment(line, scomment) abort
  let matches = matchlist(a:line, s:comment_pattern(a:scomment))
  let solToComment = get(matches, 1, '')
  let commentToEol = get(matches, 2, '')
  return [solToComment, commentToEol]
endfunction

function! s:get_oneline_scomment(filetype)
  return get(s:scomments, a:filetype, '')
endfunction

" License: NEW BSD LICENSE
" Licence URL: https://github.com/tyru/caw.vim/blob/bb24d3bb06bd1c193f2b7b161775989b833e0c8e/doc/caw.txt#L7
" CODE: https://github.com/tyru/caw.vim/blob/bb24d3bb06bd1c193f2b7b161775989b833e0c8e/autoload/caw.vim#L262
let s:scomments = {
\   'aap': '#',
\   'abc': '%',
\   'acedb': '//',
\   'actionscript': '//',
\   'ada': '--',
\   'ahdl': '--',
\   'ahk': ';',
\   'amiga': ';',
\   'aml': '/*',
\   'ampl': '#',
\   'apache': '#',
\   'apachestyle': '#',
\   'applescript': '--',
\   'asciidoc': '//',
\   'asm': ';',
\   'asm68k': ';',
\   'asn': '--',
\   'aspvbs': "'",
\   'asterisk': ';',
\   'asy': '//',
\   'atlas': 'C',
\   'autohotkey': ';',
\   'autoit': ';',
\   'ave': "'",
\   'awk': '#',
\   'basic': "'",
\   'bbx': '%',
\   'bc': '#',
\   'bib': '%',
\   'bindzone': ';',
\   'bst': '%',
\   'btm': '::',
\   'c': '//',
\   'calibre': '//',
\   'caos': '*',
\   'catalog': '--',
\   'cfg': '#',
\   'cg': '//',
\   'ch': '//',
\   'cl': '#',
\   'clean': '//',
\   'clipper': '//',
\   'clojure': ';',
\   'cmake': '#',
\   'conf': '#',
\   'config': '#',
\   'conkyrc': '#',
\   'cpp': '//',
\   'crontab': '#',
\   'cs': '//',
\   'csp': '--',
\   'cterm': '*',
\   'cucumber': '#',
\   'cvs': 'CVS:',
\   'd': '//',
\   'dakota': '#',
\   'dcl': '$!',
\   'debcontrol': '#',
\   'debsources': '#',
\   'def': ';',
\   'desktop': '#',
\   'dhcpd': '#',
\   'diff': '#',
\   'dns': ';',
\   'dosbatch': 'REM',
\   'dosini': ';',
\   'dot': '//',
\   'dracula': ';',
\   'dsl': ';',
\   'dylan': '//',
\   'ebuild': '#',
\   'ecd': '#',
\   'eclass': '#',
\   'eiffel': '--',
\   'elf': "'",
\   'elmfilt': '#',
\   'erlang': '%',
\   'expect': '#',
\   'exports': '#',
\   'factor': '!',
\   'fgl': '#',
\   'focexec': '-*',
\   'form': '*',
\   'foxpro': '*',
\   'fstab': '#',
\   'fvwm': '#',
\   'fx': '//',
\   'gams': '*',
\   'gdb': '#',
\   'gdmo': '--',
\   'gentoo-conf-d': '#',
\   'gentoo-env-d': '#',
\   'gentoo-init-d': '#',
\   'gentoo-make-conf': '#',
\   'gentoo-package-keywords': '#',
\   'gentoo-package-mask': '#',
\   'gentoo-package-use': '#',
\   'gitcommit': '#',
\   'gitconfig': '#',
\   'gitrebase': '#',
\   'gnuplot': '#',
\   'go': '//',
\   'groovy': '//',
\   'gtkrc': '#',
\   'h': '//',
\   'haskell': '--',
\   'haml': '-#',
\   'hb': '#',
\   'hercules': '//',
\   'hog': '#',
\   'hostsaccess': '#',
\   'htmlcheetah': '##',
\   'htmlos': '#',
\   'ia64': '#',
\   'icon': '#',
\   'idl': '//',
\   'idlang': ';',
\   'inform': '!',
\   'inittab': '#',
\   'ishd': '//',
\   'iss': ';',
\   'ist': '%',
\   'java': '//',
\   'javacc': '//',
\   'javascript': '//',
\   'jess': ';',
\   'jproperties': '#',
\   'julia': '#',
\   'kix': ';',
\   'kscript': '//',
\   'lace': '--',
\   'ldif': '#',
\   'lilo': '#',
\   'lilypond': '%',
\   'lisp': ';',
\   'llvm': ';',
\   'lout': '#',
\   'lprolog': '%',
\   'lscript': "'",
\   'lss': '#',
\   'lua': '--',
\   'lynx': '#',
\   'lytex': '%',
\   'mail': '>',
\   'mako': '##',
\   'man': '."',
\   'map': '%',
\   'maple': '#',
\   'masm': ';',
\   'master': '$',
\   'matlab': '%',
\   'mel': '//',
\   'mib': '--',
\   'mkd': '>',
\   'model': '$',
\   'monk': ';',
\   'mush': '#',
\   'named': '//',
\   'nasm': ';',
\   'nastran': '$',
\   'natural': '/*',
\   'ncf': ';',
\   'newlisp': ';',
\   'nroff': '\"',
\   'nsis': '#',
\   'ntp': '#',
\   'objc': '//',
\   'objcpp': '//',
\   'objj': '//',
\   'occam': '--',
\   'omnimark': ';',
\   'openroad': '//',
\   'opl': 'REM',
\   'ora': '#',
\   'ox': '//',
\   'patran': '$',
\   'pcap': '#',
\   'pccts': '//',
\   'pdf': '%',
\   'perl': '#',
\   'pfmain': '#',
\   'php': '//',
\   'pic': ';',
\   'pike': '//',
\   'pilrc': '//',
\   'pine': '#',
\   'plm': '//',
\   'plsql': '--',
\   'po': '#',
\   'postscr': '%',
\   'pov': '//',
\   'povini': ';',
\   'ppd': '%',
\   'ppwiz': '%',
\   'processing': '//',
\   'prolog': '%',
\   'ps1': '#',
\   'psf': '#',
\   'ptcap': '#',
\   'python': '#',
\   'r': '#',
\   'radiance': '#',
\   'ratpoison': '#',
\   'rc': '//',
\   'rebol': ';',
\   'registry': ';',
\   'remind': '#',
\   'resolv': '#',
\   'rgb': '!',
\   'rib': '#',
\   'robots': '#',
\   'ruby': '#',
\   'sa': '--',
\   'samba': '#',
\   'sass': '//',
\   'sather': '--',
\   'scala': '//',
\   'scheme': ';',
\   'scilab': '//',
\   'scsh': ';',
\   'sed': '#',
\   'sh': '#',
\   'sicad': '*',
\   'simula': '%',
\   'sinda': '$',
\   'skill': ';',
\   'slang': '%',
\   'slice': '//',
\   'slrnrc': '%',
\   'sm': '#',
\   'smith': ';',
\   'snnsnet': '#',
\   'snnspat': '#',
\   'snnsres': '#',
\   'snobol4': '*',
\   'spec': '#',
\   'specman': '//',
\   'spectre': '//',
\   'spice': '$',
\   'sql': '--',
\   'sqlforms': '--',
\   'sqlj': '--',
\   'sqr': '!',
\   'squid': '#',
\   'st': '"',
\   'stp': '--',
\   'systemverilog': '//',
\   'tads': '//',
\   'tags': ';',
\   'tak': '$',
\   'tasm': ';',
\   'tcl': '#',
\   'texinfo': '@c',
\   'texmf': '%',
\   'tf': ';',
\   'tidy': '#',
\   'tli': '#',
\   'tmux': '#',
\   'trasys': '$',
\   'tsalt': '//',
\   'tsscl': '#',
\   'tssgm': "comment = '",
\   'txt2tags': '%',
\   'uc': '//',
\   'uil': '!',
\   'vb': "'",
\   'velocity': '##',
\   'verilog': '//',
\   'verilog_systemverilog': '//',
\   'vgrindefs': '#',
\   'vhdl': '--',
\   'vim': '"',
\   'vimperator': '"',
\   'virata': '%',
\   'vrml': '#',
\   'vsejcl': '/*',
\   'webmacro': '##',
\   'wget': '#',
\   'winbatch': ';',
\   'wml': '#',
\   'wvdial': ';',
\   'xdefaults': '!',
\   'xkb': '//',
\   'xmath': '#',
\   'xpm2': '!',
\   'z8a': ';',
\   'zsh': '#'
\ }


let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
