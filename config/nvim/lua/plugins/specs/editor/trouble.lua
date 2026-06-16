vim.pack.add({
  { src = "https://github.com/folke/trouble.nvim", name = "trouble", version = "main" }
}, { load = true })

require('trouble').setup({
  auto_close = true,
  modes = {
    lsp = {
      win = {
        type = "float",
        relative = "editor",
        position = "bottom",
      },
      preview = {
        type = "main",
      },
    }
  }
})

local wk = require('which-key')

wk.add({
  {
    '<leader>x',
    group = "Diagnostics",
    icon = "󰀖"
  },
  {
    '<leader>xx',
    "<cmd>Trouble diagnostics toggle<cr>",
    desc = "Diagnostics (Trouble)",
    mode = 'n'
  },
  {
    "<leader>xX",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Buffer Diagnostics (Trouble)",
    mode = 'n'
  },
  {
    '<leader>l',
    group = 'LSP',
    icon = ""
  },
  {
    '<leader>ll',
    '<cmd>Trouble lsp toggle focus=true win.type=float<cr>',
    desc = "Toogle lsp",
    mode = 'n'
  },
  {
    '<leader>li',
    '<cmd>Trouble lsp_implementations toggle focus=true win.type=float<cr>',
    desc = "Open LSP overview window",
    mode = 'n'
  },
  {
    '<leader>lr',
    '<cmd>Trouble lsp_references toggle focus=true win.type=float<cr>',
    desc = "Open LSP reference window",
    mode = 'n'
  }
})
