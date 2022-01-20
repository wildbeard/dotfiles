require'nvim-treesitter.configs'.setup {
    ensure_installed = { 'javascript', 'vue', 'html', 'css', 'scss', 'php' },
    sync_install = true,
    highlight = {
        enable = true,
    },
}

