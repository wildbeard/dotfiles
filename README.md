### Required NPM Packages
* `npm i -g eslint_d`
  * Used for eslint
  * `eslint_d` is a daemon and runs a bit faster than standard eslint
* `npm i -g intelephense`
  * Used for php
* `npm i -g typescript-language-server`
  * Used for most any JS file (typescript, react, vue, js)
* Clone [vscode-php-debug](https://github.com/xdebug/vscode-php-debug) into a desired folder
  * Move into the repo and run `npm i && npm run build`
  * Once done building keep note of the build path
  * Use the absolute path to the build executable and set it as a value in the `args` table for `dap.adapters.php`

### Required Binaries
* [vim-plug](https://github.com/junegunn/vim-plug)
  * Used to manage, install, and update vim/neovim plugins
* [ripgrep](https://github.com/BurntSushi/ripgrep)
  * Used by [Telescope](https://github.com/nvim-telescope/telescope.nvim) for `live_grep` and `grep_string`
