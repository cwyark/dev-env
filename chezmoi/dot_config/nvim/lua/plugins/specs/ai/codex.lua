vim.pack.add({
  { src = "https://github.com/johnseth97/codex.nvim", name = "codex", version = "main" }
})

local wk = require('which-key')

wk.add({
  {
    '<leader>aC',
    "<cmd>CodexToggle<cr>",
    icon = ""
  }
})
