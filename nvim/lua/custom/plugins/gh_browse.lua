local function get_current_branch()
  local Job = require 'plenary.job'
  local result = Job:new({
    command = 'git',
    args = { 'rev-parse', '--abbrev-ref', 'HEAD' },
    on_exit = function(j, return_val)
      return j:result()[1]
    end,
  }):sync()
  return result[1]
end
return {
  'nvim-lua/plenary.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
  init = function()
    -- TODO: make this support ranges
    local function get_cursor_position()
      local buf_name = vim.fn.expand '%:.'          -- Get full path of current buffer
      local cursor = vim.api.nvim_win_get_cursor(0) -- Get cursor position
      local line = cursor[1]                        -- Line number

      -- Concatenate the information
      local result = string.format('%s:%d', buf_name, line)

      return result
    end
    local Job = require 'plenary.job'

    vim.api.nvim_create_user_command("GHBrowse",
      function()
        local position = get_cursor_position()
        print("position")
        print(position)
        local args = { "browse", position, "--branch", get_current_branch() }
        Job:new({
          command = 'gh',
          args = args,
          -- cwd = '/usr/bin',
          -- env = { ['a'] = 'b' },
          on_exit = function(j, return_val)
            print(return_val)
            for i, data in ipairs(j:result()) do
              print(data)
            end
          end,
        }):sync() -- or start()
      end,
      { desc = "open current line in github" }
    )
  end,
}
