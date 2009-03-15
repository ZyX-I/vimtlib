" checksyntax.vim -- Check syntax when saving a file (php, ruby, tex ...)
" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     04-Mai-2005.
" @Last Change: 2009-03-14.
" @Revision:    316

if exists('g:checksyntax')
    finish
endif
let g:checksyntax = 5

""" General variables
if !exists('g:checksyntax_auto')
    let g:checksyntax_auto = 1
endif
" if !exists('g:checksyntax_shellpipe')
"     let g:checksyntax_shellpipe = '>'
" endif

if !exists('g:checksyntax_failrx')
    let g:checksyntax_failrx = '\ *\(\d \f\{-}:\)\?\d\{-}:'
endif
        
""" Php specific
"""""" Check syntax
if !exists('g:checksyntax_cmd_php')
    let g:checksyntax_cmd_php  = 'php -l'
endif
if !exists('g:checksyntax_efm_php')
    let g:checksyntax_efm_php  = '%*[^:]: %m in %f on line %l'
endif
if !exists('g:checksyntax_okrx_php')
    let g:checksyntax_okrx_php = 'No syntax errors detected in '
endif
" if !exists('g:checksyntax_failrx_php')
"     let g:checksyntax_failrx_php = 'Parse error: \|Error parsing'
" endif
if !exists('g:checksyntax_auto_php')
    let g:checksyntax_auto_php = 1
endif

"""""" Parse
if !exists('g:checksyntax_cmd_phpp')
    let g:checksyntax_cmd_phpp = 'php -f'
endif
if !exists('g:checksyntax_efm_phpp')
    let g:checksyntax_efm_phpp = g:checksyntax_efm_php
endif
if !exists('g:checksyntax_okrx_phpp')
    let g:checksyntax_okrx_phpp = g:checksyntax_okrx_php
endif
" if !exists('g:checksyntax_failrx_phpp')
"     let g:checksyntax_failrx_phpp = '^Parse error: '
" endif
if !exists('g:checksyntax_auto_phpp')
    let g:checksyntax_auto_phpp = g:checksyntax_auto_php
endif

if !exists('g:checksyntax_alt_php')
    let g:checksyntax_alt_php = 'phpp'
endif

""" JavaScript specific
if !exists('g:checksyntax_cmd_javascript')
    let g:checksyntax_cmd_javascript = 'jsl -nofilelisting -nocontext -nosummary -nologo -process'
endif
if !exists('g:checksyntax_okrx_javascript')
    let g:checksyntax_okrx_javascript = '0 error(s), 0 warning(s)'
endif
" if !exists('g:checksyntax_auto_javascript')
"     let g:checksyntax_auto_javascript = 0
" endif


""" Ruby specific
if !exists('g:checksyntax_cmd_ruby')
    let g:checksyntax_cmd_ruby = 'ruby -c'
endif
if !exists('g:checksyntax_okrx_ruby')
    let g:checksyntax_okrx_ruby = 'Syntax OK\|No Errors'
endif
if !exists('g:checksyntax_auto_ruby')
    " let g:checksyntax_auto_ruby = 1
    let g:checksyntax_auto_ruby = 0
endif
if !exists('*CheckSyntax_prepare_ruby')
    fun! CheckSyntax_prepare_ruby()
        compiler ruby
    endf
endif

""" Viki specific
if !exists('g:checksyntax_cmd_viki')
    let g:checksyntax_cmd_viki = 'deplate -f null'
endif
if !exists('g:checksyntax_auto_viki')
    " let g:checksyntax_auto_viki = 1
    let g:checksyntax_auto_viki = 0
endif
" if !exists('*CheckSyntax_prepare_viki')
"     fun! CheckSyntax_prepare_viki()
"         compiler deplate
"     endf
" endif

""" chktex (LaTeX specific)
if !exists('g:checksyntax_cmd_tex')
    let g:checksyntax_cmd_tex = 'chktex -q -v0'
endif
if !exists('g:checksyntax_auto_tex')
    " File:Line:Column:Warning number:Warning message
    let g:checksyntax_efm_tex  = '%f:%l:%m'
endif
if !exists('g:checksyntax_auto_tex')
    " let g:checksyntax_auto_tex = 1
    let g:checksyntax_auto_tex = 0
endif

""" c, cpp
if !exists('g:checksyntax_compiler_c')
    let g:checksyntax_compiler_c = 'splint'
endif
if !exists('g:checksyntax_compiler_cpp')
    let g:checksyntax_compiler_cpp = 'splint'
endif

""" java
if !exists('g:checksyntax_compiler_java')
    let g:checksyntax_cmd_java = '*CheckStyleJlint'
endif
function! CheckStyleJlint() "{{{3
    let filename = expand('%:r') .'.class'
    " TLogVAR filename
    return 'jlint -done '. shellescape(filename)
endf

if !exists('g:checksyntax_alt_java')
    let g:checksyntax_alt_java = 'javaCheckstyle'
endif
if !exists('g:checksyntax_compiler_javaCheckstyle')
    let g:checksyntax_compiler_javaCheckstyle = 'checkstyle'
endif

""" tidy (HTML)
if !exists('g:checksyntax_compiler_html')
    let g:checksyntax_compiler_html = 'tidy'
endif

""" XML
if !exists('g:checksyntax_compiler_xml')
    let g:checksyntax_compiler_xml = 'xmllint'
