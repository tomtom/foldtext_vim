" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     https://github.com/tomtom
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2017-08-22
" @Revision:    4
" GetLatestVimScripts: 5552 0 :AutoInstall: foldtext.vim

if &cp || exists('g:loaded_foldtext')
    finish
endif
let g:loaded_foldtext = 1

command! -bar Foldtextreset call foldtext#Reset()

