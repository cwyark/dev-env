vim.pack.add({
  {
    src = "https://github.com/akinsho/toggleterm.nvim",
    name = "toggleterm",
    version = "main"
  }
})

local function set_terminal_keymaps(term)
  local opts = { buffer = 0 }
  if term.cmd ~= 'lazygit' then
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  end
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<cmd>wincmd l<CR>]], opts)
end

require('toggleterm').setup({
  on_open = set_terminal_keymaps
})

-- confiure which-key
local wk = require('which-key')

wk.add({
  {
    '<leader>T',
    group = "Terminal",
    icon = ""
  },
  {
    '<leader>Tt',
    "<cmd>ToggleTermToggleAll<cr>",
    desc = 'Toggle all terminals',
    mode = 'n',
  },
  {
    '<leader>Tf',
    "<cmd>ToggleTerm direction=float<cr>",
    desc = "Toggle a float terminal",
    mode = "n"
  },
  {
    '<leader>Th',
    "<cmd>ToggleTerm size=10 direction=horizontal<cr>",
    desc = "Split terminal",
    mode = "n"
  }
})

-- register custom terminal commands

-- lazygit
local Terminal = require('toggleterm.terminal').Terminal
local lazygit  = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  float_opts = {
    border = "double",
  },
})

local function _lazygit_toggle()
  lazygit:toggle()
end

vim.keymap.set("n", "<leader>gG", _lazygit_toggle, { desc = "Open LazyGit", noremap = true, silent = true })

wk.add({
  { '<leader>g', group = "Git", icon = "" },
})
