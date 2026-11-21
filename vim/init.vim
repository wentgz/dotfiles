-- =============================================================================
-- Search
-- =============================================================================

-- Show matches while typing a search pattern.
vim.opt.incsearch = true

-- Highlight all matches of the current search pattern.
vim.opt.hlsearch = true

-- Show the number of search matches, such as [1/5].
vim.opt.shortmess:remove("S")

-- Ignore case unless the search pattern contains an uppercase letter.
vim.opt.ignorecase = true
vim.opt.smartcase = true


-- =============================================================================
-- Indentation
-- =============================================================================

-- Use two spaces for each indentation level.
vim.opt.shiftwidth = 2

-- Display tabs as two columns wide.
vim.opt.tabstop = 2

-- Insert spaces instead of tab characters.
vim.opt.expandtab = true


-- =============================================================================
-- Folding
-- =============================================================================

-- Fold code based on indentation.
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99


-- =============================================================================
-- Editor behavior
-- =============================================================================

-- Do not create backup files before overwriting a file.
vim.opt.backup = false

-- Keep at least 10 screen lines visible above and below the cursor.
vim.opt.scrolloff = 10

-- Show partially typed commands in the command area.
vim.opt.showcmd = true

-- Briefly highlight the matching bracket.
vim.opt.showmatch = true

-- Enable the command-line completion menu.
vim.opt.wildmenu = true

-- Complete to the longest match and show the available choices.
vim.opt.wildmode = "list:longest"

-- Keep up to 1000 commands and search patterns in history.
vim.opt.history = 1000

-- Use the system clipboard for Neovim's unnamed register.
vim.opt.clipboard = "unnamedplus"

-- Enable mouse support in all modes.
vim.opt.mouse = "a"


-- =============================================================================
-- Line numbers and cursor
-- =============================================================================

-- Show relative line numbers and the absolute number on the current line.
vim.opt.number = true
vim.opt.relativenumber = true

-- Highlight the line containing the cursor.
vim.opt.cursorline = true


-- =============================================================================
-- File type settings
-- =============================================================================

local filetype_settings = vim.api.nvim_create_augroup(
  "FileTypeSettings",
  { clear = true }
)

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Makefiles require tab characters for recipe commands.
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "sh",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})


-- =============================================================================
-- Build and run
-- =============================================================================

local function c_build_and_run()
  local src = vim.fn.expand("%:p")

  -- Save the file before building it.
  if src == "" then
    vim.notify("Save the file before running it.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update")

  -- Select the compiler and language standard from the file extension.
  local ext = vim.fn.expand("%:e"):lower()
  local compiler
  local standard

  if ext == "c" then
    compiler = "gcc"
    standard = "-std=c17"
  elseif vim.tbl_contains({ "cpp", "cc", "cxx" }, ext) then
    compiler = "g++"
    standard = "-std=c++17"
  else
    vim.notify(
      "Supported extensions: .c, .cpp, .cc, .cxx",
      vim.log.levels.ERROR
    )
    return
  end

  local dir = vim.fn.expand("%:p:h")
  local outdir = dir .. "/out"
  local exe = outdir .. "/" .. vim.fn.expand("%:t:r") .. ".out"

  -- Create the output directory if it does not exist.
  vim.fn.mkdir(outdir, "p")

  -- Build and run the program from the source file's directory.
  local cmd = "cd " .. vim.fn.shellescape(dir)
    .. " && printf '\\n========== OUTPUT ==========\\n'"
    .. " && " .. compiler .. " " .. standard
    .. " -Wall -Wextra -O2"
    .. " -o " .. vim.fn.shellescape(exe)
    .. " " .. vim.fn.shellescape(src)
    .. " && " .. vim.fn.shellescape(exe)

  vim.cmd("!" .. cmd)
end

local function go_build_and_run()
  local src = vim.fn.expand("%:p")

  -- Save the file before building it.
  if src == "" then
    vim.notify("Save the file before running it.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update")

  local dir = vim.fn.expand("%:p:h")
  local outdir = dir .. "/out"

  -- Create the output directory if it does not exist.
  vim.fn.mkdir(outdir, "p")

  -- Build the Go module when go.mod exists; otherwise build this file.
  local target
  local name

  if vim.fn.findfile("go.mod", dir .. ";") ~= "" then
    target = "."
    name = vim.fn.fnamemodify(dir, ":t")
  else
    target = vim.fn.shellescape(src)
    name = vim.fn.expand("%:t:r")
  end

  local exe = outdir .. "/" .. name .. ".out"
  local cmd = "cd " .. vim.fn.shellescape(dir)
    .. " && go build -o " .. vim.fn.shellescape(exe)
    .. " " .. target
    .. " && " .. vim.fn.shellescape(exe)

  vim.cmd("!" .. cmd)
end


-- =============================================================================
-- Build and run key mappings
-- =============================================================================

local run_code = vim.api.nvim_create_augroup("RunCodeWithF5", { clear = true })

