local uv = vim.uv or vim.loop

local PLUGIN_NAME = "sniprun"
local PLUGIN_PATH = vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. PLUGIN_NAME

local function is_macos()
  return uv.os_uname().sysname == "Darwin"
end

local function install_cmd()
  if is_macos() then
    return { "sh", "install.sh", "1" }
  end

  return { "sh", "install.sh" }
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

local function ensure_prerequisites()
  if is_macos() and vim.fn.executable("cargo") == 0 then
    notify("SnipRun on macOS requires `cargo` to compile the native binary locally.", vim.log.levels.ERROR)
    return false
  end

  return true
end

local function run_install(path, silent_success)
  path = path or PLUGIN_PATH

  if vim.fn.isdirectory(path) == 0 then
    notify("SnipRun plugin directory not found. Install the plugin first.", vim.log.levels.ERROR)
    return
  end

  if not ensure_prerequisites() then
    return
  end

  local cmd = install_cmd()
  notify("Installing SnipRun binary ...", vim.log.levels.INFO)
  vim.system(cmd, { cwd = path, text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        if not silent_success then
          vim.notify("SnipRun binary is ready.", vim.log.levels.INFO)
        end
      else
        vim.notify("SnipRun install failed: " .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local data = ev.data or {}
    local spec = data.spec or {}
    if spec.name ~= PLUGIN_NAME then
      return
    end

    if data.kind == "install" or data.kind == "update" then
      run_install(data.path, true)
    end
  end,
})

vim.api.nvim_create_user_command("SnipRunInstall", function()
  run_install(PLUGIN_PATH, false)
end, { desc = "Build or install SnipRun binary" })

vim.pack.add({
  {
    src = "https://github.com/michaelb/sniprun",
    name = PLUGIN_NAME,
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
    { "<leader>ps", "<cmd>SnipRunInstall<cr>",     desc = "Install SnipRun binary", mode = "n" },
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
