require('dap.ext.vscode').load_launchjs()

local dap = require('dap')
local dapui = require('dapui')

dap.adapters.php = {
    type = 'executable',
    command = 'node',
    args = { '/Users/press/dap-adapters/vscode-php-debug/out/phpDebug.js' }
}

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
