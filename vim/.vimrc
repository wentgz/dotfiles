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
set showmode

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


" =============================================================================
" File-type-specific settings
" =============================================================================

" YAML files use 2-space indentation and never use hard tabs.
autocmd FileType yaml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType yml  setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" Makefiles require actual tab characters for recipe commands.
set noexpandtab
autocmd FileType make setlocal noexpandtab tabstop=2 shiftwidth=2


" =============================================================================
" Custom functions
" =============================================================================

" Toggle syntax highlighting on or off.
function! ToggleSyntax()
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
  endif
endfunction


" =============================================================================
" Key mappings
" =============================================================================

" F6: Toggle syntax highlighting.
nnoremap <F6> :call ToggleSyntax()<CR>

" <Leader>g: Show detailed information about the current file and cursor position.
nnoremap <leader>g 1<C-g>

" Ctrl-N: Toggle both absolute and relative line numbers.
nnoremap <C-n> :set invnumber invrelativenumber<CR>

" <Leader>h: Toggle search highlighting.
nnoremap <leader>h :set hlsearch!<CR>

" =============================================================================
" Plugins (vim-plug)
" =============================================================================

" Plugins installed with vim-plug are stored in ~/.vim/plugged.
if filereadable(expand('~/.vim/autoload/plug.vim'))
	call plug#begin('~/.vim/plugged')
		
		" Plug 'author/plugin-name'
		Plug 'junegunn/fzf'
		Plug 'junegunn/fzf.vim'
		Plug 'chriskempson/base16-vim'
		Plug 'itchyny/lightline.vim'

	call plug#end()
endif

colorscheme base16-chalk
let base16colorspace=256
set termguicolors
set laststatus=2
set noshowmode
