vim.pack.add({
  {
    src = "https://github.com/olimorris/codecompanion.nvim",
    name = "codecompanion.nvim",
    version = vim.version.range("^19.0.0"),
  },
})

local wk = require('which-key')

wk.add({
  {
    '<leader>a',
    group = "AI Assistant",
    icon = "",
  },
  {
    '<leader>a',
    group = "AI Assistant",
    icon = "",
    mode = "x",
  },
})

vim.keymap.set({ "n", "x" }, "<leader>aa", ":CodeCompanionActions<cr>", {
  desc = "CodeCompanion Actions",
  silent = true,
})

vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", {
  desc = "Toggle CodeCompanion Chat",
  silent = true,
})

vim.keymap.set("n", "<leader>at", "<cmd>CodeCompanionChat<cr>", {
  desc = "New CodeCompanion Chat",
  silent = true,
})

vim.keymap.set("n", "<leader>ai", "<cmd>CodeCompanion<cr>", {
  desc = "CodeCompanion Inline",
  silent = true,
})

vim.keymap.set("x", "<leader>ai", ":CodeCompanion<cr>", {
  desc = "CodeCompanion Inline",
  silent = true,
})

vim.keymap.set("n", "<leader>am", "<cmd>CodeCompanionCmd<cr>", {
  desc = "CodeCompanion Command",
  silent = true,
})

local openai_api_key

local function get_openai_api_key()
  local env_key = os.getenv("OPENAI_API_KEY")
  if env_key and env_key ~= "" then
    return env_key
  end

  if openai_api_key and openai_api_key ~= "" then
    return openai_api_key
  end

  openai_api_key = vim.fn.inputsecret("OpenAI API key: ")
  return openai_api_key
end

local function openai_responses_adapter(name, model, reasoning_effort, opts)
  opts = opts or {}

  return function()
    local adapter = require("codecompanion.adapters").extend("openai_responses", {
      name = name,
      formatted_name = opts.formatted_name,
      env = {
        api_key = get_openai_api_key,
      },
      opts = {
        tools = opts.tools,
      },
      schema = {
        model = {
          default = model,
        },
        ["reasoning.effort"] = {
          default = reasoning_effort,
        },
        ["reasoning.summary"] = {
          default = "auto",
        },
        verbosity = {
          default = opts.verbosity or "medium",
        },
      },
    })

    -- GPT reasoning models reject sampling controls on the Responses API.
    adapter.schema.temperature = nil
    adapter.schema.top_p = nil

    return adapter
  end
end

require('codecompanion').setup({
  display = {
    chat = {
      window = {
        layout = "vertical",
        position = "right",
        width = 0.25
      },
    },
  },
  adapters = {
    http = {
      opts = {
        show_model_choices = false,
      },
      ["coding-agent"] = openai_responses_adapter("coding-agent", "gpt-5.4-mini", "low", {
        formatted_name = "Coding Agent",
      }),
      ["reviewing-agent"] = openai_responses_adapter("reviewing-agent", "gpt-5.4-mini", "medium", {
        formatted_name = "Reviewing Agent",
      }),
      ["thinking-agent"] = openai_responses_adapter("thinking-agent", "gpt-5.4", "high", {
        formatted_name = "Thinking Agent",
      }),
      ["summary-agent"] = openai_responses_adapter("summary-agent", "gpt-5.4-nano", "minimal", {
        formatted_name = "Summary Agent",
      }),
    },
  },
  interactions = {
    chat = {
      adapter = "coding-agent",
      keymaps = {
        completion = {
          modes = { i = "<C-/>" },
        },
      },
    },
    inline = {
      adapter = "coding-agent",
    },
    cmd = {
      adapter = "summary-agent",
    },
    background = {
      adapter = "summary-agent",
    },
  },
})
