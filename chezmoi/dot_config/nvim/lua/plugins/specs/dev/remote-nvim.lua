vim.pack.add({
  { src = "https://github.com/amitds1997/remote-nvim.nvim", name = "remote-nvim", version = "main" }
})

require('remote-nvim').setup({
  remote = {
    copy_dirs = {
      config = {
        compression = {
          enabled = true,
          additional_opts = { "--exclude-vcs" }
        }
      }
    }
  }
})
