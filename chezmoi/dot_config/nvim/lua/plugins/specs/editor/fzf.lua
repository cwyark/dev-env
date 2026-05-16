vim.pack.add({
  { src = "https://github.com/junegunn/fzf",     name = "fzf",     version = "master" },
  { src = "https://github.com/junegunn/fzf.vim", name = "fzf.vim", version = "master" }
})

vim.api.nvim_create_user_command("FzfInstallBinary", function()
  if vim.fn.exists("*fzf#install") == 0 then
    vim.notify("fzf#install() function not exist，please confirm junegunn/fzf is installed and loaded",
      vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("fzf") == 1 then
    vim.notify("detected fzf (fzf --version), so no need to fzf#install()", vim.log.levels.INFO)
    return
  end
  vim.notify("execute fzf#install() install fzf binary…", vim.log.levels.INFO)
  vim.fn["fzf#install"]()
end, {})

local wk = require('which-key')

wk.add({
  { '<leader>s', group = "Search", icon = "" }
})

vim.keymap.set('n', '<leader>ff', "<cmd>Files<cr>", { desc = "Search files" })
vim.keymap.set('n', '<leader>s/', "<cmd>RG<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>sw", function()
  vim.cmd("Rg " .. vim.fn.expand("<cword>"))
end, { desc = "FZF Rg search word under cursor" })
