" =============================================================================
" Search
" =============================================================================

" Show matches while typing a search pattern.
set incsearch

" Highlight all matches of the current search pattern.
set hlsearch

" Show the number of search matches, such as [1/5].
set shortmess-=S

" Ignore case unless the search pattern contains an uppercase letter.
set ignorecase
set smartcase


" =============================================================================
" Indentation
" =============================================================================

" Use two spaces for each indentation level.
set shiftwidth=2

" Display tabs as two columns wide.
set tabstop=2

" Insert spaces instead of tab characters.
set expandtab


" =============================================================================
" Folding
" =============================================================================

" Fold code based on indentation.
" Change this to "syntax" to fold according to language syntax.
set foldmethod=indent
set foldlevel=99


" =============================================================================
" Editor behavior
" =============================================================================

" Do not create backup files before overwriting a file.
set nobackup

" Keep at least 10 screen lines visible above and below the cursor.
set scrolloff=10

" Show partially typed commands in the command area.
set showcmd

" Briefly highlight the matching bracket.
set showmatch

" Enable the command-line completion menu.
set wildmenu

" Complete to the longest match and show the available choices.
set wildmode=list:longest

" Keep up to 1000 commands and search patterns in history.
set history=1000

" Use the system clipboard for Vim's unnamed register.
set clipboard=unnamedplus

" Enable mouse support in all modes.
set mouse=a


" =============================================================================
" Line numbers and cursor
" =============================================================================

" Show relative line numbers and the absolute number on the current line.
set number
set relativenumber

" Highlight the line containing the cursor.
set cursorline


" =============================================================================
" Terminal mouse support
" =============================================================================

" Use SGR mouse reporting when running inside screen or tmux.
if !has('gui_running') && &term =~# '^\%(screen\|tmux\)'
  set ttymouse=sgr
endif


" =============================================================================
" File type settings
" =============================================================================

augroup file_type_settings
  autocmd!

  " Use two spaces for YAML files.
  autocmd FileType yaml,yml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

  " Makefiles require tab characters for recipe commands.
  autocmd FileType make setlocal noexpandtab tabstop=2 shiftwidth=2

  " Use two spaces for shell scripts.
  autocmd FileType sh setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

  " Use two spaces for C and C++ files.
  autocmd FileType c,cpp setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
augroup END


" =============================================================================
" Build and run
" =============================================================================

function! CBuildAndRun()
  " Save the file before building it.
  if empty(expand('%:p'))
    echoerr 'Save the file before running it.'
    return
  endif

  update

  " Select the compiler and language standard from the file extension.
  let l:ext = tolower(expand('%:e'))
  if l:ext ==# 'c'
    let l:compiler = 'gcc'
    let l:standard = '-std=c17'
  elseif index(['cpp', 'cc', 'cxx'], l:ext) >= 0
    let l:compiler = 'g++'
    let l:standard = '-std=c++17'
  else
    echoerr 'Supported extensions: .c, .cpp, .cc, .cxx'
    return
  endif

  let l:src = expand('%:p')
  let l:dir = expand('%:p:h')
  let l:outdir = l:dir . '/out'
  let l:exe = l:outdir . '/' . expand('%:t:r') . '.out'

  " Create the output directory if it does not exist.
  call mkdir(l:outdir, 'p')

  " Build and run the program from the source file's directory.
  let l:cmd = 'cd ' . shellescape(l:dir)
        \ . ' && printf "\n========== OUTPUT ==========\n"'
        \ . ' && ' . l:compiler . ' ' . l:standard
        \ . ' -Wall -Wextra -O2 -o ' . shellescape(l:exe)
        \ . ' ' . shellescape(l:src)
        \ . ' && ' . shellescape(l:exe)

  execute '!' . l:cmd
endfunction

function! GoBuildAndRun()
  " Save the file before building it.
  if empty(expand('%:p'))
    echoerr 'Save the file before running it.'
    return
  endif

  update

  let l:src = expand('%:p')
  let l:dir = expand('%:p:h')
  let l:outdir = l:dir . '/out'

  " Create the output directory if it does not exist.
  call mkdir(l:outdir, 'p')

  " Build the Go module when go.mod exists; otherwise build this file.
  if !empty(findfile('go.mod', l:dir . ';'))
    let l:target = '.'
    let l:name = fnamemodify(l:dir, ':t')
  else
    let l:target = shellescape(l:src)
    let l:name = expand('%:t:r')
  endif

  let l:exe = l:outdir . '/' . l:name . '.out'
  let l:cmd = 'cd ' . shellescape(l:dir)
        \ . ' && go build -o ' . shellescape(l:exe) . ' ' . l:target
        \ . ' && ' . shellescape(l:exe)

  execute '!' . l:cmd
endfunction


" =============================================================================
" Build and run key mappings
" =============================================================================

augroup run_code_with_f5
  autocmd!

  " Press F5 to build and run C or C++ files.
  autocmd FileType c,cpp nnoremap <buffer> <F5> :<C-u>call CBuildAndRun()<CR>

  " Press F5 to build and run Go files.
  autocmd FileType go nnoremap <buffer> <F5> :<C-u>call GoBuildAndRun()<CR>

  " Press F5 to save and run shell scripts with Bash.
  autocmd FileType sh nnoremap <buffer> <F5> :w<CR>:!bash %<CR>

  " Press F7 to format shell scripts with ALE.
  autocmd FileType sh nnoremap <buffer> <F7> :ALEFix<CR>
augroup END


" =============================================================================
" General key mappings
" =============================================================================

" <Leader>g: Show detailed information about the current file and cursor.
nnoremap <leader>g 1<C-g>

" Ctrl-N: Toggle absolute and relative line numbers.
nnoremap <C-n> :set invnumber invrelativenumber<CR>

" Esc twice: Clear the current search highlighting.
nnoremap <Esc><Esc> :nohlsearch<CR>

" <Leader>0: Remove leading whitespace from the selected lines.
xnoremap <leader>0 :s/^\s*//<CR>

" <Leader>t: Open a terminal window.
nnoremap <leader>t :terminal<CR>


" =============================================================================
" Go command
" =============================================================================

" :GoRun: Save and run the current Go file.
command! GoRun write | execute '!go run ' . shellescape(expand('%:p'))


" =============================================================================
" Plugins
" =============================================================================

" Load vim-plug and plugins when vim-plug is installed.
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')

  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'jonathanfilip/vim-lucius'

  call plug#end()
endif


" =============================================================================
" ALE
" =============================================================================

" Run ShellCheck on shell scripts.
let g:ale_linters = {
      \ 'sh': ['shellcheck'],
      \ }

" Use shfmt when running :ALEFix.
let g:ale_fixers = {
      \ 'sh': ['shfmt'],
      \ }

" Indent shell scripts with two spaces when formatting.
let g:ale_sh_shfmt_options = '-i 2'


" =============================================================================
" Colors and status line
" =============================================================================

colorscheme lucius
set background=dark

" Underline the current cursor line.
highlight CursorLine cterm=underline

" Always show the status line.
set laststatus=2

" Let lightline display the status line without Vim's built-in mode text.
set noshowmode
let g:lightline = { 'colorscheme': 'deus' }