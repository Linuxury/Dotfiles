return {
  -- mini.nvim modules, each loaded on VeryLazy with default options (opts = {}):
  --   ai (extra a/i text objects), comment (gc), surround (sa/sd/sr),
  --   pairs (auto-close brackets), move (Alt-hjkl moves lines/selections),
  --   cursorword (underline other uses of the word), trailspace (highlight
  --   trailing whitespace)
  { "echasnovski/mini.ai",        version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.comment",   version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.surround",  version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.pairs",     version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.move",      version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.cursorword",version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.trailspace",version = false, event = "VeryLazy", opts = {} },

  -- mini.icons, registered as a stand-in for nvim-web-devicons: plugins that
  -- require("nvim-web-devicons") get the mini.icons mock. Loaded lazily.
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- gitsigns.nvim — git change markers in the sign column (signs.* set one
  -- glyph per state: add, change, delete, topdelete, changedelete, untracked)
  -- and buffer-local hunk maps from on_attach:
  --   ]h / [h next/prev hunk    <leader>ghs/ghr stage/reset hunk
  --   <leader>ghS/ghR stage/reset buffer    ghu undo stage    ghp preview inline
  --   ghb blame line    ghd diff this
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buf, desc = desc, silent = true })
        end

        map("n", "]h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end, "Next Hunk")
        map("n", "[h", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end, "Prev Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>",  "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>",  "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer,                       "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk,                    "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer,                       "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline,                "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis,                           "Diff This")
      end,
    },
  },
}
