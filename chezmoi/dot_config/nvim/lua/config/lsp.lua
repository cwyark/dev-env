vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig.git" }
})

vim.lsp.log.set_level(vim.log.levels.OFF)

vim.api.nvim_create_user_command("LspLogClear", function()
  local log_file = vim.lsp.log.get_filename()
  local ok, result = pcall(vim.fn.writefile, {}, log_file)
  if ok and result == 0 then
    vim.notify("Cleared LSP log: " .. log_file, vim.log.levels.INFO)
  else
    vim.notify("Failed to clear LSP log: " .. tostring(result), vim.log.levels.ERROR)
  end
end, { desc = "Clear Neovim LSP log" })

local capabilities = vim.lsp.protocol.make_client_capabilities()
do
  local ok, cmp = pcall(require, "blink.cmp")
  if ok and cmp.get_lsp_capabilities then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp.get_lsp_capabilities())
  end
end

local function snacks_picker(method, fallback)
  return function()
    local snacks = _G.Snacks
    if snacks and snacks.picker and snacks.picker[method] then
      snacks.picker[method]()
      return
    end

    fallback()
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(e)
    local client = vim.lsp.get_client_by_id(e.data.client_id)
    local bufnr = e.buf

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "gd", snacks_picker("lsp_definitions", vim.lsp.buf.definition), "Go to definition")
    map("n", "gD", snacks_picker("lsp_declarations", vim.lsp.buf.declaration), "Go to declaration")
    map("n", "gI", snacks_picker("lsp_implementations", vim.lsp.buf.implementation), "Go to implementation")
    map("n", "gr", snacks_picker("lsp_references", vim.lsp.buf.references), "References")
    map("n", "gy", snacks_picker("lsp_type_definitions", vim.lsp.buf.type_definition), "Go to type definition")
    map("n", "gai", snacks_picker("lsp_incoming_calls", vim.lsp.buf.incoming_calls), "Incoming calls")
    map("n", "gao", snacks_picker("lsp_outgoing_calls", vim.lsp.buf.outgoing_calls), "Outgoing calls")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cs", vim.lsp.buf.signature_help, "Signature help")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>cd", snacks_picker("lsp_symbols", vim.lsp.buf.document_symbol), "Document symbols")
    map("n", "<leader>cw", snacks_picker("lsp_workspace_symbols", vim.lsp.buf.workspace_symbol), "Workspace symbols")
    map("n", "<leader>ct", function()
      local snacks = _G.Snacks
      if snacks and snacks.picker and snacks.picker.treesitter then
        snacks.picker.treesitter()
        return
      end

      vim.notify("Snacks Treesitter picker is unavailable", vim.log.levels.WARN)
    end, "Treesitter symbols")

    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "--pch-storage=memory",
  },
  before_init = function(params)
    params.capabilities.offsetEncoding = nil
  end,
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.config("ruff", {
  init_options = { settings = { logLevel = "error" } },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
      procMacro = { enable = true },
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      completion = { callSnippet = "Replace" },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({
  "lua_ls",
  "clangd",
  "pyright",
  "ruff",
  "rust_analyzer",
  "neocmake",
  "biome",
  "taplo",
})
