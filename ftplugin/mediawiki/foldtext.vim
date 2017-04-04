" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     https://github.com/tomtom
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    3

call foldtext#Setup({'rx': '^=\+\ze\s', 'level_expr': 'col(".")'})

