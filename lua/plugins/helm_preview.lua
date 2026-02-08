-- Helper: Prompts for args and pipes content to kubectl apply
local function run_kubectl_apply(content)
  vim.ui.input({ prompt = "Kubectl Args (e.g., -n test): " }, function(input)
    if input == nil then
      return
    end -- Cancelled

    local args = input or ""
    local cmd = string.format("kubectl apply %s -f -", args)

    print("Applying to cluster...")
    local output = vim.fn.system(cmd, content)

    if vim.v.shell_error == 0 then
      print("✅ Success:\n" .. output)
    else
      vim.notify("❌ Error:\n" .. output, vim.log.levels.ERROR)
    end
  end)
end

-- Generator Logic
-- Accepts an optional 'custom_values_path'
local function get_helm_template_cmd(custom_values_path)
  local curr_file = vim.api.nvim_buf_get_name(0)

  -- 1. Find Chart Root (Unchanged logic)
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
    return nil, "Error: No Chart.yaml found."
  end

  local relative_path = vim.fn.fnamemodify(curr_file, ":.")

  -- 2. Determine Values File
  -- Use the custom path if provided, otherwise default to "values.yaml"
  -- Note: The path should be relative to the Chart Root
  local values_file = (custom_values_path and custom_values_path ~= "") and custom_values_path or "values.yaml"

  -- Return the execution closure
  return function()
    local old_cwd = vim.fn.getcwd()
    vim.api.nvim_set_current_dir(chart_root)

    -- We use the determined 'values_file' here
    local cmd = string.format(
      "helm template . -s %s -f %s 2>&1",
      vim.fn.shellescape(relative_path),
      vim.fn.shellescape(values_file)
    )

    local output = vim.fn.system(cmd)

    vim.api.nvim_set_current_dir(old_cwd)
    return output, relative_path, values_file
  end
end

-- COMMAND 1: Preview (View -> Verify -> Apply)
-- nargs = "?" allows 0 or 1 argument
vim.api.nvim_create_user_command("HelmPreview", function(opts)
  vim.cmd("write")

  -- opts.args contains the command argument (e.g., "values.dev.yaml")
  local generator, err = get_helm_template_cmd(opts.args)
  if not generator then
    print(err)
    return
  end

  local output, rel_path, used_values = generator()

  -- Render Output
  vim.cmd("vnew")
  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "yaml"

  local lines = vim.split(output, "\n")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Add values file to buffer name for clarity
  local buf_name = string.format("helm://%s [%s]:%s", rel_path, used_values, os.time())
  pcall(vim.api.nvim_buf_set_name, buf, buf_name)

  -- Buffer-Specific Keymap
  vim.keymap.set("n", "<leader>K", function()
    local current_content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    run_kubectl_apply(current_content)
  end, { buffer = buf, desc = "[K]ubectl Apply Buffer" })

  print("Previewing using " .. used_values .. ". Press <leader>K to apply.")
end, { nargs = "?" })

-- COMMAND 2: Direct Apply (No Preview)
vim.api.nvim_create_user_command("HelmApply", function(opts)
  vim.cmd("write")

  local generator, err = get_helm_template_cmd(opts.args)
  if not generator then
    print(err)
    return
  end

  local output, _, used_values = generator()

  if output:lower():match("error") and not output:lower():match("kind:") then
    vim.notify("Helm Template Failed:\n" .. output, vim.log.levels.ERROR)
    return
  end

  print("Template generated using " .. used_values)
  run_kubectl_apply(output)
end, { nargs = "?" })

-- Keymaps (Defaults use values.yaml)
vim.keymap.set("n", "<leader>ht", "<cmd>HelmPreview<CR>", { desc = "Helm Template Preview" })
vim.keymap.set("n", "<leader>ha", "<cmd>HelmApply<CR>", { desc = "Helm Direct Apply" })
