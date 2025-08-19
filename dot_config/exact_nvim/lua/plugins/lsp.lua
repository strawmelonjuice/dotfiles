return {
    "neovim/nvim-lspconfig",
  
    dependencies = {
      "williamboman/mason.nvim",
    },
  
    config = function()
      local lspconfig = require("lspconfig")
      local mason = require("mason")
  
      mason.setup()
  
      lspconfig.rust_analyzer.setup({})
      lspconfig.gleam.setup({})
  
    end,
  }
  