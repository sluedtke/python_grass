""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"       Filename: python_grass.vim

"       Authors: Stefan Luedtke
"		 Jakson Alves de Aquino
"		 Jose Claudio Faria
"
"                Based on previous work by Johannes Ranke

"       Created: Tuesday 29 January 2013 18:42:51 CET

"       Last modified: Tuesday 24 September 2013 14:15:47 CEST

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""  	PURPOSE		""""""""""""""""""""""


"  This program is free software; you can redistribute it and/or modify
"  it under the terms of the GNU General Public License as published by
"  the Free Software Foundation; either version 2 of the License, or
"  (at your option) any later version.
"
"  This program is distributed in the hope that it will be useful,
"  but WITHOUT ANY WARRANTY; without even the implied warranty of
"  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"  GNU General Public License for more details.
"
"  A copy of the GNU General Public License is available at
"  http://www.r-project.org/Licenses/

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" ftplugin for PYTH files that use GRASS GIS
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"====================	FUNCTIONS	===========================
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" start a screen without GRASS and only ipyhton
"

let g:python_term = "konsole"
let g:rplugin_tmpdir = "/tmp"
function StartPYTH()
  
  let cnflines = ['set-option -g prefix C-a',
        \ 'unbind-key C-b',
        \ 'bind-key C-a send-prefix',
        \ 'set-window-option -g mode-keys vi',
        \ 'set -g status off',
        \ 'set -g default-terminal "screen-256color"',
        \ "set -g terminal-overrides 'xterm*:smcup@:rmcup@'" ]

  call writefile(cnflines, g:rplugin_tmpdir . "/tmux.conf")

  let tmuxcnf = '-f "' . g:rplugin_tmpdir . "/tmux.conf" . '"'

  let a:opencmd = printf("%s 'tmux -L vimr -2 %s new-session -s foo' &", g:python_term, tmuxcnf)
  echo a:opencmd

  " let a:opencmd = printf("%s 'tmux -L pythonvim new-session -s foo' &", g:python_term)
  call system(a:opencmd)
endfunction


function SendLs(cmd)
  " Create a custom tmux.conf
  let a:str = substitute(a:cmd, "'", "'\\\\''", "g")
  let a:scmd = "tmux -L vimr set-buffer '" . a:str . "\<C-M>' && tmux -L vimr paste-buffer -t foo.0'"
  let rlog = system(a:scmd)
  if v:shell_error
    let rlog = substitute(rlog, '\n', ' ', 'g')
    echo rlog
    " call RWarningMsg(rlog)
    " call ClearRInfo()
    return 0
  endif
  return 1
endfunction

nmap <F3> :call StartPYTH()<CR>
nmap <F4> :call SendLs("R")<CR>
"==========================================================================
"==========================================================================
