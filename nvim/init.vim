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

call plug#begin()
   Plug 'preservim/nerdtree'
   Plug 'fatih/vim-go'
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
   Plug 'jose-elias-alvarez/null-ls.nvim'
   Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
call plug#end()

colorscheme gruvbox

set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list=['exact', 'substring', 'fuzzy']

lua require'lspconfig'.vuels.setup{}
lua require'lspconfig'.intelephense.setup{ init_options = { licenseKey = "00GEQR961O987WT" } }

let mapleader = " "
nnoremap <leader>ff <cmd>Telescope find_files<cr>

