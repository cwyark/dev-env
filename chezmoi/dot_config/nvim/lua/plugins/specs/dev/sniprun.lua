vim.pack.add({
  {
    src = "https://github.com/michaelb/sniprun",
    name = "sniprun",
    version = "master",
  }
})

require("sniprun").setup({
  display = {
    "VirtualTextOk",
    "LongTempFloatingWindow",
    "TempFloatingWindowErr",
  },
  live_display = {
    "VirtualTextOk",
  },
  display_options = {
    terminal_scrollback = vim.o.scrollback,
    terminal_line_number = false,
    terminal_signcolumn = false,
    terminal_position = "horizontal",
    terminal_width = 45,
    terminal_height = 12,
    max_fw_width = 100,
    notification_timeout = 5,
  },
  show_no_output = {
    "Classic",
  },
  cwd = ".",
  interpreter_options = {
    GFM_original = {
      use_on_filetypes = { "markdown" },
    },
    Python3_original = {
      error_truncate = "auto",
    },
  },
  live_mode_toggle = "off",
  inline_messages = false,
  borders = "single",
})

local ok, wk = pcall(require, "which-key")
if ok then
  wk.add({
    { "<leader>e",  group = "Execute", icon = "" },
    { "<leader>es", desc = "SnipRun: Run snippet", mode = { "n", "v" } },
    { "<leader>ef", desc = "SnipRun: Run motion",  mode = "n" },
    { "<leader>ec", "<cmd>SnipClose<cr>",          desc = "SnipRun: Close output",  mode = "n" },
    { "<leader>ex", "<cmd>SnipReset<cr>",          desc = "SnipRun: Reset SnipRun", mode = "n" },
    { "<leader>ei", "<cmd>SnipInfo<cr>",           desc = "SnipRun: Show Info",     mode = "n" },
  })
end

vim.keymap.set({ "n", "v" }, "<leader>es", "<Plug>SnipRun", {
  desc = "Run snippet",
  remap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>ef", "<Plug>SnipRunOperator", {
  desc = "Run motion with SnipRun",
  remap = true,
  silent = true,
})
