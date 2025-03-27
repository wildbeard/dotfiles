vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Do you have a nerd font installed
vim.g.have_nerd_font = true

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.mouse = 'a'
-- Show status or not
vim.g.showmode = false

-- Will need testing
vim.opt.breakindent = true

-- Search
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldnestmax = 10
vim.opt.foldlevel = 20
-- @todo: Gives error
-- vim.opt.nofoldenable = true

-- Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- NerdTree
vim.keymap.set('n', '<leader>nt', ':NERDTreeToggle<cr>', { desc = 'Open NerdTree' })
vim.keymap.set('n', '<leader>nf', ':NERDTreeFind<cr>', { desc = 'Find current file in NerdTree' })

-- Buffer Movement
vim.keymap.set('n', '<C-h>', ':bprev<cr>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<C-l>', ':bnext<cr>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Page up and center' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Page down and center' })

-- Copilot
vim.g.copilot_no_tab_complete = true
vim.keymap.set('i', '<C-Space>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
vim.keymap.set('n', '<M-.>', '<Plug>(copilot-suggest)')

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'preservim/nerdtree',
  'vim-airline/vim-airline',
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'burntsushi/ripgrep',
      'nvim-telescope/telescope-ui-select.nvim',
      {
        'nvim-tree/nvim-web-devicons',
        enabled = vim.g.have_nerd_font,
      },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>ff', builtin.find_files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<leader>fb', builtin.buffers)
      vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols)
      vim.keymap.set('n', '<leader>ch', '<cmd>:noh<cr>')
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gd', vim.lsp.buf.definition, 'Go to definition')
          map('gD', vim.lsp.buf.declaration, 'Go to declaration')
          map('gr', vim.lsp.buf.rename, 'Rename')
          map('ga', vim.lsp.buf.code_action, 'Code Action')
          map('fr', vim.lsp.buf.references, 'Find References')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        gopls = {},
        cssls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
        tsserver = {
          filetypes = { 'vue', 'javascript', 'typescript', 'typescriptreact' },
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location =
                '/home/press/.local/share/nvim/mason/packages/vue-language-server/node_modules/@vue/language-server', -- vue_language_server_path,
                languages = { 'vue' },
              },
            },
          },
        },
        volar = {},
        intelephense = {},
        tailwindcss = {},
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -- 'stylua',
        'volar',
        'goimports',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      notify_on_error = true,
      format_on_save = function()
        return {
          async = true,
          timeout_ms = 2500,
          lsp_fallback = true,
        }
      end,
      formatters_by_ft = {
        go = { 'goimports' },
        lua = { 'stylua' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        vue = { 'prettierd', 'eslint_d' },
      },
    },
  },
  {
    'catppuccin/nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'html', 'lua', 'php', 'markdown', 'css', 'scss' },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      rainbow = {
        enable = true,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          ['<C-k>'] = cmp.mapping.select_next_item(),
          ['<C-j>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, {
            'i',
            's',
          }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {
            'i',
            's',
          }),
          -- scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<CR>'] = cmp.mapping.confirm { select = true },

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  'mfussenegger/nvim-lint',
  'github/copilot.vim',
}

-- Testing GDScript
require('lspconfig')['gdscript'].setup({
  name = 'Godot',
  -- cmd = { 'ncat', '1270.0.0.1', '6005' },
  -- command = { 'ncat', '1270.0.0.1', '6005' },
  command = { 'godot-wsl-lsp', '--host', '127.0.0.1', '6004' },
})

require('lint').linters_by_ft = {
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  vue = { 'eslint_d' },
}

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('InsertLeave', {
  desc = 'Attempt to Lint when leaving Insert',
  group = augroup('insert-leave-lint', { clear = true }),
  callback = function()
    require('lint').try_lint()
  end,
})

autocmd('Filetype', {
  desc = 'Auto Indents PHP',
  group = augroup('filetype-php', { clear = true }),
  pattern = { 'php' },
  command = 'setlocal ts=4 sw=4 sts=4 autoindent',
})

autocmd('Filetype', {
  desc = 'Sets a column at 80 chars for Prettier formatting',
  group = augroup('filetype-php', { clear = true }),
  pattern = { 'vue', 'javascript', 'typescript', 'typescriptreact' },
  command = 'setlocal colorcolumn=80',
})

-- This was causing Vue to not format properly
--autocmd('BufWritePre', {
--  desc = 'Auto formatting',
--  group = augroup('all-file-format', { clear = true }),
--  pattern = { '*' },
--  callback = function()
--    if vim.bo.filetype == 'vue' then
--      return
--    end
--
--    vim.lsp.buf.format()
--  end,
--})
