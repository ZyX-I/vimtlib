" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-02-26.
" @Last Change: 2009-02-26.
" @Revision:    9

let s:save_cpo = &cpo
set cpo&vim


SpecBegin 'title': 'PluginKiller Integration'


Should be equal &hidden, 1


SpecEnd



let &cpo = s:save_cpo
unlet s:save_cpo
