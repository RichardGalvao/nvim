return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local util = require("lspconfig/util")
    local path = util.path

    -- (Keep your existing get_python_path function here)
    local function get_python_path(workspace)
      -- ... your detection logic from the previous step ...
      if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
      end
      return "/home/yunok/anaconda3/bin/python"
    end

    opts.servers = opts.servers or {}
    opts.servers.pyright = {
      on_init = function(client)
        client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
      end,
      -- ADD THIS SETTINGS BLOCK
      settings = {
        python = {
          analysis = {
            -- "off" = chill mode. Only syntax errors.
            -- "basic" = default (complains about missing imports/types).
            -- "strict" = pain.
            typeCheckingMode = "off",

            -- If you want to keep "basic" but silence specific errors, use overrides:
            diagnosticSeverityOverrides = {
              reportMissingImports = "none",
              reportUndefinedVariable = "warning", -- "error" is too loud
            },
          },
        },
      },
    }
  end,
}
