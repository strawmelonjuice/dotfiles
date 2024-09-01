vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end
})
local w = 0;
function switch_between_outline_and_filetree()
  return function()
    vim.cmd([[Outline]])
    vim.cmd([[OutlineClose]])
    vim.cmd([[NvimTreeClose]])
    local sec = tonumber(os.clock() + .5);
    while (os.clock() < sec) do
      -- Wait half a second so that the outline window can be closed
    end
    if w == 1 then
      vim.cmd([[NvimTreeOpen]])
      w = 0
    else
      vim.cmd([[OutlineOpen]])
      w = 1
    end
  end
end

return { { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        on_attach = "default",
        hijack_cursor = false,
        auto_reload_on_write = true,
        disable_netrw = true,
        hijack_netrw = true,
        hijack_unnamed_buffer_when_opening = false,
        root_dirs = {},
        prefer_startup_root = false,
        sync_root_with_cwd = true,
        reload_on_bufenter = false,
        respect_buf_cwd = false,
        select_prompts = false,
        sort = {
          sorter = "name",
          folders_first = true,
          files_first = false,
        },
        view = {
          side = 'right',
          centralize_selection = true,
          cursorline = true,
          debounce_delay = 15,
          preserve_window_proportions = false,
          number = false,
          relativenumber = true,
          signcolumn = "yes",
          width = 50,
        },
        renderer = {
          add_trailing = false,
          group_empty = false,
          full_name = false,
          root_folder_label = ":~:s?$?/..?",
          indent_width = 2,
          special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
          symlink_destination = true,
          highlight_git = "none",
          highlight_diagnostics = "none",
          highlight_opened_files = "none",
          highlight_modified = "none",
          highlight_hidden = "none",
          highlight_bookmarks = "none",
          highlight_clipboard = "name",
          indent_markers = {
            enable = false,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "─",
              none = " ",
            },
          },
          icons = {
            web_devicons = {
              file = {
                enable = true,
                color = true,
              },
              folder = {
                enable = false,
                color = true,
              },
            },
            git_placement = "before",
            modified_placement = "after",
            hidden_placement = "after",
            diagnostics_placement = "signcolumn",
            bookmarks_placement = "signcolumn",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
              hidden = true,
              diagnostics = true,
              bookmarks = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "󰆤",
              modified = "●",
              hidden = "󰜌",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        update_focused_file = {
          enable = false,
          update_root = {
            enable = false,
            ignore_list = {},
          },
          exclude = false,
        },
        system_open = {
          cmd = "",
          args = {},
        },
        git = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          disable_for_dirs = {},
          timeout = 400,
          cygwin_support = false,
        },
        diagnostics = {
          enable = false,
          show_on_dirs = false,
          show_on_open_dirs = true,
          debounce_delay = 50,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },
        modified = {
          enable = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
        },
        filters = {
          enable = true,
          git_ignored = false,
          dotfiles = true,
          git_clean = false,
          no_buffer = false,
          no_bookmark = false,
          custom = {},
          exclude = {},
        },
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = true,
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {},
        },
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = {},
          },
          file_popup = {
            open_win_config = {
              col = 1,
              row = 1,
              relative = "cursor",
              border = "shadow",
              style = "minimal",
            },
          },
          open_file = {
            quit_on_open = true,
            eject = true,
            resize_window = true,
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
          remove_file = {
            close_window = true,
          },
        },
        trash = {
          cmd = "gio trash",
        },
        tab = {
          sync = {
            open = false,
            close = false,
            ignore = {},
          },
        },
        notify = {
          threshold = vim.log.levels.INFO,
          absolute_path = true,
        },
        help = {
          sort_by = "key",
        },
        ui = {
          confirm = {
            remove = true,
            trash = true,
            default_yes = false,
          },
        },
        experimental = {
          actions = {
            open_file = {
              relative_path = false,
            },
          },
        },
        log = {
          enable = false,
          truncate = false,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
          },
        },
      })
    end,
    keys = {
      {
        "<C-\\>",
        switch_between_outline_and_filetree(),
        mode = { "n", "t", "i", "v" },
        desc = "Toggle nvim-tree"
      },
      { "<C-|>", function() vim.cmd([[NvimTreeFindFile]]) end, desc = "Show current file in nvim-tree" },
      {
        "<leader>e",
        function()
          vim.cmd([[OutlineClose]])
          vim.cmd([[NvimTreeOpen]])
          w = 0
          vim.cmd([[NvimTreeCollapse]])
        end,
        mode = { "n", "t" },
        desc = "Toggle collapsed nvim-tree"
      },
    },
  },
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'b0o/nvim-tree-preview.lua',
    },
  },
  {
    'nvim-lua/plenary.nvim',
  },

  {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup {
        outline_window = {
          -- Where to open the split window: right/left
          position = 'right',
          -- The default split commands used are 'topleft vs' and 'botright vs'
          -- depending on `position`. You can change this by providing your own
          -- `split_command`.
          -- `position` will not be considered if `split_command` is non-nil.
          -- This should be a valid vim command used for opening the split for the
          -- outline window. Eg, 'rightbelow vsplit'.
          -- Width can be included (with will override the width setting below):
          -- Eg, `topleft 20vsp` to prevent a flash of windows when resizing.
          split_command = nil,

          -- Percentage or integer of columns
          width = 25,
          -- Whether width is relative to the total width of nvim
          -- When relative_width = true, this means take 25% of the total
          -- screen width for outline window.
          relative_width = true,

          -- Auto close the outline window if goto_location is triggered and not for
          -- peek_location
          auto_close = true,
          -- Automatically scroll to the location in code when navigating outline window.
          auto_jump = false,
          -- boolean or integer for milliseconds duration to apply a temporary highlight
          -- when jumping. false to disable.
          jump_highlight_duration = 300,
          -- Whether to center the cursor line vertically in the screen when
          -- jumping/focusing. Executes zz.
          center_on_jump = true,

          -- Vim options for the outline window
          show_numbers = true,
          show_relative_numbers = true,
          wrap = false,

          -- true/false/'focus_in_outline'/'focus_in_code'.
          -- The last two means only show cursorline when the focus is in outline/code.
          -- 'focus_in_outline' can be used if the outline_items.auto_set_cursor
          -- operations are too distracting due to visual contrast caused by cursorline.
          show_cursorline = true,
          -- Enable this only if you enabled cursorline so your cursor color can
          -- blend with the cursorline, in effect, as if your cursor is hidden
          -- in the outline window.
          -- This makes your line of cursor have the same color as if the cursor
          -- wasn't focused on the outline window.
          -- This feature is experimental.
          hide_cursor = false,

          -- Whether to auto-focus on the outline window when it is opened.
          -- Set to false to *always* retain focus on your previous buffer when opening
          -- outline.
          -- If you enable this you can still use bangs in :Outline! or :OutlineOpen! to
          -- retain focus on your code. If this is false, retaining focus will be
          -- enforced for :Outline/:OutlineOpen and you will not be able to have the
          -- other behaviour.
          focus_on_open = false,
          -- Winhighlight option for outline window.
          -- See :help 'winhl'
          -- To change background color to "CustomHl" for example, use "Normal:CustomHl".
          winhl = '',
        },

        outline_items = {
          -- Show extra details with the symbols (lsp dependent) as virtual next
          show_symbol_details = true,
          -- Show corresponding line numbers of each symbol on the left column as
          -- virtual text, for quick navigation when not focused on outline.
          -- Why? See this comment:
          -- https://github.com/simrat39/symbols-outline.nvim/issues/212#issuecomment-1793503563
          show_symbol_lineno = false,
          -- Whether to highlight the currently hovered symbol and all direct parents
          highlight_hovered_item = true,
          -- Whether to automatically set cursor location in outline to match
          -- location in code when focus is in code. If disabled you can use
          -- `:OutlineFollow[!]` from any window or `<C-g>` from outline window to
          -- trigger this manually.
          auto_set_cursor = true,
          -- Autocmd events to automatically trigger these operations.
          auto_update_events = {
            -- Includes both setting of cursor and highlighting of hovered item.
            -- The above two options are respected.
            -- This can be triggered manually through `follow_cursor` lua API,
            -- :OutlineFollow command, or <C-g>.
            follow = { 'CursorMoved' },
            -- Re-request symbols from the provider.
            -- This can be triggered manually through `refresh_outline` lua API, or
            -- :OutlineRefresh command.
            items = { 'InsertLeave', 'WinEnter', 'BufEnter', 'BufWinEnter', 'TabEnter', 'BufWritePost' },
          },
        },

        -- Options for outline guides which help show tree hierarchy of symbols
        guides = {
          enabled = true,
          markers = {
            -- It is recommended for bottom and middle markers to use the same number
            -- of characters to align all child nodes vertically.
            bottom = '└',
            middle = '├',
            vertical = '│',
          },
        },

        symbol_folding = {
          -- Depth past which nodes will be folded by default. Set to false to unfold all on open.
          autofold_depth = 1,
          -- When to auto unfold nodes
          auto_unfold = {
            -- Auto unfold currently hovered symbol
            hovered = true,
            -- Auto fold when the root level only has this many nodes.
            -- Set true for 1 node, false for 0.
            only = true,
          },
          markers = { '', '' },
        },

        preview_window = {
          -- Automatically open preview of code location when navigating outline window
          auto_preview = false,
          -- Automatically open hover_symbol when opening preview (see keymaps for
          -- hover_symbol).
          -- If you disable this you can still open hover_symbol using your keymap
          -- below.
          open_hover_on_preview = false,
          width = 15,     -- Percentage or integer of columns
          min_width = 15, -- This is the number of columns
          -- Whether width is relative to the total width of nvim.
          -- When relative_width = true, this means take 50% of the total
          -- screen width for preview window, ensure the result width is at least 50
          -- characters wide.
          relative_width = true,
          -- Border option for floating preview window.
          -- Options include: single/double/rounded/solid/shadow or an array of border
          -- characters.
          -- See :help nvim_open_win() and search for "border" option.
          border = 'single',
          -- winhl options for the preview window, see ':h winhl'
          winhl = 'NormalFloat:',
          -- Pseudo-transparency of the preview window, see ':h winblend'
          winblend = 0,
          -- Experimental feature that let's you edit the source content live
          -- in the preview window. Like VS C*de's "peek editor".
          live = false
        },

        -- These keymaps can be a string or a table for multiple keys.
        -- Set to `{}` to disable. (Using 'nil' will fallback to default keys)
        keymaps = {
          show_help = '?',
          close = { '<Esc>', 'q' },
          -- Jump to symbol under cursor.
          -- It can auto close the outline window when triggered, see
          -- 'auto_close' option above.
          goto_location = '<Cr>',
          -- Jump to symbol under cursor but keep focus on outline window.
          peek_location = 'l',
          -- Visit location in code and close outline immediately
          goto_and_close = '<S-Cr>',
          -- Change cursor position of outline window to match current location in code.
          -- 'Opposite' of goto/peek_location.
          restore_location = '<C-g>',
          -- Open LSP/provider-dependent symbol hover information
          hover_symbol = '<C-space>',
          -- Preview location code of the symbol under cursor
          toggle_preview = 'K',
          rename_symbol = 'r',
          code_actions = 'a',
          -- These fold actions are collapsing tree nodes, not code folding
          fold = 'h',
          unfold = 'o',
          fold_toggle = '<Tab>',
          -- Toggle folds for all nodes.
          -- If at least one node is folded, this action will fold all nodes.
          -- If all nodes are folded, this action will unfold all nodes.
          fold_toggle_all = '<S-Tab>',
          fold_all = 'W',
          unfold_all = 'E',
          fold_reset = 'R',
          -- Move down/up by one line and peek_location immediately.
          -- You can also use outline_window.auto_jump=true to do this for any
          -- j/k/<down>/<up>.
          down_and_jump = '<C-j>',
          up_and_jump = '<C-k>',
        },

        providers = {
          priority = { 'lsp', 'coc', 'markdown', 'norg' },
          -- Configuration for each provider (3rd party providers are supported)
          lsp = {
            -- Lsp client names to ignore
            blacklist_clients = {},
          },
          markdown = {
            -- List of supported ft's to use the markdown provider
            filetypes = { 'markdown' },
          },
        },

        symbols = {
          -- Filter by kinds (string) for symbols in the outline.
          -- Possible kinds are the Keys in the icons table below.
          -- A filter list is a string[] with an optional exclude (boolean) field.
          -- The symbols.filter option takes either a filter list or ft:filterList
          -- key-value pairs.
          -- Put  exclude=true  in the string list to filter by excluding the list of
          -- kinds instead.
          -- Include all except String and Constant:
          --   filter = { 'String', 'Constant', exclude = true }
          -- Only include Package, Module, and Function:
          --   filter = { 'Package', 'Module', 'Function' }
          -- See more examples below.
          filter = nil,

          -- You can use a custom function that returns the icon for each symbol kind.
          -- This function takes a kind (string) as parameter and should return an
          -- icon as string.
          ---@param kind string Key of the icons table below
          ---@param bufnr integer Code buffer
          ---@returns string|boolean The icon string to display, such as "f", or `false`
          ---                        to fallback to `icon_source`.
          icon_fetcher = nil,
          -- 3rd party source for fetching icons. This is used as a fallback if
          -- icon_fetcher returned an empty string.
          -- Currently supported values: 'lspkind'
          icon_source = nil,
          -- The next fallback if both icon_fetcher and icon_source has failed, is
          -- the custom mapping of icons specified below. The icons table is also
          -- needed for specifying hl group.
          icons = {
            File = { icon = '󰈔', hl = 'Identifier' },
            Module = { icon = '󰆧', hl = 'Include' },
            Namespace = { icon = '󰅪', hl = 'Include' },
            Package = { icon = '󰏗', hl = 'Include' },
            Class = { icon = '𝓒', hl = 'Type' },
            Method = { icon = 'ƒ', hl = 'Function' },
            Property = { icon = '', hl = 'Identifier' },
            Field = { icon = '󰆨', hl = 'Identifier' },
            Constructor = { icon = '', hl = 'Special' },
            Enum = { icon = 'ℰ', hl = 'Type' },
            Interface = { icon = '󰜰', hl = 'Type' },
            Function = { icon = '', hl = 'Function' },
            Variable = { icon = '', hl = 'Constant' },
            Constant = { icon = '', hl = 'Constant' },
            String = { icon = '𝓐', hl = 'String' },
            Number = { icon = '#', hl = 'Number' },
            Boolean = { icon = '⊨', hl = 'Boolean' },
            Array = { icon = '󰅪', hl = 'Constant' },
            Object = { icon = '⦿', hl = 'Type' },
            Key = { icon = '🔐', hl = 'Type' },
            Null = { icon = 'NULL', hl = 'Type' },
            EnumMember = { icon = '', hl = 'Identifier' },
            Struct = { icon = '𝓢', hl = 'Structure' },
            Event = { icon = '🗲', hl = 'Type' },
            Operator = { icon = '+', hl = 'Identifier' },
            TypeParameter = { icon = '𝙏', hl = 'Identifier' },
            Component = { icon = '󰅴', hl = 'Function' },
            Fragment = { icon = '󰅴', hl = 'Constant' },
            TypeAlias = { icon = ' ', hl = 'Type' },
            Parameter = { icon = ' ', hl = 'Identifier' },
            StaticMethod = { icon = ' ', hl = 'Function' },
            Macro = { icon = ' ', hl = 'Function' },
          },
        },
      }
    end,
  }, }
