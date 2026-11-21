-- init.lua — Neovim entry point (nvim 0.12; plugin manager: lazy.nvim).
--   1. Install lazy.nvim into stdpath("data")/lazy if it is missing (shallow
--      git clone of the `stable` branch) and add it to the runtimepath.
--   2. Load lua/options.lua and lua/keymaps.lua.
--   3. lazy.setup("plugins"): every spec file in lua/plugins/ is loaded.
--      lazy.nvim options set below:
--        change_detection.notify = false   no message when a spec file changes
--        checker.enabled = false           no background update checks
--        rocks.hererocks = false           no hererocks install for luarocks
--      Not set: install, ui, performance, defaults, lockfile (default
--      stdpath("config")/lazy-lock.json; .gitignore leaves it untracked).
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("keymaps")

require("lazy").setup("plugins", {
  change_detection = { notify = false },
  checker = { enabled = false },
  rocks = { hererocks = false },
})

-- Colorscheme: lua/plugins/base16.lua loads RRethy/base16-nvim and runs
-- require("matugen").setup() from lua/matugen.lua, a generated file (Noctalia's
-- "neovim" template output, regenerated on each wallpaper change, gitignored).
-- No colorscheme call is needed here.
