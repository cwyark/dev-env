vim.pack.add({
  { src = "https://github.com/stevearc/overseer.nvim", name = "overseer", version = "master" }
})

require('overseer').setup({
  dap = true,
  output = {
    use_terminal = true,
    preserve_output = false,
  },
})

local wk = require('which-key')

wk.add({
  { '<leader>t', group = "Task", icon = "" },
  { '<leader>tt', "<cmd>OverseerToggle<cr>", desc = "Task: Toggle Window", mode = "n" },
  { '<leader>tr', "<cmd>OverseerRun<cr>", desc = "Task: Select to Execute", mode = "n" },
})
