syntax on
set relativenumber
set nu
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nohlsearch
set hidden
set scrolloff=8
set signcolumn=yes
set matchpairs+=<:>
set ignorecase

" Folding
" set foldmethod=indent
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldnestmax=10
set nofoldenable
set foldlevel=20

call plug#begin()
   Plug 'preservim/nerdtree'
   " Plug 'gruvbox-community/gruvbox'
   Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
   " Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
   Plug 'neovim/nvim-lspconfig'
   Plug 'williamboman/nvim-lsp-installer'
   Plug 'nvim-lua/plenary.nvim'
   Plug 'nvim-telescope/telescope.nvim'
   Plug 'mattn/efm-langserver'
   Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
   Plug 'hrsh7th/cmp-nvim-lsp'
   Plug 'hrsh7th/cmp-buffer'
   Plug 'hrsh7th/cmp-path'
   Plug 'hrsh7th/cmp-cmdline'
   Plug 'hrsh7th/nvim-cmp'
   Plug 'hrsh7th/vim-vsnip'
   Plug 'hrsh7th/vim-vsnip-integ'
   Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
   Plug 'kyazdani42/nvim-web-devicons'
   Plug 'nvim-telescope/telescope-fzy-native.nvim'
   Plug 'tpope/vim-fugitive'
   Plug 'StanAngeloff/php.vim'
   Plug 'stephpy/vim-php-cs-fixer'
   Plug 'jwalton512/vim-blade'
   Plug 'noahfrederick/vim-laravel'
   Plug 'vim-airline/vim-airline'
   Plug 'tpope/vim-surround'
   Plug 'mfussenegger/nvim-dap'
   Plug 'rcarriga/nvim-dap-ui'
   Plug 'theHamsta/nvim-dap-virtual-text'
   Plug 'nathanaelkane/vim-indent-guides'
   Plug 'ThePrimeagen/harpoon'
   Plug 'ellisonleao/glow.nvim'
   Plug 'mfussenegger/nvim-lint'
   Plug 'mhartington/formatter.nvim'
call plug#end()

let g:catppuccin_flavour = 'mocha'
colorscheme catppuccin
" colorscheme gruvbox
" colorscheme tokyonight
" let g:tokyonight_style = "night"
" let g:tokyonight_dark_sidebar = "true"

set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list=['exact', 'substring', 'fuzzy']

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2

lua require('telescope').load_extension('fzy_native')
lua require'nvim-web-devicons'.setup{}
lua require('dap.ext.vscode').load_launchjs()
lua require('nvim-dap-virtual-text').setup({ highlight_changed_variables = true,  highlight_new_as_changed = true, commented = true })
lua require('glow').setup({ style = "dark", width = 120 })

let mapleader = " "
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fs :lua require'telescope.builtin'.lsp_document_symbols{}<cr>
nnoremap <leader>ch <cmd>:noh<cr>

" Harpoon
nnoremap <leader>hm :lua require'harpoon.ui'.toggle_quick_menu()<cr>
nnoremap <leader>hh :lua require'harpoon.ui'.nav_prev()<cr>
nnoremap <leader>hl :lua require'harpoon.ui'.nav_next()<cr>
nnoremap <leader>ha :lua require'harpoon.mark'.add_file()<cr>
nnoremap <leader>hd :lua require'harpoon.mark'.rm_file()<cr>
" NerdTree
nnoremap <leader>nt :NERDTreeToggle<cr>
nnoremap <leader>nf :NERDTreeFind<cr>

nnoremap <C-h> :bprev<cr>
nnoremap <C-l> :bnext<cr>
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F6> :lua require'dap'.terminate()<CR>
nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>

let mapleader = " "
nnoremap <leader>dui :lua require'dapui'.toggle()<CR>
nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>

" Autocmds
autocmd FileType php setlocal ts=4 sw=4 sts=4 autoindent
autocmd FileType vue,javascript,typescript setlocal colorcolumn=100

au InsertLeave * lua require('lint').try_lint()
au BufWritePost * FormatWrite
