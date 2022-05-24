local lspinstaller = require 'nvim-lsp-installer'
local lspconfig = require 'lspconfig'
local lspconfig_configs = require 'lspconfig.configs'
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
    vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
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

    if isVolar then
      client.resolved_capabilities.document_formatting = false
    elseif client.resolved_capabilities.document_formatting then
      vim.cmd([[
        augroup LspFormatting
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
        augroup END
      ]])
    end
  end

  return attach
end

local ts_language_server = '/Users/press/.nvm/versions/node/v16.14.2/lib/node_modules/typescript/lib/tsserverlibrary.js'

local function on_new_config(new_config, new_root_dir)
  local function get_typescript_server_path(root_dir)
    local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
    return project_root and (lspconfig_util.path.join(project_root, 'node_modules', 'typescript', 'lib', 'tsserverlibrary.js'))
      or ''
  end

  if
    new_config.init_options
    and new_config.init_options.typescript
    and new_config.init_options.typescript.serverPath == ''
  then
    new_config.init_options.typescript.serverPath = get_typescript_server_path(new_root_dir)
  end
end

local volar_cmd = {'vue-language-server', '--stdio'}
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
    elseif server.name == "sumneko_lua" then
      opts.settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          }
        }
      }
    elseif server.name == "tsserver" then
      opts.on_attach = attachFn(true)
    end

    server:setup(opts)
end)

lspconfig_configs.volar_api = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    on_attach = attachFn(true),
    -- filetypes = { 'vue'},
    -- If you want to use Volar's Take Over Mode (if you know, you know)
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    init_options = {
      typescript = {
        serverPath = ts_language_server
      },
      languageFeatures = {
        implementation = true, -- new in @volar/vue-language-server v0.33
        references = true,
        definition = true,
        typeDefinition = true,
        callHierarchy = true,
        hover = true,
        rename = true,
        renameFileRefactoring = true,
        signatureHelp = true,
        codeAction = true,
        workspaceSymbol = true,
        completion = {
          defaultTagNameCase = 'both',
          defaultAttrNameCase = 'kebabCase',
          getDocumentNameCasesRequest = false,
          getDocumentSelectionRequest = false,
        },
      }
    },
  }
}
lspconfig.volar_api.setup{}

lspconfig_configs.volar_doc = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    on_attach = attachFn(true),
    --filetypes = { 'vue'},
    -- If you want to use Volar's Take Over Mode (if you know, you know):
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    init_options = {
      typescript = {
        serverPath = ts_language_server
      },
      languageFeatures = {
        implementation = true, -- new in @volar/vue-language-server v0.33
        documentHighlight = true,
        documentLink = true,
        codeLens = { showReferencesNotification = true},
        -- not supported - https://github.com/neovim/neovim/pull/15723
        semanticTokens = false,
        diagnostics = true,
        schemaRequestService = true,
      }
    },
  }
}
lspconfig.volar_doc.setup{}

lspconfig_configs.volar_html = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    on_attach = attachFn(true),
    --filetypes = { 'vue'},
    -- If you want to use Volar's Take Over Mode (if you know, you know), intentionally no 'json':
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
      typescript = {
        serverPath = ts_language_server
      },
      documentFeatures = {
        selectionRange = true,
        foldingRange = true,
        linkedEditingRange = true,
        documentSymbol = true,
        -- not supported - https://github.com/neovim/neovim/pull/13654
        documentColor = false,
        documentFormatting = {
          defaultPrintWidth = 100,
        },
      }
    },
  }
}
lspconfig.volar_html.setup{}

lspconfig.cssls.setup{}

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.eslint_d.with({
      diagnostics_format = "#{m} (#{s}: #{c})"
    }),
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.formatting.eslint_d,
  },
  on_attach = attachFn(false)
})
