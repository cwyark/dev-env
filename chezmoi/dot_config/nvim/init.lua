-- entry point for neovim configuration

require('config.global')
require('config.option')
require('config.autocmd')

require('scripts.node_manager').ensure_path()
require('scripts.node_installer').register_commands()

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require('scripts.node_installer').ensure_node()
  end
})

require('plugins')
require('config.lsp')
require('config.colorscheme')
require('config.keymap')
