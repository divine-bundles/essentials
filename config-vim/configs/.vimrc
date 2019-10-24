":title:        Divine asset sample: .vimrc
":author:       Grove Pyree
":email:        grayarea@protonmail.ch
":revdate:      2019.06.30
":revremark:    Release version
":created_at:   2019.04.11

" --- vim-plug {{{1
" Install vim-plug if it isn't there already
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Initialize vim-plug
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
" Make sure you use single quotes

" https://github.com/tpope/vim-sensible
Plug 'tpope/vim-sensible'

" https://github.com/w0ng/vim-hybrid
" Plug 'w0ng/vim-hybrid'

" https://github.com/justinmk/vim-sneak
Plug 'justinmk/vim-sneak'

" https://github.com/junegunn/fzf.vim
" Plug '/usr/local/opt/fzf'
" Plug 'junegunn/fzf.vim'

" https://github.com/vim-airline/vim-airline
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

" https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'

" https://github.com/tpope/vim-eunuch
Plug 'tpope/vim-eunuch'

" https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround'

" https://github.com/terryma/vim-multiple-cursors
Plug 'terryma/vim-multiple-cursors'

" https://github.com/scrooloose/nerdtree
Plug 'scrooloose/nerdtree'

" https://github.com/editorconfig/editorconfig-vim
Plug 'editorconfig/editorconfig-vim'

" https://github.com/mattn/emmet-vim
Plug 'https://github.com/mattn/emmet-vim'

" https://github.com/w0rp/ale
Plug 'w0rp/ale'

" https://github.com/airblade/vim-gitgutter
Plug 'airblade/vim-gitgutter'

" https://github.com/plasticboy/vim-markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" Initialize plugin system
call plug#end()
" }}}


" --- Features {{{1
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on

" Fold portions of document on markers
set foldmethod=marker

" Open all folds on file open
au BufWinEnter * normal zR

" Color of folded marker background
hi Folded ctermbg=DarkGray
" }}}

" --- Must Have Options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
set nomodeline
" }}}

" --- Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=r

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on mappings and even quicker on keycodes
set timeout ttimeout timeoutlen=500 ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>
" }}}

" --- Wrapping options {{{1
" 
" Text wrapping and toggling of it

" Wrap on words
set wrap linebreak nolist

" Do not wrap long lines when pasted
set textwidth=0

" Do not wrap long lines when typed
set wrapmargin=0

" Arrow keys move cursor across display lines, not actual lines
" Unused. gk & gj are better for navigating within a line.
" noremap <Up> gk
" noremap <Down> gj
" inoremap <Up> <C-o>gk
" inoremap <Down> <C-o>gj

" Easy wrap toggle
command! -nargs=* Wrap set wrap! wrap?

" Fancy wrap toggle
noremap <Space>w :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Wrap OFF"
    set nowrap
  else
    echo "Wrap ON"
    set wrap linebreak nolist
  endif
endfunction

" --- Spelling {{{1

set spell spelllang=en

" }}}


" }}}

" --- Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
"set shiftwidth=4
"set tabstop=4
" }}}

" --- Commands {{{1
"
" Custom commands

" }}}

" --- Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Quick exit from Insert mode
inoremap yy <ESC>

" Breaking the habit of arrow keys
" inoremap <up> <nop>
" inoremap <down> <nop>
" inoremap <left> <nop>
" inoremap <right> <nop>
" vnoremap <up> <nop>
" vnoremap <down> <nop>
" vnoremap <left> <nop>
" vnoremap <right> <nop>
" }}}

" --- Tabs, windows & splits {{{1
"
" Options for working with multiple files

" Make splits appear intuitively below and to the right
set splitbelow splitright
" }}}

" --- Plugins {{{1
"
" Plugin-specific config

" https://github.com/w0ng/vim-hybrid
" set background=dark
" colorscheme hybrid

" https://github.com/junegunn/fzf.vim
map ; :Files<CR>

" https://github.com/scrooloose/nerdtree
map <C-o> :NERDTreeToggle<CR>

" https://github.com/vim-airline/vim-airline
" let g:airline_powerline_fonts = 1
" let g:airline_solarized_bg='dark'

" }}}

" --- Before write {{{1
"
" Auto-create parent directories on save (if they don't exist)

" https://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save

function s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" }}}

" --- Shifted mode {{{1
"
" For english language Ctrl+^ will toggle Shifted mode, which simulates always 
" pressed shift button

" http://vim.wikia.com/wiki/Insert-mode_only_Caps_Lock

" Lock search keymap to be the same as insert mode
set imsearch=-1
" Load the keymap
set keymap=shifted
" Turn it off by default
set iminsert=0

" Kill the Shifted mode when leaving insert mode
autocmd InsertLeave * set iminsert=0

" Use 'jj' in insert mode for quick Shift'ing
inoremap jj <C-^>

" The cursor color changes when Shifted is on
:highlight Cursor guifg=NONE guibg=Green
:highlight lCursor guifg=NONE guibg=Cyan

" }}}
