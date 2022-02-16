local dap = require('dap')
local dapui = require('dapui')

dap.adapters.php = {
    type = 'executable',
    command = 'node',
    args = { '/Users/press/dap-adapters/vscode-php-debug/out/phpDebug.js' }
}

dapui.setup({
    mappings = {
        expand = { '<CR>', '<LeftMouse>' }
    },
    sidebar = {
        elements = {
            { id = 'breakpoints', size = 0.5 },
            { id = 'scopes', size = 0.5 }
        },
    },
    tray = {
        elements = {}
    }
})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
  dap.repl.close()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
