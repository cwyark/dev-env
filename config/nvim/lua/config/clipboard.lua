local remote_session = vim.env.SSH_CONNECTION ~= nil and vim.env.SSH_CONNECTION ~= ''
  or vim.env.SSH_TTY ~= nil and vim.env.SSH_TTY ~= ''

vim.api.nvim_create_user_command('ClipboardInfo', function()
  local provider = vim.g.clipboard and vim.g.clipboard.name or 'auto-detected'
  local location = remote_session and 'remote (OSC 52)' or 'local (Neovim provider)'
  vim.notify(('Clipboard: %s\nProvider: %s'):format(location, provider))
end, { desc = 'Show the active clipboard transport' })

if not remote_session then
  return
end

local osc52 = require('vim.ui.clipboard.osc52')

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = osc52.copy('+'),
    ['*'] = osc52.copy('*'),
  },
  paste = {
    ['+'] = osc52.paste('+'),
    ['*'] = osc52.paste('*'),
  },
}
