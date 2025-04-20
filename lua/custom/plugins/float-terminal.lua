vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

-- Floating window utility
local function open_floating_win(opts)
  opts = opts or {}

  -- Defaults
  local default_opts = {
    width = 60,
    height = 20,
    border = 'rounded',
    title = 'Floating Window',
    title_pos = 'center',
    relative = 'editor',
    style = 'minimal',
  }

  -- Merge user opts with defaults
  for k, v in pairs(default_opts) do
    if opts[k] == nil then
      opts[k] = v
    end
  end

  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  -- Create a scratch buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  -- Window options
  local win_opts = {
    style = opts.style,
    relative = opts.relative,
    width = width,
    height = height,
    row = row,
    col = col,
    border = opts.border,
    title = opts.title,
    title_pos = opts.title_pos,
  }

  -- Open window
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = open_floating_win { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
    vim.cmd 'normal i'
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command('FloatTerm', toggle_terminal, {})
vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle_terminal)
