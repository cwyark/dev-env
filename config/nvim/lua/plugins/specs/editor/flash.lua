vim.pack.add({
  {
    src = "https://github.com/folke/flash.nvim",
    name = "flash",
    version = "main",
  }
})

require("flash").setup({
  labels = "asdfghjklqwertyuiopzxcvbnm",
  search = {
    multi_window = false,
  },
  jump = {
    nohlsearch = true,
    autojump = false,
  },
  label = {
    uppercase = false,
    current = true,
    after = false,
    before = true,
    style = "inline",
    rainbow = {
      enabled = true,
      shade = 4,
    },
  },
  modes = {
    char = {
      enabled = false,
    },
    search = {
      enabled = false,
    },
  },
  prompt = {
    enabled = true,
  },
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Treesitter Search" })
