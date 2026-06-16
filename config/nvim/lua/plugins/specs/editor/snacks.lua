vim.pack.add({
  {
    src = "https://github.com/folke/snacks.nvim.git",
    name = "snacks",
    version = "main"
  }
})

require('snacks').setup({
  bigfile = { enabled = true },
  dashboard = { enabled = false },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  picker = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
})

local Snacks = _G.Snacks

local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({
    { '<leader>s', group = "Search", icon = "" },
  })
end

vim.keymap.set('n', '<leader>ff', function()
  Snacks.picker.files()
end, { desc = "Find files" })

vim.keymap.set('n', '<leader>fr', function()
  Snacks.picker.recent()
end, { desc = "Recent files" })

vim.keymap.set('n', '<leader>fo', function()
  Snacks.explorer()
end, { desc = "Open file explorer" })

vim.keymap.set('n', '<leader>s/', function()
  Snacks.picker.grep()
end, { desc = "Live grep" })

vim.keymap.set({ 'n', 'x' }, '<leader>sw', function()
  Snacks.picker.grep_word()
end, { desc = "Search word or selection" })

vim.keymap.set('n', '<leader>sb', function()
  Snacks.picker.grep_buffers()
end, { desc = "Search open buffers" })
