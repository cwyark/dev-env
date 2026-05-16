vim.g.blink_cmp_keymap = { preset = 'default' }

vim.keymap.set('n', "<leader>cf", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "format current buffer" })
vim.keymap.set('n', "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "rename current variable" })

local ok, wk = pcall(require, 'which-key')
if not ok then
  return
end

wk.add({
  {
    '<leader>c',
    group = "Code",
    icon = ""
  }
})

wk.add({
  {
    '<leader>f',
    group = "Files",
    icon = ""
  }
})

wk.add({
  {
    '<leader>p',
    group = "Package",
    icon = "󰏓"
  }
})

vim.keymap.set('n', "<leader>pu", "<cmd>lua vim.pack.update()<cr>", { desc = "Update packages" })

vim.keymap.set('n', "<C-h>", "<cmd>wincmd h<cr>")
vim.keymap.set('n', "<C-j>", "<cmd>wincmd j<cr>")
vim.keymap.set('n', "<C-k>", "<cmd>wincmd k<cr>")
vim.keymap.set('n', "<C-l>", "<cmd>wincmd l<cr>")

-- string replace key bindings