endif
if !exists('g:checksyntax_compiler_docbk')
    let g:checksyntax_compiler_docbk = g:checksyntax_compiler_xml
endif

" if has('signs') && exists('loaded_tlib') && loaded_tlib >= 32
"     sign define CheckSyntax text=! texthl=Error
"     let s:checksyntax_signs = 1
"     " Clear all checksyntax-related signs.
"     command! CheckSyntaxClearSigns call tlib#signs#ClearAll('CheckSyntax')
" else
"     let s:checksyntax_signs = 0
" endif

fun! s:Make()
    try
        " TLogVAR &makeprg
        if &makeprg[0:0] == '*'
            " TLogVAR &makeprg[1 : -1]
            let &makeprg = call(&makeprg[1 : -1], [])
            " TLogVAR &makeprg
            silent make
        else
            silent make %
        endif
        let se=v:shell_error
        " TLogVAR se
        redir => errors
        silent! clist
        redir END
        " TLogVAR errors
        return errors
    catch
        echohl Error
        echom v:errmsg
        echohl NONE
    endtry
    return ''
endf

" CheckSyntax(manually, ?bang='', ?type=&ft)
function! CheckSyntax(manually, ...)
    let bang = a:0 >= 1 && a:1 != '' ? 1 : 0
    let ft   = a:0 >= 2 && a:2 != '' ? a:2 : &filetype
    if bang && exists('g:checksyntax_alt_'. ft)
        let ft = g:checksyntax_alt_{ft}
    endif
    if !(a:manually || (exists('g:checksyntax_auto_'. ft) && g:checksyntax_auto_{ft}))
        return
    endif
    if &modified
        echom "Buffer was modified. Please save it before calling :CheckSyntax."
        return
    end
    let compiler = s:GetVar('g:checksyntax_compiler_', ft, a:manually)
    let makecmd  = s:GetVar('g:checksyntax_cmd_', ft, a:manually)
    if empty(compiler) && empty(makecmd)
        return
    endif
    let mp = &makeprg
    let ef = &errorformat
    let sp = &shellpipe
    try
        if !empty(compiler)
            if exists('b:current_compiler')
                let cc = b:current_compiler
            else
                let cc = ''
            endif
            exec 'compiler '. compiler
        elseif !empty(makecmd)
            let &makeprg = makecmd
            " TLogVAR &makeprg
            if exists('g:checksyntax_shellpipe')
                let &shellpipe = g:checksyntax_shellpipe
                " TLogVAR &shellpipe
            endif
            if exists('g:checksyntax_efm_'. ft)
                let &errorformat = g:checksyntax_efm_{ft}
            else
                set errorformat&
            endif
            " TLogVAR &errorformat
        endif
        if exists('*CheckSyntax_prepare_'. ft)
            call CheckSyntax_prepare_{ft}()
        endif
        let output = s:Make()
        " TLogVAR output
        let failrx = exists('g:checksyntax_failrx_'. ft) ? g:checksyntax_failrx_{ft} : g:checksyntax_failrx
        let okrx   = exists('g:checksyntax_okrx_'. ft) ? g:checksyntax_okrx_{ft} : ''
        " if s:checksyntax_signs
        "     call tlib#signs#ClearAll('CheckSyntax')
        "     call tlib#signs#Mark('CheckSyntax', getqflist())
        " endif
        if output == '' || (okrx != '' && output =~ okrx) || (failrx != '' && output !~ failrx)
            " TLogVAR output, okrx, failrx
            " TLogDBG okrx != '' && output =~ okrx
            " TLogDBG output !~ failrx
            call CheckSyntaxSucceed(a:manually)
        else
            call CheckSyntaxFail(a:manually)
        endif
    finally
        let &makeprg     = mp
        let &errorformat = ef
        let &shellpipe   = sp
        if !empty(compiler)
            if cc == ''
                if exists('b:current_compiler')
                    unlet b:current_compiler
                endif
            else
                exec 'compiler '. cc
            endif
        endif
    endtry
endf

function! s:GetVar(var, ft, manually) "{{{3
    if !a:manually && exists(a:var .'auto_'. a:ft)
        return {a:var}auto_{a:ft}
    elseif exists(a:var . a:ft)
        return {a:var}{a:ft}
    else
        return ''
    endif
endf

if !exists('*CheckSyntaxSucceed')
    func! CheckSyntaxSucceed(manually)
        cclose
        if a:manually
            echo
            echo 'Syntax ok.'
        endif
    endf
endif

if !exists('*CheckSyntaxFail')
    fun! CheckSyntaxFail(manually)
        copen
    endf
endif

command! -bang -nargs=? CheckSyntax call CheckSyntax(1, "<bang>", <f-args>)

if !hasmapto(':CheckSyntax')
    noremap <F5> :CheckSyntax<cr>
    inoremap <F5> <c-o>:CheckSyntax<cr> 
endif

if g:checksyntax_auto
    autocmd BufWritePost * call CheckSyntax(0)
endif


finish
History:

0.2
php specific

0.3
generalized plugin; modes; support for ruby, phpp, tex (chktex)

0.4
use vim compilers if available (e.g., tidy, xmllint ...); makeprg was 
restored in the wrong window

0.5
- support for jsl (javascript lint)
- support for jlint

