vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim", name = "oil", version = "master" }
}, { load = true })

require('oil').setup({
  keymaps = {
    ["q"] = { "actions.close", mode = "n" },
    ["<C-h>"] = { "actions.parent", mode = "n" },
    ["<C-l>"] = { "actions.select", mode = "n" },
  }
})

vim.keymap.set('n', '<leader>fe', "<cmd>Oil<cr>", { desc = "Open or edit files" })
