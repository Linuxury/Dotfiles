return {
  -- nvim-lspconfig — language server definitions. Server binaries come from
  -- Nix, not Mason. config() sets up diagnostics (lua/utils/diagnostics.lua)
  -- and starts each server in lua/servers/.
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("utils.diagnostics").setup()
      require("servers")
    end,
  },

  -- blink.cmp — completion engine (1.x), with LuaSnip + friendly-snippets.
  --   keymap: `default` preset; <CR> accepts, <Tab>/<S-Tab> select next/prev
  --   appearance.nerd_font_variant  mono | normal
  --   completion.documentation      auto-show the doc popup after 500 ms
  --   sources.default               lsp, path, snippets, buffer, lazydev
  --   snippets.preset               luasnip      signature.enabled  true
  --   fuzzy.implementation          prefer_rust_with_warning (Rust matcher,
  --                                 warn and use the Lua one if it is missing)
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "folke/lazydev.nvim",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset  = "default",
        ["<CR>"]    = { "accept", "fallback" },
        ["<Tab>"]   = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      snippets   = { preset = "luasnip" },
      fuzzy      = { implementation = "prefer_rust_with_warning" },
      signature  = { enabled = true },
    },
  },

  -- lazydev.nvim — type information for the Neovim Lua API in Lua files, so
  -- lua_ls does not report vim.* as undefined. `library` adds luv (vim.uv) and
  -- snacks.nvim (loaded when those words appear).
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library",  words = { "vim%.uv" } },
        { path = "snacks.nvim",         words = { "Snacks", "snacks%.Config" } },
      },
    },
  },
}
