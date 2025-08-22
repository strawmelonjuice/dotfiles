vim.opt.termguicolors = true
local default_light = "dayfox"
local default_dark = "tokyonight-night"
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
  -- // Themes
  { "EdenEast/nightfox.nvim" },
  { "folke/tokyonight.nvim"  },
  -- // Auto theme switcher
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