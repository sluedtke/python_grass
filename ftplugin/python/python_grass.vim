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
" set the termial emulator that is used .. should be user variable late on
let g:gpython_term = "konsole"
let g:gpython_interpreter = "ipython"

" building the start up string for the terminal
" * workdir expands to the dir of the current file I think 
" * -e is quite crucial (executes command after startup)
"
if g:gpython_term == "konsole"
  let g:gpython_term_cmd = "konsole --workdir '" . expand("%:p:h") . "' -e"
endif

" tempdir for tmuxconf - no good for windows
let g:gpython_tmpdir = "/tmp"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"====================	FUNCTIONS	===========================
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Function that send a command to the listening tmux session
"
function Send_cmd_gpython(cmd)
  " format the command 
  let str = substitute(a:cmd, "'", "'\\\\''", "g")
  " parse it to tmux via paste-buffer  (tmux internal command)
  let scmd = "tmux -L gpython_vim set-buffer '" . str . "\<C-M>' && tmux -L gpython_vim paste-buffer -t foo.0"
  " call the command via system
  call system(scmd)
  return 1
endfunction

" Starting an external shell with a tmux session and start the interpreter
"
function Start_gpython(python_interpreter)
  " build the tmux conf file that is parsed at startup
  let cnflines = ['set-option -g prefix C-a',
        \ 'unbind-key C-b',
        \ 'bind-key C-a send-prefix',
        \ 'set-window-option -g mode-keys vi',
        \ 'set -g status off',
        \ 'set -g default-terminal "screen-256color"',
        \ "set -g terminal-overrides 'xterm*:smcup@:rmcup@'" ]
  call writefile(cnflines, g:gpython_tmpdir . "/tmux.conf")
  let tmuxcnf = '-f "' . g:gpython_tmpdir . "/tmux.conf" . '"'

  " start the terminal emulator and within that, the tmux session that is used for communication
  let opencmd = printf("%s tmux -L gpython_vim -2 %s new-session -s foo &", g:gpython_term_cmd, tmuxcnf)
  call system(opencmd)
  
  " without the additional time, the python interpreter does not start
  sleep 1200m

  " after opening the tmux session, we start the interpreter
  call Send_cmd_gpython(a:python_interpreter)

  return 1
endfunction

" Send current line to python.
"
function Send_line_gpython()
  let line = getline(".")
  call Send_cmd_gpython(line)
  return 1
endfunction

" Send current selection to python 
"
function Send_selection_to_gpython()
  " single selected line or parts of a line (most likely the latter, otherwise the
  " columns do not make sense ??
  if line("'<") == line("'>")
    let i = col("'<") - 1
    let j = col("'>") - i
    let l = getline(".")
    let  line = strpart(l, i, j)
    call Send_cmd_gpython(line)
  else

    " multiple selected lines
    let lines = getline("'<", "'>")

    " remove empty items because that result in extra line breaks
    let filtered_lines = filter(copy(lines), 'v:val !~ "^$"')

    " join lines by carriage return
    let selection = join(add(filtered_lines, ''), "\n")

    " call function to send cmd
    call Send_cmd_gpython(selection)
  endif
  " return 1
endfunction

"==========================================================================
"
noremap <F2> :call Start_gpython(g:gpython_interpreter)<CR>
noremap <LocalLeader>ro :call Start_gpython()<CR>
noremap <LocalLeader>l :call Send_line_gpython()<CR>
vnoremap <silent><buffer><LocalLeader>l <Esc> :call Send_selection_to_gpython()<CR>
vnoremap <silent><buffer><LocalLeader>ss <Esc> :call Send_selection_to_gpython()<CR>

"==========================================================================
"==========================================================================
