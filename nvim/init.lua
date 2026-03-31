--[[
  NOTES
  brew install ripgrep
  npm i -g tree-sitter-install
  npm i -g @vue/language-server
  npm i -g eslint_d
  npm i -g @fsouza/prettierd
  npm i -g typescript typescript-language-server
  JetBrainsMono Nerd Font, need to set this as the font to use in the terminal
]]
--

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Do you have a nerd font installed
vim.g.have_nerd_font = true

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.mouse = "a"
-- Show status or not
vim.g.showmode = false

-- Will need testing
vim.opt.breakindent = true

-- Search
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Don't show the mode since it is already in airline
vim.o.showmode = false

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- NerdTree
vim.keymap.set("n", "<leader>nt", ":NERDTreeToggle<cr>", { desc = "Open NerdTree" })
vim.keymap.set("n", "<leader>nf", ":NERDTreeFind<cr>", { desc = "Find current file in NerdTree" })

-- Buffer Movement
vim.keymap.set("n", "<C-h>", ":bprev<cr>", { desc = "Go to previous buffer" })
vim.keymap.set("n", "<C-l>", ":bnext<cr>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center" })

-- Add a vertical column in the buffer to visualize cutoff
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vue", "javascript", "typescript", "typescriptreact", "javascriptreact" },
  group = vim.api.nvim_create_augroup("frontend-color-column", { clear = true }),
  callback = function()
    vim.opt_local.colorcolumn = "80"
  end,
})

-- Diagnostics
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Adds the message at the end of the line
  virtual_text = false,
  -- Creates a false line under the error
  -- virtual_lines = true,
  virtual_lines = {
    current_line = true,
    format = function(diagnostic)
      return ("[%s: %s] %s"):format(diagnostic.source, diagnostic.code, diagnostic.message)
    end,
  },

  jump = { float = true },
}
-- Shouldn't need <leader>e anymore as jumping ([d and ]d) should auto open it
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "tpope/vim-sleuth",
  "tpope/vim-surround",
  "tpope/vim-fugitive",
  "preservim/nerdtree",
  "vim-airline/vim-airline",
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme "catppuccin-mocha"
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    enabled = true,
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enable = vim.g.have_nerd_font },
    },
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      }

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols)
      vim.keymap.set("n", "<leader>ch", "<cmd>:noh<cr>")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.rename, "Rename")
          map("ga", vim.lsp.buf.code_action, "Code action")
          map("fr", vim.lsp.buf.references, "Find references")

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
          end

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {},
      },
      "mason-org/mason-lspconfig.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      { "saghen/blink.cmp", version = "1.*" },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.rename, "Rename")
          map("ga", vim.lsp.buf.action, "Code action")

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client:supports_method("textDocument/documentHighlight", event.buf) then
            local highlight_group = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.clear_reference,
            })

            vim.api.nvim_create_autocmd({ "LspDetach" }, {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_reference()
                vim.api.nvim_clear_autcmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
              end,
            })
          end
        end,
      })

      local vue_ls_path = vim.fn.stdpath "data"
        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = vue_ls_path,
        languages = { "vue" },
        configNamespace = "typescript",
      }

      local servers = {
        stylua = {},
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if
                path ~= vim.fn.stdpath "config"
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
              then
                return
              end
            end

            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
              runtime = {
                version = "LuaJIT",
                path = { "lua/?.lua", "lua/?/init.lua" },
              },
              format = {
                enable = false,
              },
              workspace = {
                checkThirdParty = false,
                -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
                  "${3rd}/luv/library",
                  "${3rd}/busted/library",
                }),
              },
            })
          end,
          settings = {
            Lua = {},
          },
        },
        --[[
        ts_ls = {
          filetypes = {
            "javascript",
            "typescript",
            "vue",
          },
          init_options = {
            plugins = {
              {
                languages = { "vue" },
                location = vim.fn.stdpath "data"
                  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                name = "@vue/typescript-plugin",
              },
            },
          },
        },
        ]]
        --
        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  vue_plugin,
                },
              },
            },
          },
          filetypes = {
            "typescript",
            "javascript",
            "typescriptreact",
            "javascriptreact",
            "vue",
          },
        },
        intelephense = {
          settings = {
            intelephense = {
              format = { enable = false },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -- Others
        "vue_ls",
      })

      require("mason-lspconfig").setup { ensure_installed = ensure_installed }
      local getCapabilities = require("blink.cmp").get_lsp_capabilities

      for name, server in pairs(servers) do
        local capabilities = getCapabilities(server)

        vim.lsp.config(name, capabilities)
        vim.lsp.enable(name)
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",
    config = function()
      local parsers = {
        "lua",
        "luadoc",
        "html",
        "vim",
        "php",
        "vue",
        "javascript",
        "typescript",
      }
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)

          if not language then
            return
          end
          if not vim.treesitter.language.add(language) then
            return
          end

          vim.treesitter.start(buf, language)
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldlevel = 99
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        local disable_filetypes = {}

        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout = 500,
            lsp_format = "fallback",
          }
        end
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "eslint_d" },
        typescript = { "prettierd", "eslint_d" },
        vue = { "prettierd", "eslint_d" },
        javascriptreact = { "prettierd", "eslint_d" },
        typescriptreact = { "prettierd", "eslint_d" },
        php = { "pint" },
      },
      formatters = {
        --[[
        php_cs_fixer = {
          command = "php-cs-fixer",
          args = {
            "fix",
            '--rules={"not_operator_with_space":true,"concat_space":{"spacing":"none"}}',
            "$FILENAME",
          },
          stdin = false,
        },
        ]]
        --
        pint = {
          meta = {
            url = "https://github.com/laravel/pint",
            description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
          },
          command = vim.fn.stdpath "data" .. "/mason/bin/pint",
          args = { "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {},
        opts = {},
      },
    },
    opts = {
      keymap = {
        preset = "default",
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<Enter>"] = { "accept", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
      snippets = { preset = "luasnip" },
      fuzzy = { implementation = "lua" },
      signature = { enabled = true },
    },
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {},
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}, {
  ui = {
    icons = {},
  },
})
