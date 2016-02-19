" Enable nocompatible
if has('vim_starting')
    if &compatible
        set nocompatible
    endif
endif

"Detect OS
function! OSX()
    return has('macunix')
endfunction
function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
function! WINDOWS()
    return (has('win16') || has('win32') || has('win64'))
endfunction

"Use English for anything in vim
if WINDOWS()
    silent exec 'language english'
elseif OSX()
    silent exec 'language en_US'
else
    let s:uname = system("uname -s")
    if s:uname == "Darwin\n"
        " in mac-terminal
        silent exec 'language en_US'
    else
        " in linux-terminal
        silent exec 'language en_US.utf8'
    endif
endif

" try to set encoding to utf-8
if WINDOWS()
    " Be nice and check for multi_byte even if the config requires
    " multi_byte support most of the time
    if has('multi_byte')
        " Windows cmd.exe still uses cp850. If Windows ever moved to
        " Powershell as the primary terminal, this would be utf-8
        set termencoding=cp850
        " Let Vim use utf-8 internally, because many scripts require this
        set encoding=utf-8
        setglobal fileencoding=utf-8
        " Windows has traditionally used cp1252, so it's probably wise to
        " fallback into cp1252 instead of eg. iso-8859-15.
        " Newer Windows files might contain utf-8 or utf-16 LE so we might
        " want to try them first.
        set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
    endif

else
    " set default encoding to utf-8
    set encoding=utf-8
    set termencoding=utf-8
endif
scriptencoding utf-8

" Fsep && Psep
if WINDOWS()
    let s:Psep = ';'
    let s:Fsep = '\'
else
    let s:Psep = ':'
    let s:Fsep = '/'
endif

" Enable 256 colors
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

"Vim settings
let s:settings                         = {}
let s:settings.default_indent          = 2
let s:settings.max_column              = 120
let s:settings.auto_download_neobundle = 0
let s:settings.neobundle_installed     = 0
let s:settings.dein_installed     = 0
let s:settings.vim_plug_installed     = 0
let s:settings.plugin_bundle_dir       = join(['~/.cache','vimfiles',''],s:Fsep)
let s:settings.autocomplete_method     = ''
let s:settings.enable_cursorcolumn     = 0
let s:settings.enable_neomake          = 0
let s:settings.enable_ycm              = 0
let s:settings.enable_neocomplcache    = 0
let s:settings.enable_cursorline       = 0
let s:settings.use_colorscheme         = 1
let s:settings.vim_help_language       = 'en'
let s:settings.colorscheme             = 'gruvbox'
let s:settings.colorscheme_default     = 'desert'
let s:settings.filemanager             = 'vimfiler'
let s:settings.plugin_manager          = 'neobundle'  " neobundle or dein or vim-plug
let s:settings.plugin_groups_exclude   = []
let g:Vimrc_Home                       = fnamemodify(expand('<sfile>'), ':p:h:gs?\\?'. s:Fsep. '?')


"core vimrc
let s:settings.plugin_groups = []
call add(s:settings.plugin_groups, 'web')
call add(s:settings.plugin_groups, 'javascript')
call add(s:settings.plugin_groups, 'ruby')
call add(s:settings.plugin_groups, 'python')
call add(s:settings.plugin_groups, 'scala')
call add(s:settings.plugin_groups, 'go')
call add(s:settings.plugin_groups, 'scm')
call add(s:settings.plugin_groups, 'editing')
call add(s:settings.plugin_groups, 'indents')
call add(s:settings.plugin_groups, 'navigation')
call add(s:settings.plugin_groups, 'misc')

call add(s:settings.plugin_groups, 'core')
call add(s:settings.plugin_groups, 'unite')
call add(s:settings.plugin_groups, 'ctrlp')
call add(s:settings.plugin_groups, 'autocomplete')
if ! has('nvim')
    call add(s:settings.plugin_groups, 'vim')
else
    call add(s:settings.plugin_groups, 'nvim')
endif


if s:settings.vim_help_language == 'cn'
    call add(s:settings.plugin_groups, 'chinese')
endif
if s:settings.use_colorscheme==1
    call add(s:settings.plugin_groups, 'colorscheme')
endif
if OSX()
    call add(s:settings.plugin_groups, 'osx')
endif
if WINDOWS()
    call add(s:settings.plugin_groups, 'windows')
endif
if LINUX()
    call add(s:settings.plugin_groups, 'linux')
endif

if has('nvim')
    let s:settings.autocomplete_method = 'deoplete'
elseif has('lua')
    let s:settings.autocomplete_method = 'neocomplete'
else
    let s:settings.autocomplete_method = 'neocomplcache'
endif
if s:settings.enable_ycm
    let s:settings.autocomplete_method = 'ycm'
endif
if s:settings.enable_neocomplcache
    let s:settings.autocomplete_method = 'neocomplcache'
endif

for s:group in s:settings.plugin_groups_exclude
    let s:i = index(s:settings.plugin_groups, s:group)
    if s:i != -1
        call remove(s:settings.plugin_groups, s:i)
    endif
endfor

" python host for neovim
let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'

" auto install plugin manager
if s:settings.plugin_manager == 'neobundle'
    "auto install neobundle
    if filereadable(expand(s:settings.plugin_bundle_dir) . 'neobundle.vim'. s:Fsep. 'README.md')
        let s:settings.neobundle_installed = 1
    else
        if executable('git')
            exec '!git clone https://github.com/Shougo/neobundle.vim ' . s:settings.plugin_bundle_dir . 'neobundle.vim'
            let s:settings.neobundle_installed = 1
        else
            echohl WarningMsg | echom "You need install git!" | echohl None
        endif
    endif
    exec 'set runtimepath+='.s:settings.plugin_bundle_dir . 'neobundle.vim'
elseif s:settings.plugin_manager == 'dein'
    "auto install dein
    if filereadable(expand(s:settings.plugin_bundle_dir) . 'dein.vim'. s:Fsep. 'README.md')
        let s:settings.dein_installed = 1
    else
        if executable('git')
            exec '!git clone https://github.com/Shougo/dein.vim ' . s:settings.plugin_bundle_dir . 'dein.vim'
            let s:settings.dein_installed = 1
        else
            echohl WarningMsg | echom "You need install git!" | echohl None
        endif
    endif
    exec 'set runtimepath+='.s:settings.plugin_bundle_dir . 'dein.vim'
elseif s:settings.plugin_manager == 'vim-plug'
    "auto install dein
    if (filereadable(expand('~/.vim/autoload/plug.vim')) && ! has('nvim'))
                \|| (filereadable(expand('~/.config/nvim/autoload/plug.vim')) && has('nvim'))
        let s:settings.vim_plug_installed = 1
    else
        if executable('curl')
            exec '!curl -fLo ~/'
                        \ . (has("nvim") ? '.config/nvim' : '.vim')
                        \ . '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            let s:settings.vim_plug_installed = 1
        else
            echohl WarningMsg | echom "You need install curl!" | echohl None
        endif
    endif
endif

"init manager func

fu! s:begin(path)
    if s:settings.plugin_manager == 'neobundle'
        call neobundle#begin(a:path)
    elseif s:settings.plugin_manager == 'dein'
        call dein#begin(a:path)
    elseif s:settings.plugin_manager == 'vim-plug'
        call plug#begin(a:path)
    endif
endf

fu! s:end()
    if s:settings.plugin_manager == 'neobundle'
        call neobundle#end()
        NeoBundleCheck
    elseif s:settings.plugin_manager == 'dein'
        call dein#end()
    elseif s:settings.plugin_manager == 'vim-plug'
        call plug#end()
    endif
endf

fu! s:parser(args)
endf

fu! s:add(repo,...)
    if s:settings.plugin_manager == 'neobundle'
        exec 'NeoBundle "'.a:repo.'"'.','.join(a:000,',')
    elseif s:settings.plugin_manager == 'dein'
        call dein#add(a:repo)
    endif
endf

fu! s:lazyadd(repo,...)
    if s:settings.plugin_manager == 'neobundle'
        exec 'NeoBundleLazy "'.a:repo.'"'.','.join(a:000,',')
    elseif s:settings.plugin_manager == 'dein'
        call dein#add(a:repo)
    endif
endf
fu! s:tap(plugin)
    if s:settings.plugin_manager == 'neobundle'
        return neobundle#tap(a:plugin)
    elseif s:settings.plugin_manager == 'dein'
        return dein#tap(a:plugin)
    endif
endf
fu! s:get_hooks(plugin)
    if s:settings.plugin_manager == 'neobundle'
        return neobundle#get_hooks(a:plugin)
    elseif s:settings.plugin_manager == 'dein'
        return dein#get_hooks(a:plugin)
    endif
endf
fu! s:fetch()
    if s:settings.plugin_manager == 'neobundle'
        NeoBundleFetch 'Shougo/neobundle.vim'
    elseif s:settings.plugin_manager == 'dein'
        call dein#add('Shougo/dein.vim', {'rtp': ''})
    endif
endf

fu! s:enable_plug()
    return s:settings.neobundle_installed || s:settings.dein_installed || (s:settings.vim_plug_installed && 0)
endf

