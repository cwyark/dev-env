-- entry point for neovim configuration

require('config.global')
require('config.clipboard')
require('config.option')
require('config.empty_autocmd')

require('plugins')
require('config.lsp')
require('config.colorscheme')
require('config.keymap')
