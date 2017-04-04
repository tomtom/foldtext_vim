" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     https://github.com/tomtom
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2017-04-03
" @Revision:    10


let s:cmds = ['part', 'chapter', 'section', 'subsection', 'subsubsection', 'paragraph', 'subparagraph']


function! foldtext#ft#tex#GetRx() abort "{{{3
    return '\V\^\s\*\\\%('. join(s:cmds, '\|') .'\)\>'
endf


function! foldtext#ft#tex#GetLevel() abort "{{{3
    let cmd = matchstr(getline('.'), '^\s*\\\zs[a-z]\+')
    return index(s:cmds, cmd) + 1
endf

