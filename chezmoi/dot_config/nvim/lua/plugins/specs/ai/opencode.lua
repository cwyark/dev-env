vim.pack.add({
  {
    src = "https://github.com/nickjvandyke/opencode.nvim",
    name = "opencode.nvim",
    version = "v0.11.0"
  }
})

vim.o.autoread = true

local opencode_cmd = 'opencode --port'
local snacks_terminal_opts = {
  win = {
    position = 'right',
    enter = false,
  },
}

vim.g.opencode_opts = {
  server = {
    start = function()
      require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
    end,
  },
}

local wk = require('which-key')

wk.add({
  {
    '<leader>o',
    group = "OpenCode",
    icon = "󰚩"
  }
})

vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
  require('opencode').ask('@this: ')
end, { desc = "Ask OpenCode" })

vim.keymap.set({ 'n', 'x' }, '<leader>os', function()
  require('opencode').select()
end, { desc = "Select OpenCode action" })

vim.keymap.set({ 'n', 'x' }, 'go', function()
  return require('opencode').operator('@this ')
end, { desc = "Add range to OpenCode", expr = true })

vim.keymap.set('n', 'goo', function()
  return require('opencode').operator('@this ') .. "_"
end, { desc = "Add line to OpenCode", expr = true })

vim.keymap.set({ 'n', 't' }, '<C-.>', function()
  require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
end, { desc = "Toggle OpenCode" })

vim.keymap.set('n', '<S-C-u>', function()
  require('opencode').command('session.half.page.up')
end, { desc = "Scroll OpenCode up" })

vim.keymap.set('n', '<S-C-d>', function()
  require('opencode').command('session.half.page.down')
end, { desc = "Scroll OpenCode down" })
