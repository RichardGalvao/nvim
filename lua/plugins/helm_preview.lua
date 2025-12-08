vim.api.nvim_create_user_command("HelmPreview", function()
  -- 1. Save buffer to ensure disk content matches editor
  vim.cmd("write")

  local curr_file = vim.api.nvim_buf_get_name(0)

  -- 2. Find Chart Root
  local function find_chart_root(start_path)
    local result = vim.fs.find("Chart.yaml", {
      path = start_path,
      upward = true,
      stop = vim.loop.os_homedir(),
      type = "file",
    })
    return #result > 0 and vim.fn.fnamemodify(result[1], ":h") or nil
  end

  local chart_root = find_chart_root(vim.fn.fnamemodify(curr_file, ":h"))
  if not chart_root then
    print("Error: No Chart.yaml found.")
    return
  end

  -- 3. Change Directory & Calculate Path Natively
  local old_cwd = vim.fn.getcwd()
  vim.api.nvim_set_current_dir(chart_root)

  -- ":." asks Vim for the path relative to the *current working directory* (which is now chart_root)
  -- This creates a perfectly clean string like "templates/jupyterlab/jupyter.yaml"
  local relative_path = vim.fn.fnamemodify(curr_file, ":.")

  -- 4. Execute Helm
  -- We use "." for chart path, and the clean relative path for -s
  local cmd = string.format("helm template . -s %s -f values.yaml 2>&1", vim.fn.shellescape(relative_path))

  local output = vim.fn.systemlist(cmd)

  -- Restore Directory
  vim.api.nvim_set_current_dir(old_cwd)

  -- 5. Render Output
  vim.cmd("vnew")
  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "yaml"

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  -- Unique name to prevent watcher issues
  local buf_name = "helm://" .. relative_path .. ":" .. os.time()
  pcall(vim.api.nvim_buf_set_name, buf, buf_name)
end, {})

vim.keymap.set("n", "<leader>ht", "<cmd>HelmPreview<CR>", { desc = "Helm Template Preview" })
