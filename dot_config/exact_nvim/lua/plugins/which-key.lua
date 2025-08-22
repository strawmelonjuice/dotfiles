return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        ",?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
      {
        ",f",
        function()
            vim.cmd("Files")
        end,
        desc = "(cwd) Open file picker"
      },
      {
        ",r",
        function()
            vim.cmd("GitFiles")
        end,
        desc = "(git) Open file picker"
      },
      {
        ",/",
        function()
            vim.cmd("Rg")
        end,
        desc = "(ripgrep) Open file picker"
      },
      {
        ",s",
        function()
            vim.cmd("BLines")
        end,
        desc = "Open buffer line picker"
      },
      {
        ",b",
        function()
            vim.cmd("Buffers")
        end,
        desc = "Open buffer picker"
      },
      {
        ",\\",
        function()
            vim.cmd("vsplit")
        end,
        desc = "Open buffer picker"
      }, 
      {
        ",-",
        function()
            vim.cmd("split")
        end,
        desc = "Open buffer picker"
      }

    },
  }
