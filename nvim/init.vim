syntax on
set relativenumber
set nu
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nohlsearch
set hidden
set scrolloff=8
set signcolumn=yes
set matchpairs+=<:>

call plug#begin()
   Plug 'preservim/nerdtree'
   Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
   Plug 'gruvbox-community/gruvbox'
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
   Plug 'jose-elias-alvarez/null-ls.nvim'
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
call plug#end()

colorscheme gruvbox

set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list=['exact', 'substring', 'fuzzy']

let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

lua require'lspconfig'.vuels.setup{}
lua require('telescope').load_extension('fzy_native')
lua require'nvim-web-devicons'.setup{}
lua require('dapui').setup()
lua require('dap.ext.vscode').load_launchjs()
lua require('nvim-dap-virtual-text').setup()

let mapleader = " "
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <Leader>ch <cmd>:noh<cr>

nnoremap <C-h> :bprev<cr>
nnoremap <C-l> :bnext<cr>
nnoremap <C-n> :NERDTreeToggle<cr>

nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>

let mapleader = " "
nnoremap <leader>dui :lua require'dapui'.toggle()<CR>
nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
