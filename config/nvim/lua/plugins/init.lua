require('plugins.deps')

require('plugins.specs.core.which-key')
require('plugins.specs.core.mason')
require('plugins.specs.core.nvim-treesitter')
require('plugins.specs.core.blink-cmp')
require('plugins.specs.core.lazydev')

-- Snacks is the primary picker and file explorer stack.
-- Keep these specs available, but do not load them by default:
-- require('plugins.specs.editor.neo-tree')
-- require('plugins.specs.editor.oil')
require('plugins.specs.editor.yazi')
require('plugins.specs.editor.telescope')
-- require('plugins.specs.editor.fzf')
require('plugins.specs.editor.toggleterm')
require('plugins.specs.editor.lualine')
require('plugins.specs.editor.noice')
require('plugins.specs.editor.trouble')
require('plugins.specs.editor.flash')
require('plugins.specs.editor.snacks')
require('plugins.specs.editor.tokionight')

require('plugins.specs.dev.nvim-dap')
require('plugins.specs.dev.overseer')
require('plugins.specs.dev.sniprun')
require('plugins.specs.dev.venv-selector')

require('plugins.specs.ai.codecompanion')
require('plugins.specs.ai.opencode')

require('plugins.specs.misc.leetcode')
require('plugins.specs.misc.render-markdown')
