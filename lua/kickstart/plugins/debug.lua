-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- event = 'VeryLazy',
  ft = { 'python', 'go', 'cpp', 'c' },
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<leader>R',
      function(t)
        local args = vim.split(vim.fn.expand(t.args), ' ')
        local approval = vim.fn.confirm(
          'Will try to run:\n    ' .. vim.bo.filetype .. ' ' .. vim.fn.expand '%' .. ' ' .. t.args .. '\n\n' .. 'Do you approve? ',
          '&Yes\n&No',
          1
        )
        if approval == 1 then
          require('dap').run {
            type = vim.bo.filetype,
            request = 'launch',
            name = 'Launch file with custom arguments (adhoc)',
            program = '${file}',
            args = args,
          }
        end
      end,
    },
  },
  -- keys = function(_, keys)
  -- local dap = require 'dap'
  -- local dapui = require 'dapui'
  -- vim.api.nvim_create_user_command('RunScriptWithArgs', function(t)
  --   -- :help nvim_create_user_command
  --   local args = vim.split(vim.fn.expand(t.args), ' ')
  --   local approval =
  --     vim.fn.confirm('Will try to run:\n    ' .. vim.bo.filetype .. ' ' .. vim.fn.expand '%' .. ' ' .. t.args .. '\n\n' .. 'Do you approve? ', '&Yes\n&No', 1)
  --   if approval == 1 then
  --     require('dap').run {
  --       type = vim.bo.filetype,
  --       request = 'launch',
  --       name = 'Launch file with custom arguments (adhoc)',
  --       program = '${file}',
  --       args = args,
  --     }
  --   end
  -- end, {
  --   complete = 'file',
  --   nargs = '*',
  -- })
  -- vim.keymap.set('n', '<leader>R', ':RunScriptWithArgs ')
  -- return {
  -- Basic debugging keymaps, feel free to change to your liking!
  -- end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        -- 'delve',
        'python',
        -- 'php-debug-adapter',
      },
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
