" vim:foldmethod=marker
if has('vim_starting')
    set nocompatible
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

" Bundles {{{
NeoBundle 'morhetz/gruvbox'

NeoBundle 'altercation/vim-colors-solarized'

NeoBundle 'geoffharcourt/one-dark.vim'

NeoBundle 'Lokaltog/vim-distinguished'

NeoBundle 'vim-airline/vim-airline'

NeoBundle 'vim-airline/vim-airline-themes'

NeoBundle 'scrooloose/syntastic'

NeoBundle 'SirVer/ultisnips'

NeoBundle 'kien/ctrlp.vim'

NeoBundle 'tpope/vim-sensible'

NeoBundle 'edkolev/tmuxline.vim'

NeoBundle 'tpope/vim-fugitive'

NeoBundle 'int3/vim-extradite'

NeoBundle 'rking/ag.vim'

NeoBundle 'tmhedberg/SimpylFold'

NeoBundle 'tomtom/tcomment_vim.git'

NeoBundle 'hynek/vim-python-pep8-indent'

NeoBundle 'bkad/CamelCaseMotion'

NeoBundle 'groenewege/vim-less.git'

NeoBundle 'itchyny/calendar.vim'

NeoBundle 'xolox/vim-notes'

NeoBundle 'xolox/vim-misc'

NeoBundle 'KeitaNakamura/neodark.vim'
" }}}

call neobundle#end()

NeoBundleCheck

filetype plugin indent on

" Mappings {{{
let mapleader = ","
inoremap jk <Esc>
" Search for visually selected text
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'
" CamelCase motions
map <leader>w <plug>CamelCaseMotion_w
map <leader>b <plug>CamelCaseMotion_b
map <leader>e <plug>CamelCaseMotion_e
" Use S to stamp yanked text over current word
nnoremap S "_diwP
" Edit config files
nnoremap <leader>ev :e $MYVIMRC<cr>
nnoremap <leader>eg :e ~/.gitconfig<cr>
nnoremap <leader>ez :e ~/.zshrc<cr>
nnoremap <leader>et :e ~/.tmux.conf<cr>
" Source .vimrc
nnoremap <leader>sv :so $MYVIMRC<cr>
" Switch buffer easier
nnoremap <silent> <leader># :b#<cr>
" Close buffer without closing window
nnoremap <silent> <leader>dd :b#<cr>:bd#<cr>
" CrtlP
nnoremap <leader>p :CtrlPCurWD<cr>
" Directory navigation
nnoremap <leader>cd :lcd %:p:h<cr>:pwd<cr>
" Browse directory of file in current buffer
nnoremap <leader>ex :Explore<cr>
" Ag
nnoremap <leader>g :Ag ""<left>
let g:ag_mapping_message=0
" run make silently and go to first error
nnoremap <leader>m :silent make\|redraw!\|cc<CR>
" Rebuild ctags
nnoremap <silent> <F5> :echo "Rebuilding tags..."<cr>:! ctags -R .<cr>:echo "Rebuilt tags"<cr>
" Set background
nnoremap <leader>l :set background=light<cr>
nnoremap <leader>d :set background=dark<cr>
" Yank and paste between tmux windows
vnoremap <leader>y :'<,'>w! ~/.vimclip<cr>
nnoremap <leader>p :r ~/.vimclip<cr>
" }}}


" Options {{{
syntax on " Turn on syntax highlighting

set smartindent
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set number
set laststatus=2
set autowrite           " Automatically save buffer
set number
set incsearch
set scrolloff=3         " keep 3 lines when scrolling
set showcmd             " display incomplete commands
set nobackup            " do not keep a backup file
set nowritebackup
set noswapfile
set hlsearch            " highlight searches
set showmatch           " jump to matches when entering regexp
set ignorecase          " ignore case when searching
set smartcase           " no ignorecase if Uppercase char present
set encoding=utf-8
" set autochdir           " always set workingdir to current file's
set backspace=indent,eol,start

"
" Easiear copy paste to system clipboard
"
set clipboard=unnamed

