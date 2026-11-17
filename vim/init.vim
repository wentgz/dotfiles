" =============================================================================
" Search and folding
" =============================================================================
set incsearch
set hlsearch
set shortmess-=S
set ignorecase
set smartcase

set foldmethod=indent
set foldlevel=99

" =============================================================================
" Indentation
" =============================================================================
set shiftwidth=2
set tabstop=2
set expandtab

" =============================================================================
" Files and history
" =============================================================================
set nobackup
set history=1000

" Use the system clipboard for yank, delete, and paste.
" Requires a working Neovim clipboard provider.
set clipboard=unnamedplus

" =============================================================================
" Editor UI
" =============================================================================
set scrolloff=10
set showcmd
set showmatch
set wildmenu
set wildmode=list:longest
set relativenumber
set number
set cursorline
set laststatus=2
set noshowmode

" =============================================================================
" File-type-specific settings
" =============================================================================
augroup filetype_settings
  autocmd!
  autocmd FileType yaml,yml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType make setlocal noexpandtab tabstop=2 shiftwidth=2
  autocmd FileType sh setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
augroup END

" =============================================================================
" C/C++ build and run
" =============================================================================
function! CBuildAndLaunch(debug) abort
  if empty(expand('%:p'))
    echoerr 'Save the file before compiling!'
    return
  endif

  if &modified
    write
  endif

  let l:ext = tolower(expand('%:e'))
  let l:targets = {
        \ 'c':   {'compiler': 'gcc', 'standard': '-std=c17'},
        \ 'cpp': {'compiler': 'g++', 'standard': '-std=c++17'},
        \ 'cc':  {'compiler': 'g++', 'standard': '-std=c++17'},
        \ 'cxx': {'compiler': 'g++', 'standard': '-std=c++17'},
        \ }

  let l:target = get(l:targets, l:ext, {})

  if empty(l:target)
    echoerr 'Only .c, .cpp, .cc, and .cxx files are supported.'
    return
  endif

  let l:src = expand('%:p')
  let l:dir = expand('%:p:h')
  let l:exe = expand('%:p:r') . '.out'

  if a:debug
    let l:flags = '-Wall -Wextra -O0 -g'
    let l:launch_cmd = 'gdb --args ' . shellescape(l:exe)
  else
    let l:flags = '-Wall -Wextra -O2'
    let l:launch_cmd = shellescape(l:exe)
  endif

  let l:compile_cmd = printf(
        \ '%s %s %s %s -o %s',
        \ l:target.compiler,
        \ l:target.standard,
        \ l:flags,
        \ shellescape(l:src),
        \ shellescape(l:exe))

  let l:cmd = printf(
        \ 'cd %s && %s && %s',
        \ shellescape(l:dir),
        \ l:compile_cmd,
        \ l:launch_cmd)

  botright 12new
  call termopen(['bash', '-lc', l:cmd])
  startinsert
endfunction

augroup c_cpp_settings
  autocmd!
  autocmd FileType c,cpp setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType c,cpp nnoremap <buffer> <F5> :<C-u>call CBuildAndLaunch(0)<CR>
  autocmd FileType c,cpp nnoremap <buffer> <F6> :<C-u>call CBuildAndLaunch(1)<CR>
augroup END

" =============================================================================
" Key mappings and commands
" =============================================================================
nnoremap <leader>g 1<C-g>
nnoremap <C-n> :set invnumber invrelativenumber<CR>
nnoremap <Esc><Esc> :nohlsearch<CR>
xnoremap <leader>0 :s/^\s*//<CR>

command! GoRun write | execute '!go run ' . shellescape(expand('%:p'))
nnoremap <leader>t :terminal<CR>

" Bash: save and run the current script with F5.
autocmd FileType sh nnoremap <buffer> <F5> :w<CR>:!bash %<CR>

" =============================================================================
" Plugins (vim-plug)
" =============================================================================
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')

  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'jonathanfilip/vim-lucius'
  Plug 'dense-analysis/ale'

  call plug#end()
endif

" ALE: ShellCheck and shfmt
let g:ale_linters = {
      \ 'sh': ['shellcheck'],
      \ }

let g:ale_fixers = {
      \ 'sh': ['shfmt'],
      \ }

let g:ale_sh_shfmt_options = '-i 2'

autocmd FileType sh nnoremap <buffer> <F7> :ALEFix<CR>

" =============================================================================
" Colors and statusline
" =============================================================================
set background=dark
colorscheme lucius
highlight CursorLine cterm=underline

let g:lightline = { 'colorscheme': 'deus' }