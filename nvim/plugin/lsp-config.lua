local lspinstaller = require 'nvim-lsp-installer'

local buf_map = function(bufnr, mode, lhs, rhs, opts)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or { silent = true, })
end

local on_attach = function(client, bufnr)
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
    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
            augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup END
            ]])
        -- vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end

lspinstaller.on_server_ready(function(server)
    local opts = {}
    opts.on_attach = on_attach

    if server.name == "intelephense" then
      opts.settings = {
        intelephense = {
          licenceKey = '',
          --diagnostics = {
          --  undefinedTypes = false
          --},
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
    end

    if server.name ~= "tsserver" then
      server:setup(opts)
    end
end)

local null_ls = require('null-ls')

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.eslint_d.with({
          diagnostics_format = "#{m} (#{s}: #{c})",
        }),
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.formatting.eslint_d
   },
   on_attach = on_attach
})
