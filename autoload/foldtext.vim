" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     https://github.com/tomtom
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2017-04-04
" @Revision:    131


if !exists('g:foldtext#max_headings')
    let g:foldtext#max_headings = 1000   "{{{2
endif


function! foldtext#MaybeInvalidateData() abort "{{{3
    " Always invalidate the data
    if !exists('b:foldtext_invalidated') && exists('b:foldtext')
        let b:foldtext_invalidated = 1
        au Viki CursorHold,CursorHoldI <buffer> call s:InvalidateData()
    endif
endf


function! s:InvalidateData() abort "{{{3
    au! Viki CursorHold,CursorHoldI <buffer> call s:InvalidateData()
    unlet! b:foldtext_invalidated
    unlet! b:foldtext
endf


function! foldtext#Setup(opt) abort "{{{3
    let bufnr = bufnr('%')
    if has_key(a:opt, 'rx') && getbufvar(bufnr, 'foldtext_rx', '') != a:opt.rx
        let b:foldtext_rx = a:opt.rx
    endif
    if has_key(a:opt, 'level_expr') && getbufvar(bufnr, 'foldtext_level_expr', '') != a:opt.level_expr
        let b:foldtext_level_expr = a:opt.level_expr
    endif
    if &l:foldexpr !=# 'foldtext#Foldexpr(v:lnum)'
        augroup Foldtext
            autocmd InsertLeave <buffer> call foldtext#MaybeInvalidateData()
            " autocmd TextChanged <buffer> call foldtext#MaybeInvalidateData()
        augroup END
        setlocal foldmethod=expr
        setlocal foldexpr=foldtext#Foldexpr(v:lnum)
        let undo_ftplugin = 'setlocal foldmethod< foldexpr< | unlet! b:foldtext_rx b:foldtext_level_expr | autocmd! Foldtext InsertLeave <buffer>'
        if exists('b:undo_ftplugin')
            let b:undo_ftplugin .= ' | '. undo_ftplugin
        else
            let b:undo_ftplugin = undo_ftplugin
        endif
    endif
endf


function! foldtext#Foldexpr(lnum) abort "{{{3
    if !exists('b:foldtext')
        call s:MakeHeadingsData()
    endif
    if !exists('b:foldtext')
        return -1
    else
        return b:foldtext.GetFoldLevel(a:lnum)
    endif
endf


let s:node = {}

function! s:node.GetFoldLevel(lnum) abort dict "{{{3
    if a:lnum < self.mid
        return self.left.GetFoldLevel(a:lnum)
    else
        return self.right.GetFoldLevel(a:lnum)
    endif
endf


let s:leaf = {}

function! s:leaf.GetFoldLevel(lnum) abort dict "{{{3
    return get(self.lnums, ''. a:lnum, self.level)
endf


let s:empty = {}

function! s:empty.GetFoldLevel(lnum) abort dict "{{{3
    return -1
endf


function! s:GetRx() abort "{{{3
    if exists('b:foldtext_rx')
        return b:foldtext_rx
    else
        return foldtext#ft#{&filetype}#GetRx()
    endif
endf


function! s:GetLevel() abort "{{{3
    if exists('b:foldtext_level_expr')
        return eval(b:foldtext_level_expr)
    else
        return foldtext#ft#{&filetype}#GetLevel()
    endif
endf


function! s:MakeHeadingsData() abort "{{{3
    let l:lnums = []
    let l:headings = {}
    let l:pos = getpos('.')
    try
        let l:lnum = 0
        let l:first = 1
        while l:lnum < line('$')
            let l:lnum += 1
            exec l:lnum
            norm! 0
            let l:lnum = search(s:GetRx(), 'ceW')
            if l:lnum == 0
                break
            else
                call add(l:lnums, l:lnum)
                let l:headings[''. l:lnum] = {'level': s:GetLevel(), 'first': l:first}
                let l:first = 0
            endif
        endwh
    finally
        call setpos('.', l:pos)
    endtry
    if len(l:lnums) >= g:foldtext#max_headings
        setlocal foldexpr&
    else
        let b:foldtext = s:Tree(l:lnums, l:headings)
    endif
endf


function! s:Tree(lnums, headings) abort "{{{3
    let l:llen = len(a:lnums)
    if l:llen == 0
        return copy(s:empty)
    elseif l:llen == 1
        return s:Leaf(a:lnums, a:headings)
    elseif l:llen > 1
        return s:Node(a:lnums, a:headings)
    endif
endf


function! s:Leaf(lnums, headings) abort "{{{3
    let l:lnum = a:lnums[0]
    let l:snum = ''. l:lnum
    let l:leaf = copy(s:leaf)
    let l:level = a:headings[l:snum].level
    let l:leaf.level = l:level
    let l:lnums = {}
    for l:lnum1 in a:lnums
        let l:lnums[''. l:lnum1] = '>'. l:level
    endfor
    let l:leaf.lnums = l:lnums
    if l:lnum > 1 && a:headings[l:snum].first
        let l:node = copy(s:node)
        let l:node.mid = l:lnum
        let l:node.left = copy(s:empty)
        let l:node.right = l:leaf
        return l:node
    else
        return l:leaf
    endif
endf


function! s:Node(lnums, headings) abort "{{{3
    let l:node = copy(s:node)
    let l:llen = len(a:lnums)
    let l:mid = l:llen / 2
    let l:node.mid = a:lnums[l:mid]
    let l:node.left = s:Tree(a:lnums[0 : l:mid - 1], a:headings)
    let l:node.right = s:Tree(a:lnums[l:mid : -1], a:headings)
    if has_key(l:node.left, 'level') && has_key(l:node.right, 'level') && l:node.left.level == l:node.right.level
        return s:Leaf(a:lnums, a:headings)
    else
        return l:node
    endif
endf

