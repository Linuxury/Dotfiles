-- keymaps.lua — global key mappings (vim.keymap.set(mode, lhs, rhs, opts)).
-- Leader keys are set in lua/options.lua; plugin-specific maps live in the
-- plugin spec files (snacks.lua, ai.lua, editor.lua, ...).

-- n / N (next/previous search result, folds opened with zv) and Ctrl-d / Ctrl-u
-- (half page down/up) keep the cursor line centred (zz)
vim.keymap.set("n", "n",      "nzzzv",   { desc = "Next result (centered)" })
vim.keymap.set("n", "N",      "Nzzzv",   { desc = "Prev result (centered)" })
vim.keymap.set("n", "<C-d>",  "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>",  "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffers: Tab / Shift-Tab cycle
vim.keymap.set("n", "<Tab>",   "<Cmd>bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>bprevious<CR>", { desc = "Prev buffer" })

-- Windows: Ctrl-h/j/k/l move focus
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Splits: <leader>sv vertical, <leader>sh horizontal
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>",  { desc = "Split horizontal" })

-- Resize the focused window: Ctrl-Arrow keys, 2 lines/columns per press
vim.keymap.set("n", "<C-Up>",    "<Cmd>resize +2<CR>",          { desc = "Increase height" })
vim.keymap.set("n", "<C-Down>",  "<Cmd>resize -2<CR>",          { desc = "Decrease height" })
vim.keymap.set("n", "<C-Left>",  "<Cmd>vertical resize -2<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- Visual mode: < and > re-select after indenting so it can be repeated
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- J joins lines and returns the cursor to where it was (mark z)
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })

-- Visual mode p: replace the selection without overwriting the unnamed register
vim.keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

-- Ctrl-s saves, in normal and insert mode
vim.keymap.set({ "n", "i" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save file" })

-- <leader>rc opens init.lua
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

-- <leader>rr re-sources init.lua and re-runs matugen.setup() to reapply the theme
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd.source(vim.fn.stdpath("config") .. "/init.lua")
  package.loaded["matugen"] = nil
  require("matugen").setup()
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload config" })

-- <leader>mp starts the markdown-preview.nvim browser preview
vim.keymap.set("n", "<leader>mp", "<Cmd>MarkdownPreview<CR>",       { desc = "Markdown preview" })
vim.keymap.set("n", "<leader>mt", "<Cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle MD preview" })
vim.keymap.set("n", "<leader>ms", "<Cmd>MarkdownPreviewStop<CR>",   { desc = "Stop MD preview" })
