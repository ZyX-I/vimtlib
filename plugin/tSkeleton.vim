" tSkeleton.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     21-Sep-2004.
" @Last Change: 2010-02-26.
" @Revision:    3897
"
" GetLatestVimScripts: 1160 1 tSkeleton.vim
" http://www.vim.org/scripts/script.php?script_id=1160
"
" TODO: When bits change, opened hidden buffer don't get updated it 
" seems.
" TODO: Enable multiple skeleton directories (and maybe other sources 
" like DBs).
" TODO: Sorted menus.
" TODO: ADD: More html bits
" TODO: ADD: <tskel:post> embedded tag (evaluate some vim code on the 
" visual region covering the final expansion)

if &cp || exists("loaded_tskeleton") "{{{2
    finish
endif
if !exists('loaded_tlib') || loaded_tlib < 29
    runtime plugin/02tlib.vim
    if !exists('loaded_tlib') || loaded_tlib < 29
        echoerr "tSkeleton requires tlib >= 0.29"
        finish
    endif
endif
let loaded_tskeleton = 409


if !exists("g:tskelDir") "{{{2
    let g:tskelDir = get(split(globpath(&rtp, 'skeletons/'), '\n'), 0, '')
endif
if !isdirectory(g:tskelDir) "{{{2
    echoerr 'tSkeleton: g:tskelDir ('. g:tskelDir .') isn''t readable. See :help tSkeleton-install for details!'
    finish
endif
let g:tskelDir = tlib#dir#CanonicName(g:tskelDir)

if !exists('g:tskelBitsDir') "{{{2
    let g:tskelBitsDir = g:tskelDir .'bits/'
    " call tlib#dir#Ensure(g:tskelBitsDir)
endif

let g:tskeleton_SetFiletype = 1

if !exists("g:tskelMapLeader")     | let g:tskelMapLeader     = "<Leader>#"   | endif "{{{2
if !exists("g:tskelMapInsert")     | let g:tskelMapInsert     = '<c-\><c-\>'  | endif "{{{2
if !exists("g:tskelAddMapInsert")  | let g:tskelAddMapInsert  = 0             | endif "{{{2
if !exists("g:tskelMenuCache")      | let g:tskelMenuCache = '.tskelmenu'  | endif "{{{2
if !exists("g:tskelMenuPrefix")     | let g:tskelMenuPrefix  = 'TSke&l'    | endif "{{{2

if !exists("g:tskelMapHyperComplete") "{{{2
    if empty(maparg('<c-space>') . maparg('<c-space>', 'i'))
        let g:tskelMapHyperComplete = '<c-space>'
    else
        let g:tskelMapHyperComplete = ''
    endif
endif

if !exists("g:tskelHyperComplete") "{{{2
    " let g:tskelHyperComplete = {'use_completefunc': 1, 'use_omnifunc': 1, 'scan_words': 1, 'scan_tags': 1}
    let g:tskelHyperComplete = {'use_completefunc': 1, 'scan_words': 1, 'scan_tags': 1}
endif

