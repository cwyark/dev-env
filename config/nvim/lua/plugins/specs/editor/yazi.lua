vim.pack.add({
  {
    src = "https://github.com/mikavilpas/yazi.nvim.git",
    name = "yazi",
    version = "main"
  }
}, { load = true })

require("yazi").setup({
  open_for_directories = true,
  change_neovim_cwd_on_close = true
})

vim.keymap.set('n', '<leader>fy', '<cmd>Yazi<cr>', { desc = "Open Yazi" })
vim.keymap.set('n', '<leader>fY', '<cmd>Yazi cwd<cr>', { desc = "Open Yazi in cwd" })
