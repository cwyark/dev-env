vim.pack.add({
  {
    src = "https://github.com/kawre/leetcode.nvim.git",
    name = "leetcode",
    version = "master"
  }
})

require('leetcode').setup({
  arg = "leetcode"
})