if !exists('g:tskelHyperType')
    " Either query or pum.
    " If you set the variable to "pum", you have to accept completions 
    " with <c-y>.
    " This variable must be set in your |vimrc| file before loading the 
    " tskeleton plugin.
    let g:tskelHyperType = 'query'   "{{{2
    " let g:tskelHyperType = 'pum'   "{{{2
endif


function! TSkeletonMapGoToNextTag() "{{{3
    nnoremap <silent> <c-j> :call tskeleton#GoToNextTag()<cr>
    vnoremap <silent> <c-j> <c-\><c-n>:call tskeleton#GoToNextTag()<cr>
    inoremap <silent> <c-j> <c-\><c-o>:call tskeleton#GoToNextTag()<cr>
endf


" In the current buffer, map a:key so that
"   - If the cursor is located at the beginning of the line or if the 
"     the cursor is over a whitespace character, indent the current
"     line
"   - otherwise expand the bit under the cursor or (if not suitable bit
"     was found) use &omnifunc, &completefunc, tags, and (as fallback 
"     strategy) the words in the buffer as possible completions.
function! TSkeletonMapHyperComplete(key, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : '=='
    if g:tskelHyperType == 'pum'
        exec 'inoremap '. a:key .' <C-R>=tskeleton#HyperComplete_'. g:tskelHyperType .'("i", '. string(default) .')<cr>'
    elseif g:tskelHyperType == 'query'
        exec 'inoremap '. a:key .' <c-\><c-o>:call tskeleton#HyperComplete_'. g:tskelHyperType .'("i", '. string(default) .')<cr>'
    else
        echoerr "tSkeleton: Unknown type for g:tskelHyperType: "+ g:tskelHyperType
    endif
    exec 'noremap '. a:key .' :call tskeleton#HyperComplete_query("n", '. string(default) .')<cr>'
endf
if !empty(g:tskelMapHyperComplete)
    call TSkeletonMapHyperComplete(g:tskelMapHyperComplete)
endif


command! -nargs=* -complete=custom,tskeleton#SelectTemplate TSkeletonSetup 
            \ call tskeleton#Setup(<f-args>)


command! -nargs=? -complete=custom,tskeleton#SelectTemplate TSkeletonEdit 
            \ call tskeleton#Edit(<q-args>)


command! -nargs=? -complete=customlist,tskeleton#EditBitCompletion TSkeletonEditBit 
            \ call tskeleton#EditBit(<q-args>)


command! -nargs=* -complete=custom,tskeleton#SelectTemplate TSkeletonNewFile 
            \ call tskeleton#NewFile(<f-args>)


command! -bar -nargs=? TSkeletonBitReset call tskeleton#ResetBits(<q-args>)


command! -nargs=? -complete=custom,tskeleton#SelectBit TSkeletonBit
            \ call tskeleton#Bit(<q-args>)


command! TSkeletonCleanUpBibEntry call tskeleton#CleanUpBibEntry()

if !empty(g:tskelMapLeader)
    " noremap <unique> <Leader>tt ""diw:TSkeletonBit <c-r>"
    exec "noremap <unique> ". g:tskelMapLeader ."t :TSkeletonBit "
    
    exec "nnoremap <unique> ". g:tskelMapLeader ."# :call tskeleton#ExpandBitUnderCursor('n')<cr>"
    if g:tskelAddMapInsert
        exec "inoremap <unique> ". g:tskelMapInsert ." <c-\\><c-o>:call tskeleton#ExpandBitUnderCursor('i','', {'string':". string(g:tskelMapInsert) ."})<cr>"
    else
        exec "inoremap <unique> ". g:tskelMapInsert ." <c-\\><c-o>:call tskeleton#ExpandBitUnderCursor('i')<cr>"
    endif
    
    exec "vnoremap <unique> ". g:tskelMapLeader ."# d:call tskeleton#WithSelection('')<cr>"
    exec "vnoremap <unique> ". g:tskelMapLeader ."<space> d:call tskeleton#WithSelection(' ')<cr>"
    
    exec "nnoremap <unique> ". g:tskelMapLeader ."x :call tskeleton#LateExpand()<cr>"
    exec "vnoremap <unique> ". g:tskelMapLeader ."x <esc>`<:call tskeleton#LateExpand()<cr>"
endif


augroup tSkeleton
    autocmd!
    if !exists("g:tskelDontSetup") "{{{2
        function! s:DefineAutoCmd(template) "{{{3
            " TLogVAR a:template
            " let sfx = fnamemodify(a:template, ':e')
            let tpl = fnamemodify(a:template, ':t')
            " TLogVAR tpl
            let filetype = tlib#url#Decode(matchstr(tpl, '^\S\+'))
            let pattern  = matchstr(tpl, '^\S\+ \+\zs.*$')
            if !empty(filetype) && !empty(pattern)
                " TLogVAR pattern
                let pattern  = substitute(pattern, '#', '*', 'g')
                " TLogVAR pattern
                let pattern  = tlib#url#Decode(pattern)
                " TLogVAR pattern
                " TLogDBG 'autocmd BufNewFile '. escape(pattern, ' ') .' set ft='. escape(filetype, ' ') .' | TSkeletonSetup '. escape(a:template, ' ')
                exec 'autocmd BufNewFile '. escape(pattern, ' ') .' set ft='. escape(filetype, ' ') .' | TSkeletonSetup '. escape(a:template, ' ')
            endif
        endf

        call map(split(glob(tlib#file#Join([g:tskelDir, 'templates', '**'], 1)), '\n'), 'isdirectory(v:val) || s:DefineAutoCmd(v:val)')
        delfunction s:DefineAutoCmd

        autocmd BufNewFile *.bat       TSkeletonSetup batch.bat
        autocmd BufNewFile *.tex       TSkeletonSetup latex.tex
        autocmd BufNewFile tc-*.rb     TSkeletonSetup tc-ruby.rb
        autocmd BufNewFile *.rb        TSkeletonSetup ruby.rb
        autocmd BufNewFile *.rbx       TSkeletonSetup ruby.rb
        autocmd BufNewFile *.sh        TSkeletonSetup shell.sh
        autocmd BufNewFile *.txt       TSkeletonSetup text.txt
        autocmd BufNewFile *.vim       TSkeletonSetup plugin.vim
        autocmd BufNewFile *.inc.php   TSkeletonSetup php.inc.php
        autocmd BufNewFile *.class.php TSkeletonSetup php.class.php
        autocmd BufNewFile *.php       TSkeletonSetup php.php
        autocmd BufNewFile *.tpl       TSkeletonSetup smarty.tpl
        autocmd BufNewFile *.html      TSkeletonSetup html.html

    endif

    exec 'autocmd BufNewFile,BufRead '. escape(g:tskelDir, ' ') .'* if g:tskeleton_SetFiletype | set ft=tskeleton | endif'
    exec 'autocmd BufWritePost '. escape(g:tskelBitsDir, ' ') .'* exec "TSkeletonBitReset ".expand("<afile>:p:h:t")'
    autocmd SessionLoadPost,BufEnter * if (g:tskelMenuPrefix != '' && g:tskelMenuCache != '' && !tskeleton#IsScratchBuffer()) | call tskeleton#BuildBufferMenu(1) | endif
    
    autocmd FileType bib if !hasmapto(":TSkeletonCleanUpBibEntry") | exec "noremap <buffer> ". g:tskelMapLeader ."c :TSkeletonCleanUpBibEntry<cr>" | endif
augroup END


" call tskeleton#PrepareBits('general')


finish

-------------------------------------------------------------------
CHANGES:

1.0
- Initial release

1.1
- User-defined tags
- Modifiers <+NAME:MODIFIERS+> (c=capitalize, u=toupper, l=tolower, 
  s//=substitute)
- Skeleton bits
- the default markup for tags has changed to <+TAG+> (for 
  "compatibility" with imaps.vim), the cursor position is marked as 
  <+CURSOR+> (but this can be changed by setting g:tskelMarkerLeft, 
  g:tskelMarkerRight, and g:tskelMarkerCursor)
- in the not so simple mode, skeleton bits can contain vim code that 
  is evaluated after expanding the template tags (see 
  .../skeletons/bits/vim/if for an example)
- function TSkeletonExpandBitUnderCursor(), which is mapped to 
  <Leader>#
- utility function: TSkeletonIncreaseRevisionNumber()

1.2
- new pseudo tags: bit (recursive code skeletons), call (insert 
  function result)
- before & after sections in bit definitions may contain function 
  definitions
- fixed: no bit name given in s:SelectBit()
- don't use ={motion} to indent text, but simply shift it

1.3
- TSkeletonCleanUpBibEntry (mapped to <Leader>tc for bib files)
- complete set of bibtex entries
- fixed problem with [&bg]: tags
- fixed typo that caused some slowdown
- other bug fixes
- a query must be enclosed in question marks as in <+?Which ID?+>
- the "test_tSkeleton" skeleton can be used to test if tSkeleton is 
  working
- and: after/before blocks must not contain function definitions

1.4
- Popup menu with possible completions if 
  TSkeletonExpandBitUnderCursor() is called for an unknown code 
  skeleton (if there is only one possible completion, this one is 
  automatically selected)
- Make sure not to change the alternate file and not to distort the 
  window layout
- require genutils
- Syntax highlighting for code skeletons
- Skeleton bits can now be expanded anywhere in the line. This makes 
  it possible to sensibly use small bits like date or time.
- Minor adjustments
- g:tskelMapLeader for easy customization of key mapping (changed the 
  map leader to "<Leader>#" in order to avoid a conflict with Align; 
  set g:tskelMapLeader to "<Leader>t" to get the old mappings)
- Utility function: TSkeletonGoToNextTag(); imaps.vim like key 
  bindings via TSkeletonMapGoToNextTag()

1.5
- Menu of small skeleton "bits"
- TSkeletonLateExpand() (mapped to <Leader>#x)
- Disabled <Leader># mapping (use it as a prefix only)
- Fixed copy & paste error (loaded_genutils)
- g:tskelDir defaults to $HOME ."/vimfiles/skeletons/" on Win32
- Some speed-up

2.0
- You can define "groups of bits" (e.g. in php mode, all html bits are 
  available too)
- context sensitive expansions (only very few examples yet); this 
  causes some slowdown; if it is too slow, delete the files in 
  .vim/skeletons/map/
- one-line "mini bits" defined in either 
  ./vim/skeletons/bits/{&filetype}.txt or in $PWD/.tskelmini
- Added a few LaTeX, HTML and many Viki skeleton bits
- Added EncodeURL.vim
- Hierarchical bits menu by calling a bit "SUBMENU.BITNAME" (the 
  "namespace" is flat though; the prefix has no effect on the bit 
  name; see the "bib" directory for an example)
- the bit file may have an ampersand (&) in their names to define the 
  keyboard shortcut
- Some special characters in bit names may be encoded as hex (%XX as 
  in URLs)
- Insert mode: map g:tskelMapInsert ('<c-\><c-\>', which happens to be 
  the <c-#> key on a German qwertz keyboard) to 
  TSkeletonExpandBitUnderCursor()
- New <tskel:msg> tag in skeleton bits
- g:tskelKeyword_{&filetype} variable to define keywords by regexp 
  (when 'iskeyword' isn't flexible enough)
- removed the g:tskelSimpleBits option
- Fixed some problems with the menu
- Less use of globpath()

2.1
- Don't accidentally remove torn off menus; rebuild the menu less 
  often
- Maintain insert mode (don't switch back to normal mode) in 
  <c-\><c-\> imap
- If no menu support is available, use the s:Query function to let 
  the user select among eligible bits (see also g:tskelQueryType)
- Create a normal and an insert mode menu
- Fixed selection of eligible bits
- Ensure that g:tskelDir ends with a (back)slash
- Search for 'skeletons/' in &runtimepath & set g:tskelDir accordingly
- If a template is named "#.suffix", an autocmd is created  
  automatically.
- Set g:tskelQueryType to 'popup' only if gui is win32 or gtk.
- Minor tweak for vim 7.0 compatibility

2.2
- Don't display query menu, when there is only one eligible bit
- EncodeURL.vim now correctly en/decoded urls
- UTF8 compatibility -- use col() instead of virtcol() (thanks to Elliot 
  Shank)

2.3
- Support for current versions of genutils (> 2.0)

2.4
- Changed the default value for g:tskelDateFormat from "%d-%b-%Y" to 
'%Y-%m-%d'
- 2 changes to TSkeletonGoToNextTag(): use select mode (as does 
imaps.vim, set g:tskelSelectTagMode to 'v' to get the old behaviour), 
move the cursor one char to the left before searching for the next tag 
(thanks to M Stubenschrott)
- added a few AutoIt3 skeletons
- FIX: handle tabs properly
- FIX: problem with filetypes containing non-word characters
- FIX: check the value of &selection
- Enable normal tags for late expansion

3.0
- Partial rewrite for vim7 (drop vim6 support)
- Now depends on tlib (vimscript #1863)
- "query" now uses a more sophisticated version from autoload/tlib.vim
- The default value for g:tskelQueryType is "query".
- Experimental (proof of concept) code completion for vim script 
(already sourced user-defined functions only). Use :delf 
TSkelFiletypeBits_functions_vim to disable this as it can take some 
time on initialization.
- Experimental (proof of concept) tags-based code completion for ruby.  
Use :delf TSkelProcessTag_ruby to disable this. It's only partially 
useful as it simply works on method names and knows nothing about 
classes, modules etc. But it gives you an argument list to fill in. It 
shouldn't be too difficult to adapt this for other filetypes for which 
such an approach could be more useful.
- The code makes it now possible to somehow plug in custom bit types by 
defining TSkelFiletypeBits_{NAME}(dict, filetype), or 
TSkelFiletypeBits_{NAME}_{FILETYPE}(dict, filetype), 
TSkelBufferBits_{NAME}(dict, filetype), 
TSkelBufferBits_{NAME}_{FILETYPE}(dict, filetype).
- FIX s:RetrieveAgent_read(): Delete last line, which should fix the 
problem with extraneous return characters in recursively included 
skeleton bits.
- FIX: bits containing backslashes
- FIX TSkeletonGoToNextTag(): Moving cursor when no tag was found.
- FIX: Minibits are now properly displayed in the menu.

3.1
- Tag-based code completion for vim
- Made the supported skeleton types configurable via g:tskelTypes
- FIX: Tag-based skeletons the name of which contain blanks
- FIX: Undid shortcut that prevented the <+bit:+> tag from working
- Preliminary support for using keys like <space> for insert mode 
expansion.

3.2
- "tags" & "functions" types are disabled by default due to a noticeable 
delay on initialization; add 'tags' and 'functions' to g:tskelTypes to 
re-enable them (with the new caching strategy, it's usable, but can 
produce much noise; but this depends of course on the way you handle 
tags)
- Improved caching strategy: cache filetype bits in 
skeletons/cache_bits; cache buffer-specific bits in 
skeletons/cache_bbits/&filetype/path (set g:tskelUseBufferCache to 0 to 
turn this off; this speeds up things quite a lot but creates many files 
on the long run, so you might want to purge the cache from time to time)
- embedded <tskel:> tags are now extracted on initialization and not 
when the skeleton is expanded (I'm not sure yet if it is better this 
way)
- CHANGE: dropped support for the ~/.vim/skeletons/prefab subdirectory; 
you'll have to move the templates, if any, to ~/.vim/skeletons
- FIX: :TSkeletonEdit, :TSkeletonSetup command-line completion
- FIX: Problem with fold markers in bits when &fdm was marker
- FIX: Problems with PrepareBits()
- FIX: Problems when the skeletons/menu/ subdirectory didn't exist
- TSkeletonExecInDestBuffer(code): speed-up
- Moved functions from EncodeURL.vim to tlib.vim
- Updated the manual
- Renamed the skeletons/menu subdirectory to skeletons/cache_menu

3.3
- New :TSkeletonEditBit command
- FIX: Embedded <tskel> tags in file templates didn't work

3.4
- Automatically reset bits information after editing a bit.
- Automatically define autocommands for templates with the form "NAME 
PATTERN" (where "#" in the pattern is replaced with "*"), i.e. the 
template file "text #%2ffoo%2f#.txt" will define a template for all new 
files matching "*/foo/*.txt"; the filetype will be set to "text"
- These "auto templates" must be located in 
~/.vim/skeletons/templates/GROUP/
- TSkeletonCB_FILENAME(), TSkeletonCB_DIRNAME()
- FIX: TSkeletonGoToNextTag() didn't work properly with ### type of 
markers.
- FIX: TSkeletonLateExpand(): tag at first column
- FIX: In templates, empty lines sometimes were not inserted in the 
document
- FIX: Build menu on SessionLoadPost event.
- FIX: Protect against autocommands that move the cursor on a BufEnter 
event
- FIX: Some special characters in the skeleton bit expansion were escaped 
twice with backslashes.
- Require tlib 0.9
- Make sure &foldmethod=manual in the scratch buffer

3.5
- FIX: Minor problem with auto-templates

4.0
- Renamed g:tskelPattern* variables to g:tskelMarker*
- If g:tskelMarkerHiGroup is non-empty, place holders will be 
highlighted in this group.
- Re-enable 'mini' in g:tskelTypes.
- Calling TSkeletonBit with no argument, brings up the menu.
- Require tlib 0.12
- CHANGE: The cache is now stored in ~/vimfiles/cache/ (use 
tlib#cache#Filename)
- INCOMPATIBLE CHANGE: Use autoload/tskeleton.vim
- FIX: Problem with cache name
- FIX: Problem in s:IsDefined()
- FIX: TSkeletonEditBit completion didn't work before expanding a bit.
- FIX: Command-line completion when tSkeleton wasn't invoked yet (and 
menu wasn't built).

4.1
- Automatically define iabbreviations by adding [bg]:tskelAbbrevPostfix 
(default: '#') to the bit name (i.e., a bit with the file "foo.bar" will 
by default create the menu entry "TSkel.foo.bar" for the bit "bar" and 
the abbreviation "bar#"). If this causes problems, set 
g:tskelAutoAbbrevs to 0.
- Bits can have a <tskel:abbrev> section that defines the abbreviation.
- New type 'abbreviations': This will make your abbreviations accessible 
as a template (in case you can't remember their names)
- New experimental <tskel:condition> section (a vim expression) that 
checks if a bit is eligible in the current context.
- New <+input()+> tag.
- New <+execute()+> tag.
- New <+let(VAR=VALUE)+> tag.
- <+include(NAME)+> as synonym for <+bit:NAME+>.
- Experimental <+if()+> ... <+elseif()+> ... <+else+> ... <+endif+>, 
<+for(var in list)+> ... <+endfor+> tags.
- Special tags <+nop+>, <+joinline+>, <+nl+> to prevent certain 
problems.
- These special tags have to be lower case.
- Made tskeleton#GoToNextTag() smarter in recognizing something like: 
<+/DEFAULT+>.
- Defined <Leader>## and <Leader>#<space> (see g:tskelMapLeader) as 
visual command (the user will be queried for the name of a skeleton)
- Some functions have moved and changed names. It should now be possible 
to plug-in custom template expanders (or re-use others).
- Use append() via tlib#buffer#InsertText() to insert bits. This could 
cause old problems to reappear although it seems to work fine.
- The markup should now be properly configurable (per buffer; you can 
set template-specific markers in the tskel:here_before section).
- Require tlib 0.14
- The default value for g:tskelUseBufferCache is 0 as many people might 
find the accumulation of cached information somewhat surprising. Unless 
you use tag/functions type of skeleton bit, it's unnecessary anyway.
- Removed the dependency on genutils.
- The g:tskelMarkerCursor variable was removed and replaced with 
g:tskelMarkerCursor_mark and g:tskelMarkerCursor_rx.

4.2
- Enable <+CURSOR/foo+>. After expansion "foo" will be selected.
- New (old) default values: removed 'abbreviations' from g:tskelTypes 
and set g:tskelAutoAbbrevs to 0 in order to minimize surprises.
- Enabled tex-Skeletons for the viki filetype
- FIX: Place the cursor at the end of an inserted bit that contains no 
cursor marker (which was the original behaviour).
- Split html bits into html and html_common; the java group includes 
html_common.
- CHANGE: Made bit names case-sensitive
- NEW: select() tag (similar to the query tag)

4.3
- bbcode group
- tskelKeyword_{&ft} and tskelGroup_{&ft} variables can be buffer-local
- Case-sensitivity can be configured via [bg]:tskelCaseSensitive and 
[bg]:tskelCaseSensitive_{&filetype}
- Make sure tlib is loaded even if it is installed in a different 
rtp-directory

4.4
- Make sure tlib is loaded even if it is installed in a different 
rtp-directory

4.5
- Call s:InitBufferMenu() earlier.
- C modifier: Consider _ whitespace
- g:tskelMarkerExtra (extra markers for tskeleton#GoToNextTag)

4.6
- Minibits: Allow single words as bit definition: "word" expands to 
"word<+CURSOR+>"
- Require tlib 0.29

4.7
- TSkeletonSetup: allow full filenames as argument
- Auto templates: don't cd into the templates directory
- tskeleton#ExpandBitUnderCursor(): Third argument is a dictionary.
- TSkeletonMapHyperComplete() (default: <c-space>): Map a magic key that 
expands skeletons or, if no matching templates were found, completions, 
tags, words etc.
- FIX: Problem with <+name/expandsion+> kind of tags when located at the 
beginning or end of a line
- s:GetBitDefs()
- Improved tskeleton#Complete() (for use as completefunc or omnifunc)
- FIX: Cursor positioning after expanding templates without a <+CURSOR+> 
tag
- Don't build the menu for tSkeleton scratch buffers

4.8
- Moved the definition of some variables from plugin/tSkeleton.vim to 
autoload/tskeleton.vim
- If g:tskelMapLeader is empty, don't define maps.
- Don't build a menu if g:tskelMenuPrefix == ''.
- If g:tskelDontSetup is defined and g:tskelMenuPrefix == '', 
autoload/tskeleton.vim won't be loaded on startup.
- Don't create g:tskelBitsDir if it doesn't exist

4.9
- "Mini bits": Load all .tskelmini files from the current file's 
directory upwards
- s:InsertDefault handles <+CURSOR+> tags
- tskeleton#HyperComplete_query(): Set w:tskeleton_hypercomplete
- FIX: g:tskelHyperType = "pum" didn't work properly.

