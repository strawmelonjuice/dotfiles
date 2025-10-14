vim.opt.termguicolors = true
-- local default_light = "gruvbox"
-- local default_light = "dayfox"
local default_light = "rose-pine-dawn"
local default_dark = "tokyonight-night"
-- local default_dark = "kanagawa-wave"
-- local default_dark = "rose-pine-main"
local default_show = "koehler"

local get_time_of_day = function()
  local hour = tonumber(os.date("%H"))
  if hour >= 6 and hour < 12 then
    return "morning"
  elseif hour >= 12 and hour < 18 then
    return "afternoon"
  elseif hour >= 18 and hour < 24 then
    return "evening"
  else
    return "night"
  end
end
local get_colorscheme = function(a)
  if a == "random" then
    math.randomseed(os.time())
    math.random(); math.random(); math.random();
    local random = math.ceil((math.random(0.1, 1.9) / 2)) - 1;
    vim.notify_once("[Random colorscheme]: random = " .. random .. " - " .. (random == 1 and "light" or "dark"))

    if random == 1 then return default_light end
    if random == 0 then return default_dark end
    return "default"
  else
    if a == "tod" then
      local tod = get_time_of_day()
      if (tod == "morning") or (tod == "afternoon") then
        vim.notify_once("Good " .. tod .. " Mar! colorscheme auto set to: " .. default_light)
        return default_light
      end
      if (tod == "evening") or (tod == "night") then
        vim.notify_once("Good " .. tod .. " Mar! colorscheme auto set to: " .. default_dark)
        return default_dark
      end
    end
  end
end;
local get_background = function(a)
  if a == "random" then
    math.randomseed(os.time())
    math.random(); math.random(); math.random();
    local random = math.ceil((math.random(0.1, 1.9) / 2)) - 1;
    vim.notify_once("[Random background]: random = " .. random .. " - " .. (random == 1 and "light" or "dark"))

    if random == 1 then return "light" end
    if random == 0 then return "dark" end
    return "default"
  else
    if a == "tod" then
      local tod = get_time_of_day()
      if (tod == "morning") or (tod == "afternoon") then
        vim.notify_once("Good " .. tod .. " Mar! background auto set to: light")
        return "light"
      end
      if (tod == "evening") or (tod == "night") then
        vim.notify_once("Good " .. tod .. " Mar! background auto set to: dark")
        return "dark"
      end
    end
  end
end;
return {
  { "haystackandroid/carbonized" },
  { "xiyaowong/transparent.nvim" },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    config = function()
      require('kanagawa').setup({
        compile = false,  -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true,    -- do not set background color
        dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = {             -- add/modify theme and palette colors
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors) -- add/modify highlights
          return {}
        end,
        theme = "wave",  -- Load "wave" theme when 'background' option is not set
        background = {   -- map the value of 'background' option to a theme
          dark = "wave", -- try "dragon" !
          light = "lotus"
        },
      })
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require('rose-pine').setup({
        --- @usage 'auto'|'main'|'moon'|'dawn'
        variant = 'dawn',
        --- @usage 'main'|'moon'|'dawn'
        dark_variant = 'moon',
        bold_vert_split = false,
        dim_nc_background = true,
        disable_background = true,
        disable_float_background = false,
        disable_italics = false,

        --- @usage string hex value or named color from rosepinetheme.com/palette
        groups = {
          background = 'base',
          background_nc = '_experimental_nc',
          panel = 'surface',
          panel_nc = 'base',
          border = 'highlight_med',
          comment = 'muted',
          link = 'iris',
          punctuation = 'subtle',

          error = 'love',
          hint = 'iris',
          info = 'foam',
          warn = 'gold',

          headings = {
            h1 = 'iris',
            h2 = 'foam',
            h3 = 'rose',
            h4 = 'gold',
            h5 = 'pine',
            h6 = 'foam',
          }
          -- or set all headings at once
          -- headings = 'subtle'
        },

        -- Change specific vim highlight groups
        -- https://github.com/rose-pine/neovim/wiki/Recipes
        highlight_groups = {
          ColorColumn = { bg = 'rose' },

          -- Blend colours against the "base" background
          CursorLine = { bg = 'foam', blend = 10 },
          StatusLine = { fg = 'love', bg = 'love', blend = 10 },
        }
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "latte",
        default_integrations = true,
        integrations = {
          treesitter = true,
          telescope = true,
          nvimtree = true,
          noice = true,
        },
        term_colors = true,
        transparent_background = false,
      })
    end,
  },
  { "EdenEast/nightfox.nvim" },
  { "tanvirtin/monokai.nvim" },
  { "ellisonleao/gruvbox.nvim" },
  { "sts10/vim-pink-moon" },
  { "rktjmp/lush.nvim" },
  {
    'maxmx03/fluoromachine.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      local fm = require 'fluoromachine'

      fm.setup {
        glow = true,
        theme = 'fluoromachine',
        transparent = false,
      }
    end
  }
  ,
  { "sainnhe/sonokai" },
  { "Scysta/pink-panic.nvim" }, { "savq/melange-nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = get_colorscheme("tod"),
      background = get_background("tod")
    },
    keys = {
      {
        "<leader>Md",
        function()
          vim.cmd("colorscheme " .. default_dark)
          vim.cmd("set background=dark")
        end,
        mode = { "n", "t" },
        desc = "Set to " .. default_dark .. " theme."
      },
      {
        "<leader>Ml",
        function()
          vim.cmd("colorscheme " .. default_light)
          vim.cmd("set background=light")
        end,
        mode = { "n", "t" },
        desc = "Set to " .. default_light .. " theme."
      },
      {
        "<leader>Mg",
        function()
          vim.cmd("colorscheme " .. default_show)
          vim.cmd("set background=default")
        end,
        mode = { "n", "t" },
        desc = "Set to " .. default_show .. " theme."
      },
      -- { "<leader>Mf", function() vim.cmd("TransparentToggle") end,             mode = { "n", "t" }, desc = "Toggle transparency." },

    },
  },
}
