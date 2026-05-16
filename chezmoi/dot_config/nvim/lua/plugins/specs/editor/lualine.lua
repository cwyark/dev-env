vim.pack.add({
  {
    src = "https://github.com/nvim-lualine/lualine.nvim",
    name = "lualine",
    version = "master",
    data = {
      deps = { "nui.nvim", "plenary.nvim", "nvim-web-devicons" }
    }
  },
  {
    src = "https://github.com/nvim-lua/plenary.nvim",
    name = "plenary.nvim",
    version = "master"
  },
}, { load = true })

require('lualine').setup({})