"
" Patterns to ignore for ctrlp etc.
"
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.so,*.o,*.pyc
set wildignore+=*/node_modules/*,*/bower_components/*,*/venv/*,*/Python34/*

"
" CrtlP options
"
let g:ctrlp_use_caching = 0
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -oc --exclude-standard'] 
let g:ctrlp_working_path_mode = ''

"
" Ultisnips options
"
let g:UltiSnipsSnippetsDir="~/.vim/ultisnips"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"
" Calendar options
"
let g:calendar_google_calendar = 1
let g:calendar_google_task = 1
let g:calendar_first_day = "monday"

" }}}

" Python Settings {{{
let g:pymode_python = 'python3'
let g:syntastic_python_python_exec = '/usr/bin/python3'
let g:syntastic_python_checkers = ['python', 'flake8', 'pep8', 'pyflakes']
"
"
" Syntastic options
"
let g:syntastic_enable_signs = 1
let g:syntastic_error_symbol = "☣"
let g:syntastic_warning_symbol = "☠"
let g:syntastic_style_error_symbol = "💩"
let g:syntastic_style_warning_symbol = "✗"
let g:syntastic_always_populate_loc_list = 1

augroup filetype_python
    autocmd!
    autocmd FileType python setlocal colorcolumn=80
    " We don't need smartindent in python. Makes comments always go to 
    " the start of the line.
    autocmd FileType python setlocal nosmartindent
augroup END

" {{{ Functions for running unit tests in python
function! RunAllTests()
    silent ! echo -e "\033[1;36mRunning all unit tests\033[0m"
    set makeprg=nosetests\ --with-describe-it\ --with-terseout %:p
    exec "make!"
endfunction

function! JumpToError()
    if getqflist() != []
        for error in getqflist()
            if error['valid']
                break
            endif
        endfor
        let error_message = substitute(error['text'], '^ *', '', 'g')
        silent cc!
        if error['bufnr'] != 0
            exec ":sbuffer " . error['bufnr']
        endif
        call RedBar()
        echo error_message
    else
        call GreenBar()
        echo "All tests passed"
    endif
endfunction

function! RedBar()
    hi RedBar ctermfg=white ctermbg=red guibg=red
    echohl RedBar
    echon repeat(" ",&columns - 1)
    echohl None
endfunction

function! GreenBar()
    hi GreenBar ctermfg=white ctermbg=green guibg=green
    echohl GreenBar
    echon repeat(" ",&columns - 1)
    echohl None
endfunction"

nnoremap <leader>a :call RunAllTests()<cr>:redraw<cr>:call JumpToError()<cr>

" }}}
" }}}

" Appearance {{{

set background=light
colorscheme solarized

" set background=dark
" colorscheme neodark

" set background=dark
" colorscheme onedark

" set background=light
" colorscheme gruvbox

let g:airline_powerline_fonts = 1
" let g:airline_theme='onedark'
" let g:airline_theme='neodark'
let g:airline_theme='solarized'

if has('gui_running')
    set guioptions-=m
    set guioptions-=T "remove toolbar
    set guioptions-=r "remove right-hand scroll bar
    set guioptions-=L "remove left-hand scroll bar. Fix for TagBar.

    if has('win32') || has('win64')
        set guifont=Source_Code_Pro_Medium:h10:cANSI
    elseif has('macunix') || has('unix')
        set guifont=Source\ Code\ Pro\ Medium\ 10
    endif

    set list                " Display special characters (e.g. trailing whitespace)
    set listchars=tab:??,trail:?

    augroup trailing
        au!
        au InsertEnter * :set listchars-=trail:?
        au InsertLeave * :set listchars+=trail:?
    augroup END

else
    "
    " Make vim display colors and fonts properly in terminal windows (conemu)
    "
    if has("win32unix")
        set term=xterm-256color
        let &t_ti.="\e[1 q"
        let &t_SI.="\e[5 q"
        let &t_EI.="\e[1 q"
        let &t_te.="\e[0 q"       
        set t_ut=
    else
        set termencoding=ut8
        set term=xterm
        set t_Co=256
        let &t_AB="\e[48;5;%dm"
        let &t_AF="\e[38;5;%dm"
        let &t_ZH="\e[3m"
    endif
    
endif

if &background == 'light'
    highlight CursorLine cterm=NONE ctermbg=LightGray ctermfg=NONE
else
    highlight CursorLine cterm=NONE ctermbg=4 ctermfg=NONE
endif
" }}}
