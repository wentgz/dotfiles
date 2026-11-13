" =============================================================================
" Search
" =============================================================================

" Show search matches while typing the search pattern.
set incsearch

" Highlight all matches of the current search pattern.
set hlsearch

" Show the number of search matches, e.g. [1/5].
set shortmess-=S

" Ignore case when searching by default.
set ignorecase

" Make searches case-sensitive if the pattern contains uppercase letters.
" Example: /hello is case-insensitive, while /Hello is case-sensitive.
set smartcase

" Folding config
set foldmethod=indent " can set to 'syntax' if want to fold by {} / []
set foldlevel=99

" =============================================================================
" Indentation
" =============================================================================

" Number of spaces used for each indentation level.
set shiftwidth=2

" Display a tab character as 2 columns wide.
set tabstop=2

" Insert spaces instead of actual tab characters.
set expandtab


" =============================================================================
" Files
" =============================================================================

" Do not create backup files before overwriting a file.
set nobackup


" =============================================================================
" Editor UI
" =============================================================================

" Keep at least 10 lines visible above and below the cursor when possible.
set scrolloff=10

" Show partially typed commands in the bottom-right corner.
set showcmd

" Show the current mode, e.g. -- INSERT -- or -- VISUAL --.
" set showmode

" Briefly jump to the matching bracket when inserting ), ], or }.
set showmatch

" Show an enhanced command-line completion menu.
set wildmenu

" Complete commands to the longest common match and show all candidates.
set wildmode=list:longest

" Show relative line numbers for easier movement with commands like 5j or 8k.
set relativenumber

" Also show the absolute line number for the current line.
set number

" Highlight cursorline
set cursorline

" =============================================================================
" History
" =============================================================================

" Keep up to 1000 commands and search patterns in history.
set history=1000

" Sync with system clipboard.
set clipboard=unnamedplus

" =============================================================================
" File-type-specific settings
" =============================================================================

" YAML files use 2-space indentation and never use hard tabs.
autocmd FileType yaml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType yml  setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" Makefiles require actual tab characters for recipe commands.
autocmd FileType make setlocal noexpandtab tabstop=2 shiftwidth=2

" Use spaces and two-space indentation for shell scripts
autocmd FileType sh setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" C/C++: use spaces and two-space indentation.
" F5: build optimized binary and run it.
" F6: build debug binary and launch GDB.
augroup c_cpp_settings
  autocmd!
  autocmd FileType c,cpp setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType c,cpp nnoremap <buffer> <F5> :<C-u>call CBuildAndLaunch(0)<CR>
  autocmd FileType c,cpp nnoremap <buffer> <F6> :<C-u>call CBuildAndLaunch(1)<CR>
augroup END

" =============================================================================
" Custom functions
" =============================================================================

" Build and run the current C/C++ source, or launch it in GDB.
function! CBuildAndLaunch(debug)
  if !has('terminal')
    echoerr 'Your Vim was not built with +terminal.'
    return
  endif

  if empty(expand('%:p'))
    echoerr 'Save file before compile!'
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
    echoerr 'Only support .c, .cpp, .cc hoặc .cxx.'
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
  call term_start(['bash', '-lc', l:cmd], {'curwin': 1})
  startinsert
endfunction

" =============================================================================
" Key mappings
" =============================================================================

" <Leader>g: Show detailed information about the current file and cursor position.
nnoremap <leader>g 1<C-g>

" Ctrl-N: Toggle both absolute and relative line numbers.
nnoremap <C-n> :set invnumber invrelativenumber<CR>

" <Esc><Esc>: Turn off current highlight search.
nnoremap <Esc><Esc> :nohlsearch<CR>

" Remove all leading whitespace from the selected lines.
xnoremap <leader>0 :s/^\s*//<CR>

" Run the current Go file.
command! GoRun write | execute '!go run ' . shellescape(expand('%:p'))

" <Leader>t: Open a terminal.
nnoremap <leader>t :terminal<CR>

" =============================================================================
" Plugins (vim-plug)
" =============================================================================

" Plugins installed with vim-plug are stored in ~/.vim/plugged.
if filereadable(expand('~/.vim/autoload/plug.vim'))
	call plug#begin('~/.vim/plugged')
		
		Plug 'junegunn/fzf'
		Plug 'junegunn/fzf.vim'
		Plug 'itchyny/lightline.vim'
		Plug 'jonathanfilip/vim-lucius'

	call plug#end()
endif


" Run ShellCheck while editing shell scripts
let g:ale_linters = {
      \ 'sh': ['shellcheck'],
      \ }

" Use shfmt when running :ALEFix
let g:ale_fixers = {
      \ 'sh': ['shfmt'],
      \ }
let g:ale_sh_shfmt_options = '-i 2'

" Bash: save and run the current script with F5
autocmd FileType sh nnoremap <buffer> <F5> :w<CR>:!bash %<CR>

" Bash: format the current buffer with F7
autocmd FileType sh nnoremap <buffer> <F7> :ALEFix<CR>

colorscheme lucius
set background=dark
hi CursorLine cterm=underline

" Status bar
set laststatus=2
set noshowmode
let g:lightline = { 'colorscheme': 'deus' }
