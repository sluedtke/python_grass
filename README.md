## PYTHON-GRASS PLUGIN FOR GVIM

This file-type plugin is inspired by the work of the
[vim-r-plugin]((https://github.com/vim-scripts/Vim-R-plugin.git). To be totally honest, I
just adapted the part Jakson Alves de Aquino ( __thank you very much__ ) send me and included
functions that create parameters required to start a GRASS GIS session - so it is 95% copy
and paste. The plugin uses the screen-plugin as well and has been tested on my machine
only (Ubuntu 12.04). It requires __python__ and vim compiled with python support.

## Key mappings

The plugin uses the key mappings from the
[vim-r-plugin]((https://github.com/vim-scripts/Vim-R-plugin.git) because they are burned
into my brain by now. Additional features will stick to their parents as well.
The mappings are:

Starting the interpreter ([i]python) in _normal mode_

* `<F2>` for python 2.*
* `<F3>` for python 3.*

By default, python or python3 ist used and started inside the external window. 
This might be changed to __ipython__ using:

python-2.*
```vim
let g:gpython2_interpreter = "ipython"
```
or  python-3.*
```vim
let g:gpython3_interpreter = "ipython3"
```

Send current line under the cursor in _normal mode_

* `<LocalLeader>`l 

Send selection (as well as parts of a line) in _visual mode_

* `<LocalLeader>`l
* `<LocalLeader>`ss

## Future stuff 
The plugin should be integrated in
[vimcmdline](https://github.com/jalvesaq/vimcmdline.git) because it does actually the same
things (not that robust though) but with GVIM.

