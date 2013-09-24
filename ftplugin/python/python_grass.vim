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
"
" Skip empty lines 
"
function GoDown()
    let i = line(".") + 1
    call cursor(i, 1)
endfunction


" Send sources to PYTH
function PYTHSourceLines(lines, e)
    call writefile(a:lines, b:rsource)
    if a:e == "echo"
        if exists("g:vimrplugin_maxdeparse")
		let rcmd = 'execfile("' . b:rsource . '"), echo=TRUE, max.deparse=' . g:vimrplugin_maxdeparse . ''
        else
		let rcmd = 'execfile("' . b:rsource . '"), echo=TRUE'
        endif
    else
	    let rcmd = 'execfile("' . b:rsource . '")'
    endif
    let ok = SendCmdToPYTH(rcmd)
    return ok
endfunction


" Function to send commands
" return 0 on failure and 1 on success
function SendCmdToPYTH(cmd)
    " ^K clean from cursor to the right and ^U clean from cursor to the left
    let cmd = "\013" . "\025" . a:cmd

    if !exists("g:ScreenShellSend")
        echo "Did you already start the plugin?"
        return 0
    endif
    call g:ScreenShellSend(cmd)
    return 1
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" get  GISBASE from the source file
"
function EVAL_python(pattern)
" Get the arguments in python
python<<EOF
import vim 
import os 
import sys
temp = vim.eval("a:pattern")
temp=eval(temp)
vim.command("let temp= '%s'" % temp)
EOF
return(temp)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" get LOCATION_NAME, MAPSET and GISBASE from the source file
"
function GRASSBuildLocation(python_grass_pattlist)

	let python_grass_pattlist=a:python_grass_pattlist
	let temp=[]
	let index = 0

	while index < len(python_grass_pattlist)

		let PATTERN = python_grass_pattlist[index]

		"get line number first of each entry of the python_grass_pattlist
		let lnum= search(PATTERN)

		"get the string 
		let TempName=getline(lnum)

		"get all after the GRASSsep
		"first, the position 
		let PosNameSep=match(TempName, '=')
		let TempName = strpart(TempName, PosNameSep+1)

		let TempName=EVAL_python(TempName)

		"add the entry to the list
		call add(temp, TempName)
		
		let index = index + 1

	endwhile
	"put to list into a string
	let LOCATION = join(temp, '/')
	return LOCATION
endfunction

" Start GRASS 
"function StartGRASS(python_grass_pattlist)
function StartGRASS()
	
	"""""""""""""""""""""""""""""""""""""""
	" Set variables if not given in .vimrc
	if exists("g:python_grass_pattlist")
		let python_grass_pattlist=g:python_grass_pattlist
	else
		let python_grass_pattlist=["gisdbase=","location=","mapset="]
	endif
		
	if exists("g:python_grass_gui")
		let python_grass_gui=g:python_grass_gui
	else
		let python_grass_gui=0
	endif

	if exists("g:python_grass_import")
		let python_grass_import=g:python_grass_import
	else
		let python_grass_import=0
	endif
	"""""""""""""""""""""""""""""""""""""""

	
	"call the function to create a string that defines the LOCATION string that is
	"passed to the grass command
	let a:LOCATION=GRASSBuildLocation(python_grass_pattlist)
	" Change to buffer's directory before starting GRASS
	lcd %:p:h

	" start in text mode or with wxpython gui
	" check whether gui is running
	if has('gui_running')
		if python_grass_gui==1
			exec 'ScreenShell grass --wxpython ' . a:LOCATION
		else
			exec 'ScreenShell grass --text ' . a:LOCATION
		endif
	else
	" if not -text mode only
		exec 'ScreenShell grass --text ' . a:LOCATION
	endif

	" start ipython
	call g:ScreenShellSend('ipython')
	
	" send standard modules to import?
	if python_grass_import==1

		call g:ScreenShellSend('import os')
		call g:ScreenShellSend('import sys')

		call g:ScreenShellSend('import grass.script as grass')
		call g:ScreenShellSend('import grass.script.setup as gsetup')
	endif

	" Go back to original directory:
	lcd -
    echo
endfunction

" Start PYTH 
function StartPYTH()
	exec 'ScreenShell ipython '
    echon
endfunction


" Send selection to PYTH 
function SendSelectionToPYTH(e, m)
    echon
    if line("'<") == line("'>")
        let i = col("'<") - 1
        let j = col("'>") - i
        let l = getline("<")
        let line = strpart(l, i, j)
        let ok = SendCmdToPYTH(line)
        if ok && a:m =~ "down"
            call GoDown()
        endif
        return
    endif
    let lines = getline("'<", "'>")
    let ok = PYTHSourceLines(lines, a:e)
    if ok == 0
        return
    endif
    if a:m == "down"
        call GoDown()
    else
        normal! gv
    endif
endfunction

" Send current line to PYTH.
function SendLineToPYTH(godown)
    echon
    let line = getline(".")

    if line =~ "^@$"
        if a:godown =~ "down"
             call GoDown()
        endif
    return
    endif

    " let b:needsnewomnilist = 1
    let ok = SendCmdToPYTH(line)
    if ok
        if a:godown =~ "down"
            call GoDown()
        else
            if a:godown == "newline"
                normal! o
            endif
        endif
    endif
endfunction

" Quit PYTH
function PYTHQuit()
    if exists(':ScreenQuit')
        ScreenQuit
    endif
    echon
endfunction

" From changelog.vim, with bug fixed by "Si" ("i5ivem")
" Windows logins can include domain, e.g: 'DOMAIN\Username', need to remove
" the backslash from this as otherwise cause file path problems.
let g:pythplugin_userlogin = substitute(system('whoami'), "\\", "-", "")

if v:shell_error
    let g:pythplugin_userlogin = 'unknown'
else
    let newuline = stridx(g:pythplugin_userlogin, "\n")
    if newuline != -1
        let g:pythplugin_userlogin = strpart(g:pythplugin_userlogin, 0, newuline)
    endif
    unlet newuline
endif


" Make the file name of files to be sourced
let $VIMRPLUGIN_TMPDIR = "/tmp/python-plugin-".g:pythplugin_userlogin
if !isdirectory($VIMRPLUGIN_TMPDIR)
    call mkdir($VIMRPLUGIN_TMPDIR, "p", 0700)
endif

let b:bname = expand("%:t")
let b:bname = substitute(b:bname, " ", "",  "g")
if exists("*getpid") " getpid() was introduced in Vim 7.1.142
  let b:rsource = $VIMRPLUGIN_TMPDIR . "/PYTHsource" . getpid() . "_" . b:bname
else
  let b:randnbr = system("echo $RANDOM")
  let b:randnbr = substitute(b:randnbr, "\n", "", "")
  if strlen(b:randnbr) == 0
    let b:randnbr = "NoRandom"
  endif
  let b:rsource = $VIMRPLUGIN_TMPDIR . "/PYTHsource-" . b:randnbr . "-" . b:bname
  unlet b:randnbr
endif
unlet b:bname

"==========================================================================

" start a screen with GRASS and ipython
nmap <F2> :call StartGRASS()<CR>

" start a screen without GRASS and only ipyhton
nmap <F3> :call StartPYTH()<CR>

"send code
nmap <LocalLeader>l :call SendLineToPYTH("down")<CR>
vmap <LocalLeader>l <ESC> :call SendSelectionToPYTH("no", "down")<CR>
vmap <LocalLeader>ss <ESC> :call SendSelectionToPYTH("no", "down")<CR>
nmap <LocalLeader>rq :call PYTHQuit()<CR>

"==========================================================================
"==========================================================================
