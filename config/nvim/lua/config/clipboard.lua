local remote_session = vim.env.SSH_CONNECTION or vim.env.SSH_TTY or vim.env.ZELLIJ

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
