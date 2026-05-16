vim.pack.add({
  { src = "https://github.com/linux-cultist/venv-selector.nvim", name = "venv-selector", version = "main" }
})

require('venv-selector').setup({})

local wk = require('which-key')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(args)
    wk.add({
      {
        '<leader>lv', '<cmd>VenvSelect<cr>', desc = 'Select Python Virtualenv', buffer = args.buf,
      },
    })
  end,
})
