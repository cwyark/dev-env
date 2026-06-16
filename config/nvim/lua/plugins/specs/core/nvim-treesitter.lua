vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",             name = "nvim-treesitter",             version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", name = "nvim-treesitter-textobjects", version = "main" }
})

require('nvim-treesitter-textobjects').setup({
  select = {
    -- Automatically jump forward to textobj, similar to targets.vim
    lookahead = true,
    -- You can choose the select mode (default is charwise 'v')
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * method: eg 'v' or 'o'
    -- and should return the mode ('v', 'V', or '<c-v>') or a table
    -- mapping query_strings to modes.
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V',  -- linewise
      ['@class.outer'] = '<c-v>', -- blockwise
    },
    -- If you set this to `true` (default is `false`) then any textobject is
    -- extended to include preceding or succeeding whitespace. Succeeding
    -- whitespace has priority in order to act similarly to eg the built-in
    -- `ap`.
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * selection_mode: eg 'v'
    -- and should return true of false
    include_surrounding_whitespace = false,
  },
  move = {
    -- whether to set jumps in the jumplist
    set_jumps = true,
  },
})

-- text object select module
local ts_textobject_select = require "nvim-treesitter-textobjects.select"

local textobject_mappings = {
  ["af"] = { capture = "@function.outer", desc = "Select outer function" },
  ["if"] = { capture = "@function.inner", desc = "Select inner function" },
  ["ac"] = { capture = "@class.outer", desc = "Select outer class" },
  ["ic"] = { capture = "@class.inner", desc = "Select inner class" },
  ["ab"] = { capture = "@block.outer", desc = "Select outer block" },
  ["ib"] = { capture = "@block.inner", desc = "Select inner block" },
  ["al"] = { capture = "@loop.outer", desc = "Select outer loop" },
  ["il"] = { capture = "@loop.inner", desc = "Select inner loop" },
  ["a/"] = { capture = "@comment.outer", desc = "Select outer comment" },
  ["i/"] = { capture = "@comment.outer", desc = "Select comment (no inner)" },
  ["ap"] = { capture = "@parameter.outer", desc = "Select outer argument" },
  ["ip"] = { capture = "@parameter.inner", desc = "Select inner argument" },
}

for lhs, meta in pairs(textobject_mappings) do
  vim.keymap.set({ "x", "o" }, lhs, function()
    ts_textobject_select.select_textobject(meta.capture, "textobjects")
  end, { desc = meta.desc })
end

local textobject_move_mappings = {
  goto_next_start = {
    ["]f"] = { capture = "@function.outer", desc = "Next function start" },
    ["]c"] = { capture = "@class.outer", desc = "Next class start" },
    ["]b"] = { capture = "@block.outer", desc = "Next block start" },
    ["]p"] = { capture = "@parameter.outer", desc = "Next parameter start" },
  },
  goto_next_end = {
    ["]F"] = { capture = "@function.outer", desc = "Next function end" },
    ["]C"] = { capture = "@class.outer", desc = "Next class end" },
    ["]B"] = { capture = "@block.outer", desc = "Next block end" },
    ["]P"] = { capture = "@parameter.outer", desc = "Next parameter end" },
  },
  goto_previous_start = {
    ["[f"] = { capture = "@function.outer", desc = "Previous function start" },
    ["[c"] = { capture = "@class.outer", desc = "Previous class start" },
    ["[b"] = { capture = "@block.outer", desc = "Previous block start" },
    ["[p"] = { capture = "@parameter.outer", desc = "Previous parameter start" },
  },
  goto_previous_end = {
    ["[F"] = { capture = "@function.outer", desc = "Previous function end" },
    ["[C"] = { capture = "@class.outer", desc = "Previous class end" },
    ["[B"] = { capture = "@block.outer", desc = "Previous block end" },
    ["[P"] = { capture = "@parameter.outer", desc = "Previous parameter end" },
  },
}

-- text object move module
local ts_textobject_move = require "nvim-treesitter-textobjects.move"

for fn_name, mappings in pairs(textobject_move_mappings) do
  for lhs, meta in pairs(mappings) do
    vim.keymap.set({ "n", "x", "o" }, lhs, function()
      ts_textobject_move[fn_name](meta.capture, "textobjects")
    end, { desc = meta.desc })
  end
end

local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"

vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
