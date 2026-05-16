vim.pack.add({
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    name = "neo-tree",
    version = "main",
    data = {
      deps = { "nui.nvim", "plenary.nvim", "nvim-web-devicons" }
    }
  }
}, {
  load = true
})

require("neo-tree").setup({
  filesystem = {
    use_libuv_file_watcher = true,
    follow_current_file = {
      enabled = true,
    },
  },
})

-- setup which-key binding
local wk = require('which-key')
wk.add({
  {
    '<leader>fo',
    ":Neotree toggle<CR>",
    desc = 'Toggle file browser',
    mode = 'n',
  },
})
