" test.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-02-21.
" @Last Change: 2009-02-21.
" @Revision:    0.0.4

let s:save_cpo = &cpo
set cpo&vim


let s:foo = 123

exec TAssertInit()

function! should#test#Init() "{{{3
    return "TAssert test"
endf


let &cpo = s:save_cpo
unlet s:save_cpo