-- Press F5 to build and run C or C++ files.
vim.api.nvim_create_autocmd("FileType", {
  group = run_code,
  pattern = { "c", "cpp" },
  callback = function(event)
    vim.keymap.set("n", "<F5>", c_build_and_run, {
      buffer = event.buf,
      desc = "Build and run C/C++",
    })
  end,
})

-- Press F5 to build and run Go files.
vim.api.nvim_create_autocmd("FileType", {
  group = run_code,
  pattern = "go",
  callback = function(event)
    vim.keymap.set("n", "<F5>", go_build_and_run, {
      buffer = event.buf,
      desc = "Build and run Go",
    })
  end,
})

-- Press F5 to save and run shell scripts with Bash.
vim.api.nvim_create_autocmd("FileType", {
  group = run_code,
  pattern = "sh",
  callback = function(event)
    vim.keymap.set("n", "<F5>", function()
      vim.cmd("write")
      local src = vim.fn.expand("%:p")
      vim.cmd("!" .. "bash " .. vim.fn.shellescape(src))
    end, {
      buffer = event.buf,
      desc = "Save and run shell script",
    })
  end,
})

-- Press F7 to format shell scripts with ALE.
vim.api.nvim_create_autocmd("FileType", {
  group = run_code,
  pattern = "sh",
  callback = function(event)
    vim.keymap.set("n", "<F7>", "<cmd>ALEFix<CR>", {
      buffer = event.buf,
      desc = "Format shell script with ALE",
    })
  end,
})


-- =============================================================================
-- General key mappings
-- =============================================================================

-- <Leader>g: Show detailed information about the current file and cursor.
vim.keymap.set("n", "<leader>g", "1<C-g>", {
  desc = "Show file and cursor information",
})

-- Ctrl-N: Toggle absolute and relative line numbers.
vim.keymap.set("n", "<C-n>", "<cmd>set invnumber invrelativenumber<CR>", {
  desc = "Toggle line numbers",
})

-- Esc twice: Clear the current search highlighting.
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", {
  desc = "Clear search highlighting",
})

-- <Leader>0: Remove leading whitespace from the selected lines.
vim.keymap.set("x", "<leader>0", ":s/^\\s*//<CR>", {
  desc = "Remove leading whitespace",
})

-- <Leader>t: Open a terminal window.
vim.keymap.set("n", "<leader>t", "<cmd>terminal<CR>", {
  desc = "Open terminal",
})


-- =============================================================================
-- Go command
-- =============================================================================

-- :GoRun: Save and run the current Go file.
vim.api.nvim_create_user_command("GoRun", function()
  local src = vim.fn.expand("%:p")

  if src == "" then
    vim.notify("Save the file before running it.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("write")
  vim.cmd("!" .. "go run " .. vim.fn.shellescape(src))
end, {
  desc = "Save and run the current Go file",
})


-- =============================================================================
-- Plugins
-- =============================================================================

-- Find vim-plug in Neovim's data directory.
local plug_path = vim.fn.stdpath("data") .. "/site/autoload/plug.vim"
local plug_dir = vim.fn.stdpath("data") .. "/plugged"

-- If vim-plug is only installed for Vim, reuse its existing installation
-- and plugin directory.
if vim.fn.filereadable(plug_path) == 0 then
  local vim_plug_path = vim.fn.expand("~/.vim/autoload/plug.vim")

  if vim.fn.filereadable(vim_plug_path) == 1 then
    plug_path = vim_plug_path
    plug_dir = vim.fn.expand("~/.vim/plugged")
  end
end

if vim.fn.filereadable(plug_path) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(plug_path))
  vim.fn["plug#begin"](plug_dir)

  vim.cmd("Plug 'junegunn/fzf'")
  vim.cmd("Plug 'junegunn/fzf.vim'")
  vim.cmd("Plug 'itchyny/lightline.vim'")
  vim.cmd("Plug 'jonathanfilip/vim-lucius'")

  vim.fn["plug#end"]()
end


-- =============================================================================
-- ALE
-- =============================================================================

-- Run ShellCheck on shell scripts.
vim.g.ale_linters = {
  sh = { "shellcheck" },
}

-- Use shfmt when running :ALEFix.
vim.g.ale_fixers = {
  sh = { "shfmt" },
}

-- Indent shell scripts with two spaces when formatting.
vim.g.ale_sh_shfmt_options = "-i 2"


-- =============================================================================
-- Colors and status line
-- =============================================================================

-- The colorscheme comes from vim-lucius.
pcall(vim.cmd, "colorscheme lucius")
vim.opt.background = "dark"

-- Underline the current cursor line.
vim.cmd("highlight CursorLine cterm=underline")

-- Always show the status line.
vim.opt.laststatus = 2

-- Let lightline display the status line without Neovim's built-in mode text.
vim.opt.showmode = false
vim.g.lightline = {
  colorscheme = "deus",
}