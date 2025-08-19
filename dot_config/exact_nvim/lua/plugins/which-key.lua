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
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
      {
        "<leader>f",
        function()
            vim.cmd("Files")
        end,
        desc = "(cwd) Open file picker"
      },
      {
        "<leader>r",
        function()
            vim.cmd("GitFiles")
        end,
        desc = "(git) Open file picker"
      },
      {
        "<leader>/",
        function()
            vim.cmd("Rg")
        end,
        desc = "(ripgrep) Open file picker"
      },
      {
        "<leader>s",
        function()
            vim.cmd("BLines")
        end,
        desc = "Open buffer line picker"
      },
      {
        "<leader>b",
        function()
            vim.cmd("Buffers")
        end,
        desc = "Open buffer picker"
      },
    },
  }
  