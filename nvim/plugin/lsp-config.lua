local lspinstaller = require 'nvim-lsp-installer'
local lspconfig = require 'lspconfig'
local lspconfig_util = require 'lspconfig.util'

local keymaps = {
  { "n", "gd", "vim.lsp.buf.definition", { buffer = 0 } },
  { "n", "gD", "vim.lsp.buf.declaration", { buffer = 0 } },
  { "n", "gr", "vim.lsp.buf.rename", { buffer = 0 } },
  { "n", "gy", "vim.lsp.buf.type_definition", { buffer = 0 } },
  { "n", "K", "vim.lsp.buf.hover", { buffer = 0 } },
  { "n", "[a", "vim.diagnostic.goto_prev", { buffer = 0 } },
  { "n", "]a", "vim.diagnostic.goto_next", { buffer = 0 } },
  { "n", "]l", "<cmd>Telescope diagnostics<cr>", { buffer = 0 } },
  { "n", "ga", "vim.lsp.buf.code_action", { buffer = 0 } },
  { "n", "<leader>a", "vim.diagnostic.open_float", { buffer = 0 } },
}

local attachFn = function(isVolar)
  local attach = function(client, bufnr)
    -- @todo: Using vim.keymap.set has a bug where it tends to always open insert mode
    -- for _, kt in ipairs(keymaps) do
    --   -- @todo: How to not do this manually?
    --   vim.keymap.set(kt[1], kt[2], kt[3], kt[4])
    -- end

    local buf_map = function(bufnm, mode, lhs, rhs, opts)
      vim.api.nvim_buf_set_keymap(bufnm, mode, lhs, rhs, opts or { silent = true, })
    end

    vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
    vim.cmd("command! LspDec lua vim.lsp.buf.declaration()")
    vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
    vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
    vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
    vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
    vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
    vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
    vim.cmd("command! LspDiagPrev lua vim.diagnostic.goto_prev()")
    vim.cmd("command! LspDiagNext lua vim.diagnostic.goto_next()")
    vim.cmd("command! LspDiagLine lua vim.diagnostic.open_float()")
    vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
    buf_map(bufnr, "n", "gd", ":LspDef<CR>")
    buf_map(bufnr, "n", "gD", ":LspDec<CR>")
    buf_map(bufnr, "n", "gr", ":LspRename<CR>")
    buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>")
    buf_map(bufnr, "n", "K", ":LspHover<CR>")
    buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>")
    buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>")
    buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>")
    buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>")
    buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>")

    -- This _should_ place nicely with eslint_d and null_ls
    if client.server_capabilities.documentFormattingProvider and not isVolar then
      vim.cmd([[
        augroup LspFormatting
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
        augroup END
      ]])
    end
  end

  return attach
end

local typescript_path = '/home/press/.nvm/versions/node/v16.18.1/lib/node_modules/typescript/lib'

local function on_new_config(new_config, new_root_dir)
  local function get_typescript_server_path(root_dir)
    local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
    return project_root and
        (lspconfig_util.path.join(project_root, 'node_modules', 'typescript', 'lib', 'tsserverlibrary.js'))
        or ''
  end

  if new_config.init_options
      and new_config.init_options.typescript
      and new_config.init_options.typescript.tsdk == ''
  then
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end
end

local volar_cmd = { 'vue-language-server', '--stdio' }
local volar_root_dir = lspconfig_util.root_pattern 'package.json'

lspinstaller.on_server_ready(function(server)
  local opts = {}
  opts.on_attach = attachFn(false)

  if server.name == "intelephense" then
    opts.settings = {
      intelephense = {
        licenceKey = '',
        --diagnostics = {
        --  undefinedTypes = false
        --},
        files = {
          associations = { '*.php', '*.mjml', '*.phtml' }
        }
      }
    }
  -- elseif server.name == "tsserver" then -- or server.name == "volar" then
    -- opts.on_attach = attachFn(true)
  end

  server:setup(opts)
end)

-- Disable volar until I'm back in Vue-Land :')
-- lspconfig.volar.setup {
--   cmd = volar_cmd,
--   root_dir = volar_root_dir,
--   filetypes = {
--     'vue',
--     'json',
--     'typescript',
--     'javascript',
--   },
--   on_attach = attachFn(true),
--   on_new_config = on_new_config,
--   init_options = {
--     typescript = {
--       tsdk = typescript_path,
--     },
--   }
-- }

lspconfig.graphql.setup{}

lspconfig.cssls.setup {
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
}

require('lint').linters_by_ft = {
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  vue = { 'eslint_d' },
}

local prettierFn = function()
  config = {
    exe = '/Users/prestonhaddock/.nvm/versions/node/v18.18.2/bin/prettier',
    args = {
      '--stdin-filepath',
      require('formatter.util').get_current_buffer_file_path()
    },
    stdin = true
  }
  configPath = lspconfig_util.find_node_modules_ancestor(require('formatter.util').get_current_buffer_file_path())
  fileExists = vim.fn.filereadable(configPath .. '/.prettierrc')

  if configPath and fileExists == 1 then
    table.insert(config.args, '--config')
    table.insert(config.args, configPath .. '/.prettierrc')
  end

  return config
end
require('formatter').setup{
  filetype = {
    vue = {
      prettierFn,
      require('formatter.filetypes.vue').eslint_d,
    },
    javascript = {
      prettierFn
    },
    typescript = {
      prettierFn
    },
    ["*"] = {
      require('formatter.filetypes.any').remove_trailing_whitespace
    }
  }
}