"plugins and config
if s:enable_plug()
    call s:begin(s:settings.plugin_bundle_dir)
    call s:fetch()
    if count(s:settings.plugin_groups, 'core') "{{{
        call s:add('Shougo/vimproc.vim', {
                    \ 'build'   : {
                    \ 'windows' : 'tools\\update-dll-mingw',
                    \ 'cygwin'  : 'make -f make_cygwin.mak',
                    \ 'mac'     : 'make -f make_mac.mak',
                    \ 'linux'   : 'make',
                    \ 'unix'    : 'gmake',
                    \ },
                    \ })
    endif
    if count(s:settings.plugin_groups, 'unite') "{{{
        call s:add('Shougo/unite.vim')
        if s:tap('unite.vim')
            let s:hooks = s:get_hooks('unite.vim')
            func! s:hooks.on_source(bundle) abort
                call unite#custom#source('codesearch', 'max_candidates', 30)
                call unite#filters#matcher_default#use(['matcher_fuzzy'])
                call unite#filters#sorter_default#use(['sorter_rank'])
                call unite#custom#profile('default', 'context', {
                            \   'safe': 0,
                            \   'start_insert': 1,
                            \   'short_source_names': 1,
                            \   'update_time': 500,
                            \   'direction': 'rightbelow',
                            \   'winwidth': 40,
                            \   'winheight': 15,
                            \   'max_candidates': 100,
                            \   'no_auto_resize': 1,
                            \   'vertical_preview': 1,
                            \   'cursor_line_time': '0.10',
                            \   'hide_icon': 0,
                            \   'candidate-icon': ' ',
                            \   'marked_icon': '✓',
                            \   'prompt' : '⮀ '
                            \ })
                call unite#custom#profile('source/neobundle/update', 'context', {
                            \   'start_insert' : 0,
                            \ })
                let g:unite_source_codesearch_ignore_case = 1
                let g:unite_source_file_mru_time_format = "%m/%d %T "
                let g:unite_source_directory_mru_limit = 80
                let g:unite_source_directory_mru_time_format = "%m/%d %T "
                let g:unite_source_file_rec_max_depth = 6
                let g:unite_enable_ignore_case = 1
                let g:unite_enable_smart_case = 1
                let g:unite_data_directory='~/.cache/unite'
                "let g:unite_enable_start_insert=1
                let g:unite_source_history_yank_enable=1
                let g:unite_prompt='>> '
                let g:unite_split_rule = 'botright'
                let g:unite_winheight=25
                let g:unite_source_grep_default_opts = "-iRHn"
                            \ . " --exclude='tags'"
                            \ . " --exclude='cscope*'"
                            \ . " --exclude='*.svn*'"
                            \ . " --exclude='*.log*'"
                            \ . " --exclude='*tmp*'"
                            \ . " --exclude-dir='**/tmp'"
                            \ . " --exclude-dir='CVS'"
                            \ . " --exclude-dir='.svn'"
                            \ . " --exclude-dir='.git'"
                            \ . " --exclude-dir='node_modules'"
                let g:unite_launch_apps = [
                            \ 'rake',
                            \ 'make',
                            \ 'git pull',
                            \ 'git push']
                let g:unite_source_menu_menus = {}
                let g:unite_source_menu_menus.git = {
                            \ 'description' : '            gestionar repositorios git
                            \                            ⌘ [espacio]g',
                            \}
                let g:unite_source_menu_menus.git.command_candidates = [
                            \['▷ tig                                                        ⌘ ,gt',
                            \'normal ,gt'],
                            \['▷ git status       (Fugitive)                                ⌘ ,gs',
                            \'Gstatus'],
                            \['▷ git diff         (Fugitive)                                ⌘ ,gd',
                            \'Gdiff'],
                            \['▷ git commit       (Fugitive)                                ⌘ ,gc',
                            \'Gcommit'],
                            \['▷ git log          (Fugitive)                                ⌘ ,gl',
                            \'exe "silent Glog | Unite quickfix"'],
                            \['▷ git blame        (Fugitive)                                ⌘ ,gb',
                            \'Gblame'],
                            \['▷ git stage        (Fugitive)                                ⌘ ,gw',
                            \'Gwrite'],
                            \['▷ git checkout     (Fugitive)                                ⌘ ,go',
                            \'Gread'],
                            \['▷ git rm           (Fugitive)                                ⌘ ,gr',
                            \'Gremove'],
                            \['▷ git mv           (Fugitive)                                ⌘ ,gm',
                            \'exe "Gmove " input("destino: ")'],
                            \['▷ git push         (Fugitive, salida por buffer)             ⌘ ,gp',
                            \'Git! push'],
                            \['▷ git pull         (Fugitive, salida por buffer)             ⌘ ,gP',
                            \'Git! pull'],
                            \['▷ git prompt       (Fugitive, salida por buffer)             ⌘ ,gi',
                            \'exe "Git! " input("comando git: ")'],
                            \['▷ git cd           (Fugitive)',
                            \'Gcd'],
                            \]
                let g:unite_source_grep_max_candidates = 200
                if executable('hw')
                    " Use hw (highway)
                    " https://github.com/tkengo/highway
                    let g:unite_source_grep_command = 'hw'
                    let g:unite_source_grep_default_opts = '--no-group --no-color'
                    let g:unite_source_grep_recursive_opt = ''
                elseif executable('ag')
                    " Use ag (the silver searcher)
                    " https://github.com/ggreer/the_silver_searcher
                    let g:unite_source_grep_command = 'ag'
                    let g:unite_source_grep_default_opts =
                                \ '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
                                \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
                    let g:unite_source_grep_recursive_opt = ''
                elseif executable('pt')
                    " Use pt (the platinum searcher)
                    " https://github.com/monochromegane/the_platinum_searcher
                    let g:unite_source_grep_command = 'pt'
                    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
                    let g:unite_source_grep_recursive_opt = ''
                elseif executable('ack-grep')
                    " Use ack
                    " http://beyondgrep.com/
                    let g:unite_source_grep_command = 'ack-grep'
                    let g:unite_source_grep_default_opts =
                                \ '-i --no-heading --no-color -k -H'
                    let g:unite_source_grep_recursive_opt = ''
                elseif executable('ack')
                    let g:unite_source_grep_command = 'ack'
                    let g:unite_source_grep_default_opts = '-i --no-heading --no-color -k -H'
                    let g:unite_source_grep_recursive_opt = ''
                elseif executable('jvgrep')
                    " Use jvgrep
                    " https://github.com/mattn/jvgrep
                    let g:unite_source_grep_command = 'jvgrep'
                    let g:unite_source_grep_default_opts = '-i --exclude ''\.(git|svn|hg|bzr)'''
                    let g:unite_source_grep_recursive_opt = '-R'
                endif
                let g:unite_source_rec_async_command =
                            \ ['ag', '--follow', '--nocolor', '--nogroup',
                            \  '--hidden', '-g', '']
                nnoremap <silent><leader>ufa :<C-u>Unite -no-split -buffer-name=Mixed -start-insert file file_mru file_rec buffer<cr>
                nnoremap <silent><leader>ufr :<C-u>Unite -buffer-name=files file_rec/async:!<cr>
                nnoremap <silent><leader>ufg :<C-u>Unite -buffer-name=git-repo file_rec/git<cr>
                call unite#custom#profile('file_rec/async,file_rec/git', 'context', {
                            \   'start_insert' : 1,
                            \   'quit'         : 1,
                            \   'split'        : 1,
                            \   'keep_focus'   : 1,
                            \   'winheight'    : 20,
                            \ })
                call unite#custom#source('file_rec/async', 'ignore_globs',['*.png','.git/','*.ttf'])
                nnoremap <silent><leader>uf  :<C-u>Unite -no-split -buffer-name=files -start-insert file<cr>
                nnoremap <silent><leader>ufm :<C-u>Unite -no-split -buffer-name=mru   -start-insert file_mru<cr>
                nnoremap <silent><leader>ubf :<C-u>Unite -buffer-name=buffer  buffer<cr>
                nnoremap <silent><leader>utb :<C-u>Unite -buffer-name=buffer_tab  buffer_tab<cr>
                call unite#custom#profile('buffer,buffer_tab', 'context', {
                            \   'start_insert' : 0,
                            \   'quit'         : 1,
                            \   'keep_focus'   : 1,
                            \   'winheight'    : 20,
                            \ })
                nnoremap <silent><leader>um  :<C-u>Unite -start-insert mapping<CR>
                nnoremap <C-h>  :<C-u>Unite -start-insert help<CR>
                nnoremap <silent> g<C-h>  :<C-u>UniteWithCursorWord help<CR>
                "" Tag search
                """ For searching the word in the cursor in tag file
                nnoremap <silent><leader>f :<c-u>Unite tag/include:<C-R><C-w><CR>
                nnoremap <silent><leader>ff :<c-u>Unite tag/include -start-insert<CR>
                "" grep dictionay
                """ For searching the word in the cursor in the current directory
                nnoremap <silent><leader>v :Unite -auto-preview -no-split grep:.::<C-R><C-w><CR>
                nnoremap <space>/ :Unite -auto-preview grep:.<cr>
                """ For searching the word handin
                nnoremap <silent><leader>vs :Unite -auto-preview -no-split grep:.<CR>
                """ For searching the word in the cursor in the current buffer
                noremap <silent><leader>vf :Unite -auto-preview -no-split grep:%::<C-r><C-w><CR>
                """ For searching the word in the cursor in all opened buffer
                noremap <silent><leader>va :Unite -auto-preview -no-split grep:$buffers::<C-r><C-w><CR>
                nnoremap <silent> <C-b> :<C-u>Unite -start-insert -buffer-name=buffer buffer<cr>
                "" outline
                nnoremap <silent><leader>o :<C-u>Unite -buffer-name=outline -start-insert -auto-preview -no-split outline<cr>
                "" Line search
                nnoremap <silent><leader>l :Unite line -start-insert  -auto-preview -no-split<CR>
                "" Yank history
                nnoremap <silent><leader>y :<C-u>Unite -no-split -buffer-name=yank history/yank<cr>
                " search plugin
                " :Unite neobundle/search
                "for Unite menu{
                nnoremap <silent><leader>ug :Unite -silent -start-insert menu:git<CR>
                " The prefix key.
                nnoremap    [unite]   <Nop>
                nmap    f [unite]
                nnoremap <silent> [unite]c  :<C-u>UniteWithCurrentDir
                            \ -buffer-name=files buffer bookmark file<CR>
                nnoremap <silent> [unite]b  :<C-u>UniteWithBufferDir
                            \ -buffer-name=files -prompt=%\  buffer bookmark file<CR>
                nnoremap <silent> [unite]r  :<C-u>Unite
                            \ -buffer-name=register register<CR>
                nnoremap <silent> [unite]o  :<C-u>Unite outline<CR>
                nnoremap <silent> [unite]s  :<C-u>Unite session<CR>
                nnoremap <silent> [unite]n  :<C-u>Unite session/new<CR>
                nnoremap <silent> [unite]fr
                            \ :<C-u>Unite -buffer-name=resume resume<CR>
                nnoremap <silent> [unite]ma
                            \ :<C-u>Unite mapping<CR>
                nnoremap <silent> [unite]me
                            \ :<C-u>Unite output:message<CR>
                nnoremap  [unite]f  :<C-u>Unite source<CR>
                nnoremap <silent> [unite]w
                            \ :<C-u>Unite -buffer-name=files -no-split
                            \ jump_point file_point buffer_tab
                            \ file_rec:! file file/new<CR>
            endf
        endif
        call s:add('Shougo/neoyank.vim')
        call s:add('soh335/unite-qflist')
        call s:add('ujihisa/unite-equery')
        call s:add('m2mdas/unite-file-vcs')
        call s:add('Shougo/neomru.vim')
        call s:add('kmnk/vim-unite-svn')
        call s:add('basyura/unite-rails')
        call s:add('nobeans/unite-grails')
        call s:add('choplin/unite-vim_hacks')
        call s:add('mattn/webapi-vim')
        call s:add('mattn/wwwrenderer-vim')
        call s:add('thinca/vim-openbuf')
        call s:add('ujihisa/unite-haskellimport')
        call s:add('oppara/vim-unite-cake')
        call s:add('thinca/vim-ref')
        if s:tap('vim-ref')
            let s:hooks = s:get_hooks('vim-ref')
            func! s:hooks.on_source(bundle) abort
                let g:ref_source_webdict_sites = {
                            \   'je': {
                            \     'url': 'http://dictionary.infoseek.ne.jp/jeword/%s',
                            \   },
                            \   'ej': {
                            \     'url': 'http://dictionary.infoseek.ne.jp/ejword/%s',
                            \   },
                            \   'wiki': {
                            \     'url': 'http://ja.wikipedia.org/wiki/%s',
                            \   },
                            \   'cn': {
                            \     'url': 'http://www.iciba.com/%s',
                            \   },
                            \   'wikipedia:en':{'url': 'http://en.wikipedia.org/wiki/%s',  },
                            \   'bing':{'url': 'http://cn.bing.com/search?q=%s', },
                            \ }
                let g:ref_source_webdict_sites.default = 'cn'
                "let g:ref_source_webdict_cmd='lynx -dump -nonumbers %s'
                "let g:ref_source_webdict_cmd='w3m -dump %s'
                "The filter on the output. Remove the first few lines
                function! g:ref_source_webdict_sites.je.filter(output)
                    return join(split(a:output, "\n")[15 :], "\n")
                endfunction
                function! g:ref_source_webdict_sites.ej.filter(output)
                    return join(split(a:output, "\n")[15 :], "\n")
                endfunction
                function! g:ref_source_webdict_sites.wiki.filter(output)
                    return join(split(a:output, "\n")[17 :], "\n")
                endfunction
                nnoremap <Leader>rj :<C-u>Ref webdict je<Space>
                nnoremap <Leader>re :<C-u>Ref webdict ej<Space>
                nnoremap <Leader>rc :<C-u>Ref webdict cn<Space>
                nnoremap <Leader>rw :<C-u>Ref webdict wikipedia:en<Space>
                nnoremap <Leader>rb :<C-u>Ref webdict bing<Space>
            endf
        endif
        call s:add('heavenshell/unite-zf')
        call s:add('heavenshell/unite-sf2')
        call s:add('Shougo/unite-outline')
        call s:add('hewes/unite-gtags')
        if s:tap('unite-gtags')
            let s:hooks = s:get_hooks('unite-gtags')
            func! s:hooks.on_source(bundle) abort
                nnoremap <leader>gd :execute 'Unite  -auto-preview -start-insert -no-split gtags/def:'.expand('<cword>')<CR>
                nnoremap <leader>gc :execute 'Unite  -auto-preview -start-insert -no-split gtags/context'<CR>
                nnoremap <leader>gr :execute 'Unite  -auto-preview -start-insert -no-split gtags/ref'<CR>
                nnoremap <leader>gg :execute 'Unite  -auto-preview -start-insert -no-split gtags/grep'<CR>
                nnoremap <leader>gp :execute 'Unite  -auto-preview -start-insert -no-split gtags/completion'<CR>
                vnoremap <leader>gd <ESC>:execute 'Unite -auto-preview -start-insert -no-split gtags/def:'.GetVisualSelection()<CR>
                let g:unite_source_gtags_project_config = {
                            \ '_':                   { 'treelize': 0 }
                            \ }
            endf
        endif
        call s:add('rafi/vim-unite-issue')
        call s:add('tsukkee/unite-tag')
        call s:add('ujihisa/unite-launch')
        call s:add('ujihisa/unite-gem')
        call s:add('osyo-manga/unite-filetype')
        call s:add('thinca/vim-unite-history')
        call s:add('Shougo/neobundle-vim-recipes')
        call s:add('Shougo/unite-help')
        call s:add('ujihisa/unite-locate')
        call s:add('kmnk/vim-unite-giti')
        call s:add('ujihisa/unite-font')
        call s:add('t9md/vim-unite-ack')
        call s:add('mileszs/ack.vim')
        call s:add('albfan/ag.vim')
        let g:ag_prg="ag  --vimgrep"
        let g:ag_working_path_mode="r"
        call s:add('dyng/ctrlsf.vim')
        if s:tap('ctrlsf.vim')
            let s:hooks = s:get_hooks('ctrlsf.vim')
            func! s:hooks.on_source(bundle) abort
                nmap <leader>sf <Plug>CtrlSFPrompt
                vmap <leader>sf <Plug>CtrlSFVwordPath
                vmap <leader>sF <Plug>CtrlSFVwordExec
                nmap <leader>sn <Plug>CtrlSFCwordPath
                nmap <leader>sp <Plug>CtrlSFPwordPath
                nnoremap <leader>so :CtrlSFOpen<CR>
                nnoremap <leader>st :CtrlSFToggle<CR>
                inoremap <leader>st <Esc>:CtrlSFToggle<CR>
            endf
        endif
        call s:add('daisuzu/unite-adb')
        call s:add('osyo-manga/unite-airline_themes')
        call s:add('mattn/unite-vim_advent-calendar')
        call s:add('mattn/unite-remotefile')
        call s:add('sgur/unite-everything')
        call s:add('kannokanno/unite-dwm')
        call s:add('raw1z/unite-projects')
        call s:add('voi/unite-ctags')
        call s:add('Shougo/unite-session')
        call s:add('osyo-manga/unite-quickfix')
        call s:add('Shougo/vimfiler')
        if s:tap('vimfiler')
            let s:hooks = s:get_hooks("vimfiler")
            function! s:hooks.on_source(bundle) abort
                let g:vimfiler_as_default_explorer = 1
                let g:vimfiler_restore_alternate_file = 1
                let g:vimfiler_tree_indentation = 1
                let g:vimfiler_tree_leaf_icon = ''
                let g:vimfiler_tree_opened_icon = '▼'
                if WINDOWS()
                    let g:vimfiler_tree_closed_icon = '>'
                else
                    let g:vimfiler_tree_closed_icon = '▷'

                endif
                let g:vimfiler_file_icon = ''
                let g:vimfiler_readonly_file_icon = '*'
                let g:vimfiler_marked_file_icon = '√'
                "let g:vimfiler_preview_action = 'auto_preview'
                let g:vimfiler_ignore_pattern =
                            \ '^\%(\.git\|\.idea\|\.DS_Store\|\.vagrant\|.stversions'
                            \ .'\|node_modules\|.*\.pyc\)$'

                if has('mac')
                    let g:vimfiler_quick_look_command =
                                \ '/Applications//Sublime\ Text.app/Contents/MacOS/Sublime\ Text'
                else
                    let g:vimfiler_quick_look_command = 'gloobus-preview'
                endif

                call vimfiler#custom#profile('default', 'context', {
                            \ 'explorer' : 1,
                            \ 'winwidth' : 30,
                            \ 'winminwidth' : 30,
                            \ 'toggle' : 1,
                            \ 'columns' : 'type',
                            \ 'auto_expand': 1,
                            \ 'direction' : 'rightbelow',
                            \ 'parent': 0,
                            \ 'explorer_columns' : 'type',
                            \ 'status' : 1,
                            \ 'safe' : 0,
                            \ 'split' : 1,
                            \ 'hidden': 1,
                            \ 'no_quit' : 1,
                            \ 'force_hide' : 0,
                            \ })
                autocmd FileType vimfiler call s:vimfilerinit()
                "autocmd VimEnter * if !argc() | VimFiler | endif
                autocmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') |
                            \ q | endif
                function! s:vimfilerinit()
                    set nonumber
                    set norelativenumber
                endf
            endfunction
        endif
        "NeoBundle 'mattn/webapi-vim'
        "NeoBundle 'mattn/googlesuggest-complete-vim'
        "NeoBundle 'mopp/googlesuggest-source.vim'
        call s:add('ujihisa/unite-colorscheme')
        call s:add('mattn/unite-gist')
        "NeoBundle 'klen/unite-radio.vim'
        call s:add('tacroe/unite-mark')
        call s:add('tacroe/unite-alias')
        call s:add('ujihisa/quicklearn')
        call s:add('tex/vim-unite-id')
        call s:add('sgur/unite-qf')
        call s:lazyadd('lambdalisue/unite-grep-vcs', {
                    \ 'autoload': {
                    \    'unite_sources': ['grep/git', 'grep/hg'],
                    \}})
    endif "}}}


    "{{{ctrlpvim settings
    if count(s:settings.plugin_groups, 'ctrlp') "{{{

        call s:add('ctrlpvim/ctrlp.vim')
        call s:add('felixSchl/ctrlp-unity3d-docs')
        call s:add('voronkovich/ctrlp-nerdtree.vim')
        call s:add('elentok/ctrlp-objects.vim')
        call s:add('h14i/vim-ctrlp-buftab')
        call s:add('vim-scripts/ctrlp-cmdpalette')
        call s:add('mattn/ctrlp-windowselector')
        call s:add('the9ball/ctrlp-gtags')
        call s:add('thiderman/ctrlp-project')
        call s:add('mattn/ctrlp-google')
        call s:add('ompugao/ctrlp-history')
        call s:add('pielgrzym/ctrlp-sessions')
        call s:add('tacahiroy/ctrlp-funky')
        call s:add('brookhong/k.vim')
        call s:add('mattn/ctrlp-launcher')
        call s:add('sgur/ctrlp-extensions.vim')
        call s:add('FelikZ/ctrlp-py-matcher')
        call s:add('JazzCore/ctrlp-cmatcher')
        call s:add('ompugao/ctrlp-z')
        let g:ctrlp_map = '<c-p>'
        let g:ctrlp_cmd = 'CtrlP'
        let g:ctrlp_working_path_mode = 'ra'
        let g:ctrlp_root_markers = 'pom.xml'
        let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:25,results:25'
        let g:ctrlp_show_hidden = 1
        "for caching
        let g:ctrlp_use_caching = 1
        let g:ctrlp_clear_cache_on_exit = 0
        let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
        "let g:ctrlp_map = ',,'
        "let g:ctrlp_open_multiple_files = 'v'
        let g:ctrlp_custom_ignore = {
                    \ 'dir':  '\v[\/]\.(git|hg|svn)$|target',
                    \ 'file': '\v\.(exe|so|dll|ttf|png)$',
                    \ 'link': 'some_bad_symbolic_links',
                    \ }
        let g:ctrlp_user_command = ['ag %s -i --nocolor --nogroup --hidden
                    \ --ignore out
                    \ --ignore .git
                    \ --ignore .svn
                    \ --ignore .hg
                    \ --ignore .DS_Store
                    \ --ignore "**/*.pyc"
                    \ -g ""'
                    \ ]

        let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch'  }


        "nnoremap <Leader>kk :CtrlPMixed<Cr>


        " comment for ctrlp-funky {{{
        nnoremap <Leader>fu :CtrlPFunky<Cr>
        " narrow the list down with a word under cursor
        nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
        let g:ctrlp_funky_syntax_highlight = 1
        " }}}

        "for ctrlp_nerdtree {{{
        let g:ctrlp_nerdtree_show_hidden = 1
        "}}}

        "for ctrlp_sessions{{{
        let g:ctrlp_extensions = ['funky', 'sessions' , 'k' , 'tag', 'mixed', 'quickfix', 'undo', 'line', 'changes', 'cmdline', 'menu']
        "}}}


        "for k.vim {{{
        nnoremap <silent> <leader>qe :CtrlPK<CR>
        "}}}

        " for ctrlp-launcher {{{
        nnoremap <Leader>pl :<c-u>CtrlPLauncher<cr>
        "}}}

        ""for ctrlp-cmatcher {{{

        "let g:ctrlp_max_files = 0
        "let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }

        ""}}}

    endif "}}}


    if count(s:settings.plugin_groups, 'autocomplete') "{{{
        call s:add('honza/vim-snippets')
        imap <silent><expr><TAB> MyTabfunc()
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        inoremap <silent> <CR> <C-r>=MyEnterfunc()<Cr>
        inoremap <silent> <Leader><Tab> <C-r>=MyLeaderTabfunc()<CR>
        inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
        inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
        inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
        inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
        if s:settings.autocomplete_method == 'ycm' "{{{
            call s:add('SirVer/ultisnips')
            let g:UltiSnipsExpandTrigger="<tab>"
            let g:UltiSnipsJumpForwardTrigger="<tab>"
            let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
            let g:UltiSnipsSnippetsDir='~/DotFiles/snippets'
            call s:add('ervandew/supertab')
            let g:SuperTabContextDefaultCompletionType = "<c-n>"
            let g:SuperTabDefaultCompletionType = '<C-n>'
            autocmd InsertLeave * if pumvisible() == 0|pclose|endif
            let g:neobundle#install_process_timeout = 1500
            call s:add('Valloric/YouCompleteMe')
            "let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
            "let g:ycm_confirm_extra_conf = 0
            let g:ycm_collect_identifiers_from_tags_files = 1
            let g:ycm_collect_identifiers_from_comments_and_strings = 1
            let g:ycm_key_list_select_completion = ['<C-TAB>', '<Down>']
            let g:ycm_key_list_previous_completion = ['<C-S-TAB>','<Up>']
            let g:ycm_seed_identifiers_with_syntax = 1
            let g:ycm_key_invoke_completion = '<leader><tab>'
            let g:ycm_semantic_triggers =  {
                        \   'c' : ['->', '.'],
                        \   'objc' : ['->', '.'],
                        \   'ocaml' : ['.', '#'],
                        \   'cpp,objcpp' : ['->', '.', '::'],
                        \   'perl' : ['->'],
                        \   'php' : ['->', '::'],
                        \   'cs,javascript,d,python,perl6,scala,vb,elixir,go' : ['.'],
                        \   'java,jsp' : ['.'],
                        \   'vim' : ['re![_a-zA-Z]+[_\w]*\.'],
                        \   'ruby' : ['.', '::'],
                        \   'lua' : ['.', ':'],
                        \   'erlang' : [':'],
                        \ }
        elseif s:settings.autocomplete_method == 'neocomplete' "{{{
            call s:add('Shougo/neocomplete')
            let s:hooks = s:get_hooks("neocomplete")
            function! s:hooks.on_source(bundle) abort
                let g:neocomplete#data_directory='~/.cache/neocomplete'
                let g:acp_enableAtStartup = 0
                let g:neocomplete#enable_at_startup = 1
                " Use smartcase.
                let g:neocomplete#enable_smart_case = 1
                let g:neocomplete#enable_camel_case = 1
                "let g:neocomplete#enable_ignore_case = 1
                let g:neocomplete#enable_fuzzy_completion = 1
                " Set minimum syntax keyword length.
                let g:neocomplete#sources#syntax#min_keyword_length = 3
                let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

                " Define dictionary.
                let g:neocomplete#sources#dictionary#dictionaries = {
                            \ 'default' : '',
                            \ 'vimshell' : $CACHE.'/vimshell/command-history',
                            \ 'java' : '~/.vim/dict/java.dict',
                            \ 'ruby' : '~/.vim/dict/ruby.dict',
                            \ 'scala' : '~/.vim/dict/scala.dict',
                            \ }

                let g:neocomplete#enable_auto_delimiter = 1

                " Define keyword.
                if !exists('g:neocomplete#keyword_patterns')
                    let g:neocomplete#keyword_patterns = {}
                endif
                let g:neocomplete#keyword_patterns._ = '\h\k*(\?'


                " AutoComplPop like behavior.
                let g:neocomplete#enable_auto_select = 0

                if !exists('g:neocomplete#sources#omni#input_patterns')
                    let g:neocomplete#sources#omni#input_patterns = {}
                endif

                let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
                let g:neocomplete#sources#omni#input_patterns.java ='[^. \t0-9]\.\w*'
                let g:neocomplete#force_omni_input_patterns = {}
                "let g:neocomplete#force_omni_input_patterns.java = '^\s*'
                " <C-h>, <BS>: close popup and delete backword char.
                inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
                inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
                inoremap <expr><C-y>  neocomplete#close_popup()
                inoremap <expr><C-e>  neocomplete#cancel_popup()
            endfunction
        elseif s:settings.autocomplete_method == 'neocomplcache' "{{{
            call s:add('Shougo/neocomplcache.vim')
            if s:tap('neocomplcache.vim')
                let s:hooks = s:get_hooks("neocomplcache.vim")
                function! s:hooks.on_source(bundle) abort
                    "---------------------------------------------------------------------------
                    " neocomplache.vim
                    "
                    let g:neocomplcache_enable_at_startup = 1
                    " Use smartcase
                    let g:neocomplcache_enable_smart_case = 1
                    " Use camel case completion.
                    let g:neocomplcache_enable_camel_case_completion = 1
                    " Use underbar completion.
                    let g:neocomplcache_enable_underbar_completion = 1
                    " Use fuzzy completion.
                    let g:neocomplcache_enable_fuzzy_completion = 1

                    " Set minimum syntax keyword length.
                    let g:neocomplcache_min_syntax_length = 3
                    " Set auto completion length.
                    let g:neocomplcache_auto_completion_start_length = 2
                    " Set manual completion length.
                    let g:neocomplcache_manual_completion_start_length = 0
                    " Set minimum keyword length.
                    let g:neocomplcache_min_keyword_length = 3
                    " let g:neocomplcache_enable_cursor_hold_i = v:version > 703 ||
                    "       \ v:version == 703 && has('patch289')
                    let g:neocomplcache_enable_cursor_hold_i = 0
                    let g:neocomplcache_cursor_hold_i_time = 300
                    let g:neocomplcache_enable_insert_char_pre = 1
                    let g:neocomplcache_enable_prefetch = 1
                    let g:neocomplcache_skip_auto_completion_time = '0.6'

                    " For auto select.
                    let g:neocomplcache_enable_auto_select = 1

                    let g:neocomplcache_enable_auto_delimiter = 1
                    let g:neocomplcache_disable_auto_select_buffer_name_pattern =
                                \ '\[Command Line\]'
                    "let g:neocomplcache_disable_auto_complete = 0
                    let g:neocomplcache_max_list = 100
                    let g:neocomplcache_force_overwrite_completefunc = 1
                    if !exists('g:neocomplcache_omni_patterns')
                        let g:neocomplcache_omni_patterns = {}
                    endif
                    if !exists('g:neocomplcache_omni_functions')
                        let g:neocomplcache_omni_functions = {}
                    endif
                    if !exists('g:neocomplcache_force_omni_patterns')
                        let g:neocomplcache_force_omni_patterns = {}
                    endif
                    let g:neocomplcache_enable_auto_close_preview = 1
                    " let g:neocomplcache_force_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
                    let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
                    let g:neocomplcache_omni_patterns.java = '[^. *\t]\.\w*\|\h\w*::'
                    let g:neocomplcache_force_omni_patterns.java = '[^. *\t]\.\w*\|\h\w*::'

                    " For clang_complete.
                    let g:neocomplcache_force_overwrite_completefunc = 1
                    let g:neocomplcache_force_omni_patterns.c =
                                \ '[^.[:digit:] *\t]\%(\.\|->\)'
                    let g:neocomplcache_force_omni_patterns.cpp =
                                \ '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
                    let g:clang_complete_auto = 0
                    let g:clang_auto_select = 0
                    let g:clang_use_library   = 1

                    " Define keyword pattern.
                    if !exists('g:neocomplcache_keyword_patterns')
                        let g:neocomplcache_keyword_patterns = {}
                    endif
                    let g:neocomplcache_keyword_patterns['default'] = '[0-9a-zA-Z:#_]\+'
                    let g:neocomplcache_keyword_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
                    let g:neocomplete#enable_multibyte_completion = 1

                    let g:neocomplcache_vim_completefuncs = {
                                \ 'Ref' : 'ref#complete',
                                \ 'Unite' : 'unite#complete_source',
                                \ 'VimShellExecute' :
                                \      'vimshell#vimshell_execute_complete',
                                \ 'VimShellInteractive' :
                                \      'vimshell#vimshell_execute_complete',
                                \ 'VimShellTerminal' :
                                \      'vimshell#vimshell_execute_complete',
                                \ 'VimShell' : 'vimshell#complete',
                                \ 'VimFiler' : 'vimfiler#complete',
                                \ 'Vinarise' : 'vinarise#complete',
                                \}
                endf
            endif
        elseif s:settings.autocomplete_method == 'deoplete'
            call s:add('Shougo/deoplete.nvim')
            if s:tap('deoplete.nvim')
                let s:hooks = s:get_hooks("deoplete.nvim")
                function! s:hooks.on_source(bundle)
                    let g:deoplete#enable_at_startup = 1
                    let g:deoplete#enable_ignore_case = 1
                    let g:deoplete#enable_smart_case = 1
                    let g:deoplete#enable_refresh_always = 1
                    let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
                    let g:deoplete#omni#input_patterns.java = [
                                \'[^. \t0-9]\.\w*',
                                \'[^. \t0-9]\->\w*',
                                \'[^. \t0-9]\::\w*',
                                \]
                    let g:deoplete#omni#input_patterns.jsp = ['[^. \t0-9]\.\w*']
                    let g:deoplete#ignore_sources = {}
                    let g:deoplete#ignore_sources._ = ['javacomplete2']
                    call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
                    inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
                    inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
                endfunction
            endif
        endif "}}}
        call s:add('Shougo/neco-syntax')
        call s:add('ujihisa/neco-look')
        call s:add('Shougo/neco-vim')
        if !exists('g:necovim#complete_functions')
            let g:necovim#complete_functions = {}
        endif
        let g:necovim#complete_functions.Ref =
                    \ 'ref#complete'
        call s:add('Shougo/context_filetype.vim')
        call s:add('Shougo/neoinclude.vim')
        call s:add('Shougo/neosnippet-snippets')
        call s:add('Shougo/neosnippet.vim')
        if WINDOWS()
            let g:neosnippet#snippets_directory=g:Vimrc_Home .s:Fsep .'snippets'
        else
            let g:neosnippet#snippets_directory='~/DotFiles/snippets'
        endif
        let g:neosnippet#enable_snipmate_compatibility=1
        let g:neosnippet#enable_complete_done = 1
        let g:neosnippet#completed_pairs= {}
        let g:neosnippet#completed_pairs.java = {'(' : ')'}
        call s:add('Shougo/neopairs.vim')
        if g:neosnippet#enable_complete_done
            let g:neopairs#enable = 0
        endif
        imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
    endif "}}}

    if count(s:settings.plugin_groups, 'colorscheme') "{{{
        "colorscheme
        call s:add('morhetz/gruvbox')
        call s:add('mhartington/oceanic-next')
        call s:add('nanotech/jellybeans.vim')
        call s:add('altercation/vim-colors-solarized')
        call s:add('kristijanhusak/vim-hybrid-material')
    endif

    if count(s:settings.plugin_groups, 'chinese') "{{{
        call s:add('vimcn/vimcdoc')
    endif

    if count(s:settings.plugin_groups, 'vim') "{{{
        call s:add('Shougo/vimshell.vim')
    endif
    call s:add('tpope/vim-scriptease')
    call s:add('tpope/vim-fugitive')
    call s:add('tpope/vim-surround')
    call s:add('terryma/vim-multiple-cursors')
    let g:multi_cursor_next_key='<C-j>'
    let g:multi_cursor_prev_key='<C-k>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<Esc>'

    "web plugins

    call s:lazyadd('groenewege/vim-less', {'autoload':{'filetypes':['less']}})
    call s:lazyadd('cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}})
    call s:lazyadd('hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}})
    call s:lazyadd('ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less','styl']}})
    call s:lazyadd('othree/html5.vim', {'autoload':{'filetypes':['html']}})
    call s:lazyadd('wavded/vim-stylus', {'autoload':{'filetypes':['styl']}})
    call s:lazyadd('digitaltoad/vim-jade', {'autoload':{'filetypes':['jade']}})
    call s:lazyadd('juvenn/mustache.vim', {'autoload':{'filetypes':['mustache']}})
    call s:add('Valloric/MatchTagAlways')
    "call s:lazyadd('marijnh/tern_for_vim', {
    "\ 'autoload': { 'filetypes': ['javascript'] },
    "\ 'build': {
    "\ 'mac': 'npm install',
    "\ 'unix': 'npm install',
    "\ 'cygwin': 'npm install',
    "\ 'windows': 'npm install',
    "\ },
    "\ })
    call s:lazyadd('pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}})
    call s:lazyadd('maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript']}})
    nnoremap <leader>fjs :call JsBeautify()<cr>
    call s:lazyadd('leafgarland/typescript-vim', {'autoload':{'filetypes':['typescript']}})
    call s:lazyadd('kchmck/vim-coffee-script', {'autoload':{'filetypes':['coffee']}})
    call s:lazyadd('mmalecki/vim-node.js', {'autoload':{'filetypes':['javascript']}})
    call s:lazyadd('leshill/vim-json', {'autoload':{'filetypes':['javascript','json']}})
    call s:lazyadd('othree/javascript-libraries-syntax.vim', {'autoload':{'filetypes':['javascript','coffee','ls','typescript']}})

    call s:add('artur-shaik/vim-javacomplete2')
    let g:JavaComplete_UseFQN = 1
    let g:JavaComplete_ServerAutoShutdownTime = 300
    let g:JavaComplete_MavenRepositoryDisable = 0
    call s:add('wsdjeg/vim-dict')
    call s:add('wsdjeg/java_getset.vim')
    let s:hooks = s:get_hooks('java_getset.vim')
    function! s:hooks.on_source(bundle)
        let g:java_getset_disable_map = 1
    endfunction
    call s:add('wsdjeg/JavaUnit.vim')
    call s:add('jaxbot/github-issues.vim')
    call s:add('wsdjeg/Mysql.vim')
    let g:JavaUnit_key = "<leader>ooo"
    call s:add('vim-jp/vim-java')
    call s:add('vim-airline/vim-airline')
    call s:add('vim-airline/vim-airline-themes')
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tmuxline#enabled = 1
    if s:tap('vim-airline')
        let s:hooks = s:get_hooks('bling/vim-airline')
        function! s:hooks.on_source(bundle)
            let g:Powerline_sybols = 'unicode'
            set statusline+=%#warningmsg#
            set statusline+=%{SyntasticStatuslineFlag()}
            set statusline+=%*
        endfunction
    endif
    call s:add('mattn/emmet-vim')
    let g:user_emmet_install_global = 0
    let g:user_emmet_leader_key='<C-e>'
    let g:user_emmet_mode='a'
    let g:user_emmet_settings = {
                \  'jsp' : {
                \      'extends' : 'html',
                \  },
                \}
    " use this two command to find how long the plugin take!
    "profile start vim-javacomplete2.log
    "profile! file */vim-javacomplete2/*
    if has('nvim') && s:settings.enable_neomake
        call s:add('wsdjeg/neomake')
        if s:tap('neomake')
            let s:hooks = s:get_hooks('neomake')
            function! s:hooks.on_source(bundle) abort
                let g:neomake_open_list = 2  " 1 open list and move cursor 2 open list without move cursor
                let g:neomake_verbose = 0
            endfunction
        endif
    else
        call s:add('wsdjeg/syntastic')
    endif
    if !filereadable('pom.xml') && !filereadable('build.gradle') && isdirectory('bin')
        let g:syntastic_java_javac_options = '-d bin'
    endif
    let g:syntastic_java_javac_config_file_enabled = 1
    let g:syntastic_java_javac_delete_output = 0
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0
    let g:syntastic_error_symbol = '✖'
    let g:syntastic_warning_symbol = '⚠'
    let g:syntastic_warning_symbol = '➤'
    call s:add('syngan/vim-vimlint', {
                \ 'depends' : 'ynkdir/vim-vimlparser'})
    let g:syntastic_vimlint_options = {
                \'EVL102': 1 ,
                \'EVL103': 1 ,
                \'EVL205': 1 ,
                \'EVL105': 1 ,
                \}
    call s:add('ynkdir/vim-vimlparser')
    call s:add('todesking/vint-syntastic')
    "let g:syntastic_vim_checkers = ['vint']
    call s:add('gcmt/wildfire.vim')
    noremap <SPACE> <Plug>(wildfire-fuel)
    vnoremap <C-SPACE> <Plug>(wildfire-water)
    let g:wildfire_objects = ["i'", 'i"', 'i)', 'i]', 'i}', 'ip', 'it']

    call s:add('scrooloose/nerdcommenter')
    call s:add('easymotion/vim-easymotion')
    call s:add('MarcWeber/vim-addon-mw-utils')
    "NeoBundle 'tomtom/tlib_vim'
    call s:add('mhinz/vim-startify')
    call s:add('mhinz/vim-signify')
    let g:signify_disable_by_default = 0
    let g:signify_line_highlight = 0
    call s:add('airblade/vim-rooter')
    let g:rooter_silent_chdir = 1
    call s:add('Yggdroot/indentLine')
    let g:indentLine_color_term = 239
    let g:indentLine_color_gui = '#09AA08'
    let g:indentLine_char = '¦'
    let g:indentLine_concealcursor = 'niv' " (default 'inc')
    let g:indentLine_conceallevel = 2  " (default 2)
    call s:add('godlygeek/tabular')
    call s:add('benizi/vim-automkdir')
    "[c  ]c  jump between prev or next hunk
    call s:add('airblade/vim-gitgutter')
    call s:add('itchyny/calendar.vim')
    "配合fcitx输入框架,在离开插入模式时自动切换到英文,在同一个缓冲区再次进入插入模式时回复到原来的输入状态
    call s:add('lilydjwg/fcitx.vim')
    call s:add('junegunn/goyo.vim')
    function! s:goyo_enter()
        silent !tmux set status off
        set noshowmode
        set noshowcmd
        set scrolloff=999
        Limelight
    endfunction

    function! s:goyo_leave()
        silent !tmux set status on
        set showmode
        set showcmd
        set scrolloff=5
    endfunction

    autocmd! User GoyoEnter nested call <SID>goyo_enter()
    autocmd! User GoyoLeave nested call <SID>goyo_leave()


    "vim Wimdows config
    "NeoBundle 'scrooloose/nerdtree'
    call s:add('tpope/vim-projectionist')
    call s:add('Xuyuanp/nerdtree-git-plugin')
    call s:add('taglist.vim')
    call s:add('ntpeters/vim-better-whitespace')
    call s:add('junegunn/rainbow_parentheses.vim')
    augroup rainbow_lisp
        autocmd!
        autocmd FileType lisp,clojure,scheme,java RainbowParentheses
    augroup END
    let g:rainbow#max_level = 16
    let g:rainbow#pairs = [['(', ')'], ['[', ']'],['{','}']]
    " List of colors that you do not want. ANSI code or #RRGGBB
    let g:rainbow#blacklist = [233, 234]
    call s:add('majutsushi/tagbar')
    let g:tagbar_width=30
    let g:tagbar_left = 1
    let g:NERDTreeWinPos='right'
    let g:NERDTreeWinSize=31
    let g:NERDTreeChDirMode=1
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    if !executable('ctags')
        let g:Tlist_Ctags_Cmd = '/usr/bin/ctags'  "设置ctags执行路径
    endif
    let g:Tlist_Auto_Update=1
    let g:Tlist_Auto_Open =0
    let g:Tlist_Use_Right_Window=1
    let g:Tlist_Show_One_File=0
    let g:Tlist_File_Fold_Auto_Close=1
    let g:Tlist_Exit_OnlyWindow=1
    let g:Tlist_Show_Menu=1
    noremap <silent> <F8> :TlistToggle<CR>
    "noremap <silent> <F3> :NERDTreeToggle<CR>
    noremap <silent> <F3> :VimFiler<CR>
    autocmd FileType nerdtree nnoremap <silent><Space> :call OpenOrCloseNERDTree()<cr>
    noremap <silent> <F2> :TagbarToggle<CR>
    function! OpenOrCloseNERDTree()
        exec "normal A"
    endfunction
    "}}}

    call s:add('wsdjeg/MarkDown.pl')
    call s:add('wsdjeg/matchit.zip')
    call s:add('tomasr/molokai')
    call s:add('simnalamburt/vim-mundo')
    nnoremap <silent> <F7> :MundoToggle<CR>
    "call s:add('nerdtree-ack')
    call s:add('L9')
    call s:add('TaskList.vim')
    map <unique> <Leader>td <Plug>TaskList
    call s:add('ianva/vim-youdao-translater')
    vnoremap <silent> <C-l> <Esc>:Ydv<CR>
    nnoremap <silent> <C-l> <Esc>:Ydc<CR>
    noremap <leader>yd :Yde<CR>
    call s:add('elixir-lang/vim-elixir')
    call s:add('tyru/open-browser.vim')
    if s:tap('open-brower.vim')
        let s:hooks = s:get_hooks("open-brower.vim")
        function! s:hooks.on_source(bundle)
            "for open-browser {{{
            " This is my setting.
            let g:netrw_nogx = 1 " disable netrw's gx mapping.
            "nmap gx <Plug>(openbrowser-smart-search)
            "vmap gx <Plug>(openbrowser-smart-search)
            "" Open URI under cursor.
            nnoremap go <Plug>(openbrowser-open)
            "" Open selected URI.
            vnoremap go <Plug>(openbrowser-open)
            " Search word under cursor.
            nnoremap gs <Plug>(openbrowser-search)
            " Search selected word.
            vnoremap gs <Plug>(openbrowser-search)
            " If it looks like URI, Open URI under cursor.
            " Otherwise, Search word under cursor.
            nnoremap gx <Plug>(openbrowser-smart-search)
            " If it looks like URI, Open selected URI.
            " Otherwise, Search selected word.
            vnoremap gx <Plug>(openbrowser-smart-search)
            vnoremap gob :OpenBrowser http://www.baidu.com/s?wd=<C-R>=expand("<cword>")<cr><cr>
            nnoremap gob :OpenBrowser http://www.baidu.com/s?wd=<C-R>=expand("<cword>")<cr><cr>
            vnoremap gog :OpenBrowser http://www.google.com/?#newwindow=1&q=<C-R>=expand("<cword>")<cr><cr>
            nnoremap gog :OpenBrowser http://www.google.com/?#newwindow=1&q=<C-R>=expand("<cword>")<cr><cr>
            vnoremap goi :OpenBrowserSmartSearch http://www.iciba.com/<C-R>=expand("<cword>")<cr><cr>
            nnoremap goi :OpenBrowserSmartSearch http://www.iciba.com/<C-R>=expand("<cword>")<cr><cr>
            " In command-line
            ":OpenBrowser http://google.com/
            ":OpenBrowserSearch ggrks
            ":OpenBrowserSmartSearch http://google.com/
            ":OpenBrowserSmartSearch ggrks
            "}}}
        endf
    endif
    call s:end()
endif
filetype plugin indent on
syntax on
"}}}
if count(s:settings.plugin_groups, 'colorscheme')&&s:settings.colorscheme!='' "{{{
    set background=dark
    if s:settings.colorscheme!='' && s:settings.neobundle_installed
        exec 'colorscheme '. s:settings.colorscheme
    else
        exec 'colorscheme '. s:settings.colorscheme_default
    endif
endif

let s:My_vimrc = expand('<sfile>')
function! EditMy_virmc()
    exec "edit ".s:My_vimrc
endf

" basic vim settiing
if has("gui_running")
    set guioptions-=m " 隐藏菜单栏
    set guioptions-=T " 隐藏工具栏
    set guioptions-=L " 隐藏左侧滚动条
    set guioptions-=r " 隐藏右侧滚动条
    set guioptions-=b " 隐藏底部滚动条
    set showtabline=0 " 隐藏Tab栏
endif

" indent use backspace delete indent, eol use backspace delete line at
" begining start delete the char you just typed in if you do not use set
" nocompatible ,you need this
set backspace=indent,eol,start

"显示相对行号
set relativenumber

" 显示行号
set number

" 自动缩进,自动智能对齐
set autoindent
set smartindent
set cindent

" 状态栏预览命令
set wildmenu

"整词换行
set linebreak

"Tab键的宽度
set tabstop=4
"用空格来执行tab
set expandtab
" 统一缩进为4
set softtabstop=4
set shiftwidth=4
"set nobackup
set backup
set undofile
set undolevels=1000
let g:data_dir = $HOME.'/.data/'
let g:backup_dir = g:data_dir . 'backup'
let g:swap_dir = g:data_dir . 'swap'
let g:undo_dir = g:data_dir . 'undofile'
if finddir(g:data_dir) == ''
    silent call mkdir(g:data_dir)
endif
if finddir(g:backup_dir) == ''
    silent call mkdir(g:backup_dir)
endif
if finddir(g:swap_dir) == ''
    silent call mkdir(g:swap_dir)
endif
if finddir(g:undo_dir) == ''
    silent call mkdir(g:undo_dir)
endif
unlet g:backup_dir
unlet g:swap_dir
unlet g:data_dir
unlet g:undo_dir
set undodir=$HOME/.data/undofile
set backupdir=$HOME/.data/backup
set directory=$HOME/.data/swap
set nofoldenable                "关闭自动折叠 折叠按键 'za'
set nowritebackup
set matchtime=0
set ruler
set showcmd						"命令行显示输入的命令
set showmatch					"设置匹配模式,显示匹配的括号
set showmode					"命令行显示当前vim的模式
"menuone: show the pupmenu when only one match
set completeopt=menu,menuone,longest " disable preview scratch window,
set complete=.,w,b,u,t " h: 'complete'
set pumheight=15 " limit completion menu height
set scrolloff=7               "最低显示行数
if s:settings.enable_cursorline == 1
    set cursorline					"显示当前行
endif
if s:settings.enable_cursorcolumn == 1
    set cursorcolumn				"显示当前列
endif
set incsearch
set autowrite
set hlsearch
set laststatus=2
set completeopt=longest,menu
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.class,tags
set wildignorecase
let g:markdown_fenced_languages = ['vim', 'java', 'bash=sh', 'sh', 'html', 'python']
"mapping
"{{{
"全局映射
"也可以通过'za'打开或者关闭折叠
nnoremap <silent><leader><space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
"Super paste it does not work
"ino <C-v> <esc>:set paste<cr>mui<C-R>+<esc>mv'uV'v=:set nopaste<cr>
"对于没有权限的文件使用 :w!!来保存
cnoremap w!! %!sudo tee > /dev/null %


" 映射Ctrl+上下左右来切换窗口
nnoremap <C-Right> <C-W><Right>
nnoremap <C-Left>  <C-W><Left>
nnoremap <C-Up>    <C-W><Up>
nnoremap <C-Down>  <C-W><Down>
if has('nvim')
    tnoremap <C-Right> <C-\><C-n><C-w><Right>
    tnoremap <C-Left>  <C-\><C-n><C-w><Left>
    tnoremap <C-Up>    <C-\><C-n><C-w><Up>
    tnoremap <C-Down>  <C-\><C-n><C-w><Down>
    tnoremap <esc>     <C-\><C-n>
endif

"for buftabs
noremap <Leader>bp :bprev<CR>
noremap <Leader>bn :bnext<CR>

"Quickly add empty lines
nnoremap [<space>  :<c-u>put! =repeat(nr2char(10), v:count1)<cr>
nnoremap ]<space>  :<c-u>put =repeat(nr2char(10), v:count1)<cr>

"Use jk switch to normal model
inoremap jk <esc>

"]e or [e move current line ,count can be useed
nnoremap [e  :<c-u>execute 'move -1-'. v:count1<cr>
nnoremap ]e  :<c-u>execute 'move +'. v:count1<cr>

"Ctrl+Shift+上下移动当前行
nnoremap <C-S-Down> :m .+1<CR>==
nnoremap <C-S-Up> :m .-2<CR>==
inoremap <C-S-Down> <Esc>:m .+1<CR>==gi
inoremap <C-S-Up> <Esc>:m .-2<CR>==gi
"上下移动选中的行
vnoremap <C-S-Down> :m '>+1<CR>gv=gv
vnoremap <C-S-Up> :m '<-2<CR>gv=gv

"for vim-fasd.vim
nnoremap <Leader>z :Z<CR>

"for ctrlp-z
let g:ctrlp_z_nerdtree = 1
let g:ctrlp_extensions = ['Z', 'F']
nnoremap sz :CtrlPZ<Cr>
nnoremap sf :CtrlPF<Cr>

"background
noremap <silent><leader>bg :call ToggleBG()<CR>
"numbers
noremap <silent><leader>nu :call ToggleNumber()<CR>


"autocmds
augroup quick_loc_list
    au!
    au! BufWinEnter quickfix nnoremap <silent> <buffer>
                \	q :cclose<cr>:lclose<cr>
    au! BufWinEnter quickfix if (winnr('$') == 1 ) |
                \   q | endif
augroup END
autocmd FileType jsp call JspFileTypeInit()
autocmd FileType html,css,jsp EmmetInstall
autocmd FileType java call JavaFileTypeInit()
autocmd BufEnter,WinEnter,InsertLeave * set cursorline
autocmd BufLeave,WinLeave,InsertEnter * set nocursorline
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal g`\"" |
            \ endif
autocmd BufNewFile,BufEnter * set cpoptions+=d " NOTE: ctags find the tags file from the current path instead of the path of currect file
autocmd BufEnter * :syntax sync fromstart " ensure every file does syntax highlighting (full)
autocmd BufNewFile,BufRead *.avs set syntax=avs " for avs syntax file.
autocmd FileType text setlocal textwidth=78 " for all text files set 'textwidth' to 78 characters.
autocmd FileType c,cpp,cs,swig set nomodeline " this will avoid bug in my project with namespace ex, the vim will tree ex:: as modeline.
autocmd FileType c,cpp,java,javascript set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f://
autocmd FileType cs set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f:///,f://
autocmd FileType vim set comments=sO:\"\ -,mO:\"\ \ ,eO:\"\",f:\"
autocmd FileType lua set comments=f:--
autocmd FileType python,coffee call s:check_if_expand_tab()
autocmd FileType vim setlocal foldmethod=marker
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd Filetype html setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType xml call XmlFileTypeInit()
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType unite call s:unite_my_settings()
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd BufEnter *
            \   if empty(&buftype)&&has('nvim')
            \|      nnoremap <silent><buffer> <C-]> :call MyTagfunc()<CR>
            \|      nnoremap <silent><buffer> <C-[> :call MyTagfuncBack()<CR>
            \|  else
                \|      nnoremap <silent><buffer> <leader>] :call MyTagfunc()<CR>
                \|      nnoremap <silent><buffer> <leader>[ :call MyTagfuncBack()<CR>
                \|  endif
"}}}

"functions
"{{{
function! OnmiConfigForJsp()
    let pos1 = search("</script>","nb",line("w0"))
    let pos2 = search("<script","nb",line("w0"))
    let pos3 = search("</script>","n",line("w$"))
    let pos4 = search("<script","n",line("w$"))
    let pos0 = line('.')
    if pos1 < pos2 && pos2 < pos0 && pos0 < pos3
        set omnifunc=javascriptcomplete#CompleteJS
        return "\<esc>a."
    else
        set omnifunc=javacomplete#Complete
        return "\<esc>a."
    endif
endf
function! s:unite_my_settings()
    " Overwrite settings.

    " Play nice with supertab
    let b:SuperTabDisabled=1
    " Enable navigation with control-j and control-k in insert mode
    imap <buffer> <C-n>   <Plug>(unite_select_next_line)
    nmap <buffer> <C-n>   <Plug>(unite_select_next_line)
    imap <buffer> <C-p>   <Plug>(unite_select_previous_line)
    nmap <buffer> <C-p>   <Plug>(unite_select_previous_line)


    imap <buffer> jj      <Plug>(unite_insert_leave)
    "imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)

    imap <buffer><expr> j unite#smart_map('j', '')
    imap <buffer> <TAB>   <Plug>(unite_select_next_line)
    imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
    imap <buffer> '     <Plug>(unite_quick_match_default_action)
    nmap <buffer> '     <Plug>(unite_quick_match_default_action)
    imap <buffer><expr> x
                \ unite#smart_map('x', "\<Plug>(unite_quick_match_choose_action)")
    nmap <buffer> x     <Plug>(unite_quick_match_choose_action)
    nmap <buffer> <C-z>     <Plug>(unite_toggle_transpose_window)
    imap <buffer> <C-z>     <Plug>(unite_toggle_transpose_window)
    imap <buffer> <C-y>     <Plug>(unite_narrowing_path)
    nmap <buffer> <C-y>     <Plug>(unite_narrowing_path)
    nmap <buffer> <C-e>     <Plug>(unite_toggle_auto_preview)
    imap <buffer> <C-e>     <Plug>(unite_toggle_auto_preview)
    nmap <buffer> <C-r>     <Plug>(unite_narrowing_input_history)
    imap <buffer> <C-r>     <Plug>(unite_narrowing_input_history)
    nnoremap <silent><buffer><expr> l
                \ unite#smart_map('l', unite#do_action('default'))

    let unite = unite#get_current_unite()
    if unite.profile_name ==# 'search'
        nnoremap <silent><buffer><expr> r     unite#do_action('replace')
    else
        nnoremap <silent><buffer><expr> r     unite#do_action('rename')
    endif

    nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')
    nnoremap <buffer><expr> S      unite#mappings#set_current_filters(
                \ empty(unite#mappings#get_current_filters()) ?
                \ ['sorter_reverse'] : [])

    " Runs "split" action by <C-s>.
    imap <silent><buffer><expr> <C-s>     unite#do_action('split')
endfunction
function! ToggleNumber()
    let s:isThereNumber = &nu
    let s:isThereRelativeNumber = &relativenumber
    if s:isThereNumber && s:isThereRelativeNumber
        set paste!
        set nonumber
        set norelativenumber
    else
        set paste!
        set number
        set relativenumber
    endif
endf
function! ToggleBG()
    let s:tbg = &background
    " Inversion
    if s:tbg == "dark"
        set background=light
    else
        set background=dark
    endif
endfunction
function! BracketsFunc()
    let line = getline('.')
    let col = col('.')
    if line[col - 2] == "]"
        return "{}\<esc>i"
    else
        return "{\<cr>}\<esc>O"
    endif
endf
function! XmlFileTypeInit()
    set omnifunc=xmlcomplete#CompleteTags
    if filereadable("AndroidManifest.xml")
        set dict+=~/.vim/bundle/vim-dict/dict/android_xml.dic
    endif
endf
function! JavaFileTypeInit()
    let b:javagetset_setterTemplate =
                \ "/**\n" .
                \ " * Set %varname%.\n" .
                \ " *\n" .
                \ " * @param %varname% the value to set.\n" .
                \ " */\n" .
                \ "%modifiers% void %funcname%(%type% %varname%){\n" .
                \ "    this.%varname% = %varname%;\n" .
                \ "}"
    let b:javagetset_getterTemplate =
                \ "/**\n" .
                \ " * Get %varname%.\n" .
                \ " *\n" .
                \ " * @return %varname% as %type%.\n" .
                \ " */\n" .
                \ "%modifiers% %type% %funcname%(){\n" .
                \ "    return %varname%;\n" .
                \ "}"
    set omnifunc=javacomplete#Complete
    set tags +=~/others/openjdksrc/java/tags
    set tags +=~/others/openjdksrc/javax/tags
    inoremap <silent> <buffer> <leader>UU <esc>bgUwea
    inoremap <silent> <buffer> <leader>uu <esc>bguwea
    inoremap <silent> <buffer> <leader>ua <esc>bgulea
    inoremap <silent> <buffer> <leader>Ua <esc>bgUlea
    nmap <silent><buffer> <F4> <Plug>(JavaComplete-Imports-Add)
    imap <silent><buffer> <F4> <Plug>(JavaComplete-Imports-Add)
endf
function! WSDAutoComplete(char)
    if(getline(".")=~?'^\s*.*\/\/')==0
        let line = getline('.')
        let col = col('.')
        if a:char == "."
            return a:char."\<c-x>\<c-o>\<c-p>"
        elseif line[col - 2] == " "||line[col -2] == "("||line[col - 2] == ","
            return a:char."\<c-x>\<c-o>\<c-p>"
        elseif line[col - 3] == " "&&line[col - 2] =="@"
            return a:char."\<c-x>\<c-o>\<c-p>"
        else
            return a:char
        endif
    else
        "bug exists
        let col = col('.')
        normal ma
        let [commentline,commentcol] = searchpos('//','b',line('.'))
        normal `a
        if commentcol == 0
            return a:char."\<c-x>\<c-o>\<c-p>"
        else
            return "\<Right>".a:char
        endif
    endif
endf
function! ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf

function! CloseBracket()
    if match(getline(line('.') + 1), '\s*}') < 0
        return "\<CR>}"
    else
        return "\<Esc>j0f}a"
    endif
endf

function! QuoteDelim(char)
    let line = getline('.')
    let col = col('.')
    if line[col - 2] == "\\"
        "Inserting a quoted quotation mark into the string
        return a:char
    elseif line[col - 1] == a:char
        "Escaping out of the string
        return "\<Right>"
    else
        "Starting a string
        return a:char.a:char."\<Esc>i"
    endif
endf
function! JspFileTypeInit()
    set tags+=/home/wsdjeg/others/openjdk-8-src/tags
    set omnifunc=javacomplete#Complete
    inoremap . <c-r>=OnmiConfigForJsp()<cr>
    nnoremap <F4> :JCimportAdd<cr>
    inoremap <F4> <esc>:JCimportAddI<cr>
endfunction
function! s:check_if_expand_tab()
    let has_noexpandtab = search('^\t','wn')
    let has_expandtab = search('^    ','wn')

    "
    if has_noexpandtab && has_expandtab
        let idx = inputlist ( ['ERROR: current file exists both expand and noexpand TAB, python can only use one of these two mode in one file.\nSelect Tab Expand Type:',
                    \ '1. expand (tab=space, recommended)',
                    \ '2. noexpand (tab=\t, currently have risk)',
                    \ '3. do nothing (I will handle it by myself)'])
        let tab_space = printf('%*s',&tabstop,'')
        if idx == 1
            let has_noexpandtab = 0
            let has_expandtab = 1
            silent exec '%s/\t/' . tab_space . '/g'
        elseif idx == 2
            let has_noexpandtab = 1
            let has_expandtab = 0
            silent exec '%s/' . tab_space . '/\t/g'
        else
            return
        endif
    endif

    "
    if has_noexpandtab == 1 && has_expandtab == 0
        echomsg 'substitute space to TAB...'
        set noexpandtab
        echomsg 'done!'
    elseif has_noexpandtab == 0 && has_expandtab == 1
        echomsg 'substitute TAB to space...'
        set expandtab
        echomsg 'done!'
    else
        " it may be a new file
        " we use original vim setting
    endif
endfunction

function! MyTagfunc() abort
    mark H
    let s:MyTagfunc_flag = 1
    UniteWithCursorWord -immediately tag
endfunction

function! MyTagfuncBack() abort
    if exists('s:MyTagfunc_flag')&&s:MyTagfunc_flag
        exe "normal! `H"
        let s:MyTagfunc_flag =0
    endif
endfunction

function! MyEnterfunc() abort
    if pumvisible()
        if getline('.')[col('.') - 2]=="{"
            return "\<Enter>"
        elseif s:settings.autocomplete_method == 'neocomplete'||s:settings.autocomplete_method == 'deoplete'
            return "\<C-y>"
        else
            return "\<esc>a"
        endif
    elseif getline('.')[col('.') - 2]=="{"&&getline('.')[col('.')-1]=="}"
        return "\<Enter>\<esc>ko"
    else
        return "\<Enter>"
    endif
endf

function! MyLeaderTabfunc() abort
    if s:settings.autocomplete_method == 'deoplete'
        return deoplete#mappings#manual_complete(['omni'])
    elseif s:settings.autocomplete_method == 'neocomplete'
        return neocomplete#start_manual_complete(['omni'])
    endif
endfunction

function! MyTabfunc() abort
    if getline('.')[col('.')-2] =='{'&& pumvisible()
        return "\<C-n>"
    endif
    if neosnippet#expandable() && getline('.')[col('.')-2] =='(' && !pumvisible()
        return "\<Plug>(neosnippet_expand)"
    elseif neosnippet#jumpable() && getline('.')[col('.')-2] =='(' && !pumvisible() && !neosnippet#expandable()
        return "\<plug>(neosnippet_jump)"
    elseif neosnippet#expandable_or_jumpable() && getline('.')[col('.')-2] !='('
        return "\<plug>(neosnippet_expand_or_jump)"
    elseif pumvisible()
        return "\<C-n>"
    else
        return "\<tab>"
    endif
endfunction



if filereadable(expand('~/.config/nvim/autoload/plug.vim'))
    call plug#begin('~/.cache/vim-plug')
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/gv.vim'
    "for fzf
    nnoremap <Leader>fz :FZF<CR>
    if !has('nvim')
        Plug 'junegunn/vim-github-dashboard'
    endif
    call plug#end()
endif


"============> plug.vim
set mouse=
set hidden
if has('nvim')
    augroup Terminal
        au!
        au TermOpen * let g:last_terminal_job_id = b:terminal_job_id
        au WinEnter term://* startinsert
    augroup END
    if s:settings.enable_neomake
        augroup Neomake_wsd
            au!
            autocmd! BufWritePost * Neomake
        augroup END
    endif
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    " dark0 + gray
    let g:terminal_color_0 = "#282828"
    let g:terminal_color_8 = "#928374"

    " neurtral_red + bright_red
    let g:terminal_color_1 = "#cc241d"
    let g:terminal_color_9 = "#fb4934"

    " neutral_green + bright_green
    let g:terminal_color_2 = "#98971a"
    let g:terminal_color_10 = "#b8bb26"

    " neutral_yellow + bright_yellow
    let g:terminal_color_3 = "#d79921"
    let g:terminal_color_11 = "#fabd2f"

    " neutral_blue + bright_blue
    let g:terminal_color_4 = "#458588"
    let g:terminal_color_12 = "#83a598"

    " neutral_purple + bright_purple
    let g:terminal_color_5 = "#b16286"
    let g:terminal_color_13 = "#d3869b"

    " neutral_aqua + faded_aqua
    let g:terminal_color_6 = "#689d6a"
    let g:terminal_color_14 = "#8ec07c"

    " light4 + light1
    let g:terminal_color_7 = "#a89984"
    let g:terminal_color_15 = "#ebdbb2"
endif

func! Openpluginrepo()
    try
        exec "normal! ".'"ayi'."'"
        exec 'OpenBrowser https://github.com/'.@a
    catch
        echohl WarningMsg | echomsg "can not open the web of current plugin" | echohl None
    endtry
endf

function! s:GetVisual()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][:col2 - 2]
    let lines[0] = lines[0][col1 - 1:]
    return lines
endfunction

function! REPLSend(lines)
    call jobsend(g:last_terminal_job_id, add(a:lines, ''))
endfunction
" }}}
" Commands {{{
" REPL integration {{{
command! -range=% REPLSendSelection call REPLSend(s:GetVisual())
command! REPLSendLine call REPLSend([getline('.')])
" }}}
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.  Only define it when not
" defined already.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
            \ | wincmd p | diffthis
" }}}
