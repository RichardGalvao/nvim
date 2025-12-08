vim.g.python3_host_prog = "/home/yunok/anaconda3/bin/python"

-- Use JSON parser for jsonc files (avoid broken jsonc tarball)
if vim.treesitter and vim.treesitter.language then
  vim.treesitter.language.register("json", "jsonc")
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.bigfile")

local autosave_group = vim.api.nvim_create_augroup("autosave_group", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable or not vim.bo.modified then
      return
    end
    if vim.bo.buftype ~= "" or vim.fn.expand("%") == "" then
      return
    end

    vim.cmd("silent write")
  end,
})

vim.keymap.set("n", "<leader>qp", "<cmd>q<CR>", { desc = "Quit Panel" })
vim.keymap.set("n", "<Leader>w<Left>", "<C-w>h", { desc = "Move focus to left window" })
vim.keymap.set("n", "<Leader>w<Down>", "<C-w>j", { desc = "Move focus to lower window" })
vim.keymap.set("n", "<Leader>w<Up>", "<C-w>k", { desc = "Move focus to upper window" })
vim.keymap.set("n", "<Leader>w<Right>", "<C-w>l", { desc = "Move focus to right window" })
