return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {

      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      presets = {
        command_palette = false,      -- position the cmdline and popupmenu together
        bottom_search = true,         -- use a classic bottom cmdline for search
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
      },

    },
    keys = {
      {
        "<leader>und",
        function()
          vim.cmd("NoiceDismiss")
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<leader>unh",
        function()
          vim.cmd("NoiceHistory")
        end,
        desc = "Show message history"
      }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      --   Mar: I love mini, it doesn't ruin my workflow, it keeps out of the way... I love it. Keep nvim-notify disabled!
      -- "rcarriga/nvim-notify",
      "hrsh7th/nvim-cmp"
    }
  }
}
