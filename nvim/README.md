### Required NPM Packages
* `npm i -g eslint_d`
  * Used for eslint
  * `eslint_d` is a daemon and runs a bit faster than standard eslint
* `npm i -g @volar/vue-language-server`
  * Vue Language server from [Volar](https://github.com/johnsoncodehk/volar)

### Xdebug
  * Clone [vscode-php-debug](https://github.com/xdebug/vscode-php-debug) into a desired folder
  * Move into the repo and run `npm i && npm run build`
  * Once done building keep note of the build path
    * Typically `/vscode-php-debug/out`
  * Use the absolute path to the build executable and set it as a value in the `args` table for `dap.adapters.php`
    * Example `/path/to/vscode-php-debug/out/phpDebug.js`
    ```lua
      dap.adapters.php = {
        -- ..
        args = { '/path/to/vscode-php-debug/out/phpDebug.js' }
      }
    ```
  * If you are unable to connect to the xdebug client, try updating `xdebug.discover_client_host` to `1`

### Required Binaries
* [vim-plug](https://github.com/junegunn/vim-plug)
  * Used to manage, install, and update vim/neovim plugins
* [ripgrep](https://github.com/BurntSushi/ripgrep)
  * Used by [Telescope](https://github.com/nvim-telescope/telescope.nvim) for `live_grep` and `grep_string`

### Getting Started
- Once the required binaries are installed, open any directory in nvim via `nvim .`
- Run the command `:PlugInstall` to install the specified plugins
- Restart nvim
- Re-open any directory and install the following language servers by running:
  `:LspInstall tailwindcss intelephense sumneko-lua`
- Open the your `plugin/lsp-config.lua` and update the `volar-cmd` and `ts_language_server` values to match your install
- Verify installed language servers by running `:LspInstallInfo`
