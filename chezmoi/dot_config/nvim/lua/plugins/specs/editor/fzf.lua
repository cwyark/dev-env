vim.pack.add({
  { src = "https://github.com/junegunn/fzf",     name = "fzf",     version = "master" },
  { src = "https://github.com/junegunn/fzf.vim", name = "fzf.vim", version = "master" }
})

local wk = require('which-key')

wk.add({
  { '<leader>s', group = "Search", icon = "" }
})

vim.keymap.set('n', '<leader>ff', "<cmd>Files<cr>", { desc = "Search files" })
vim.keymap.set('n', '<leader>s/', "<cmd>RG<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>sw", function()
  vim.cmd("Rg " .. vim.fn.expand("<cword>"))
end, { desc = "FZF Rg search word under cursor" })
