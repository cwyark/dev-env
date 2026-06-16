vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap",        name = "nvim-dap",       version = "master" },
  { src = "https://github.com/igorlfs/nvim-dap-view",        name = "nvim-dap-view",  version = "main" },
  { src = "https://github.com/jay-babu/mason-nvim-dap.nvim", name = "mason-nvim-dap", version = "main" }
})

require('mason-nvim-dap').setup({
  handlers = {
    function(config)
      require('mason-nvim-dap').default_setup(config)
    end,
    python = function(config)
      require('mason-nvim-dap').default_setup(config) -- don't forget this!
    end,
  },
})

local dapview = require("dap-view")

dapview.setup({})

local dap = require("dap")
dap.listeners.after.event_initialized["dap-view"] = function()
  dapview.open()
end
dap.listeners.before.event_terminated["dap-view"] = function()
  dapview.close()
end
dap.listeners.before.event_exited["dap-view"] = function()
  dapview.close()
end

local wk = require('which-key')
wk.add({
  {
    '<leader>d',
    group = "Debuger",
    icon = ""
  }
})

vim.keymap.set("n", "<leader>dv", function()
  dapview.toggle()
end, { desc = "DAP View Toggle" })

vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set("n", "<F8>",
  function()
    dap.toggle_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "DAP Toggle Conditional Breakpoint" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
vim.keymap.set("n", "<F6>", dap.terminate, { desc = "DAP Terminate" })
vim.keymap.set("n", "<F7>", dap.run_last, { desc = "DAP Run Last" })
