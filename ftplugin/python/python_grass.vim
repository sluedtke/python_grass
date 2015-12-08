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
"====================	FUNCTIONS	===========================
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" start a screen without GRASS and only ipyhton
"
" set the termial emulator that is used .. should be user variable late on
let g:python_term = "konsole"

" building the start up string for the terminal
" * workdir expands to the dir of the current file I think 
" * -e is quite crucial (executes command after startup)
"
if g:python_term == "konsole"
  let g:rplugin_termcmd = "konsole --workdir '" . expand("%:p:h") . "' -e"
endif

" tempdir for tmuxconf - no good for windows
let g:rplugin_tmpdir = "/tmp"

function StartPYTH()
  " build the tmux conf file that is parsed at startup
  let cnflines = ['set-option -g prefix C-a',
        \ 'unbind-key C-b',
        \ 'bind-key C-a send-prefix',
        \ 'set-window-option -g mode-keys vi',
        \ 'set -g status off',
        \ 'set -g default-terminal "screen-256color"',
        \ "set -g terminal-overrides 'xterm*:smcup@:rmcup@'" ]
  call writefile(cnflines, g:rplugin_tmpdir . "/tmux.conf")
  let tmuxcnf = '-f "' . g:rplugin_tmpdir . "/tmux.conf" . '"'

  " start the terminal emulator and within that, the tmux session that is used for communication
  let opencmd = printf("%s tmux -L vimr -2 %s new-session -s foo &", g:rplugin_termcmd, tmuxcnf)
  call system(opencmd)
endfunction


function SendLs(cmd)
  " format the command 
  let a:str = substitute(a:cmd, "'", "'\\\\''", "g")
  " parse it to tmux via paste-buffer  (tmux internal command)
  let a:scmd = "tmux -L vimr set-buffer '" . a:str . "\<C-M>' && tmux -L vimr paste-buffer -t foo.0"
  " call the command via system
  call system(a:scmd)
endfunction

nmap <F3> :call StartPYTH()<CR>
nmap <F4> :call SendLs("ipython")<CR>
"==========================================================================
"==========================================================================
