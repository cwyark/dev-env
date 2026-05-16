local manager = require("scripts.node_manager")
local uv = vim.uv or vim.loop

local M = {}

local commands_registered = false
local install_in_progress = false

local function path_join(...)
  return table.concat({ ... }, "/")
end

local function path_exists(path)
  return uv.fs_stat(path) ~= nil
end

local function rm_rf(path)
  if path_exists(path) then
    vim.fn.delete(path, "rf")
  end
end

local function get_node_download_info()
  local version = manager.node_version
  local os = jit.os:lower()
  local arch = jit.arch

  local targets = {
    ["osx:arm64"] = "darwin-arm64",
    ["osx:x64"] = "darwin-x64",
    ["linux:x64"] = "linux-x64",
    ["linux:arm64"] = "linux-arm64",
  }

  local target = targets[string.format("%s:%s", os, arch)]
  if not target then
    return nil
  end

  local archive_name = string.format("node-%s-%s.tar.xz", version, target)
  return {
    version = version,
    archive_name = archive_name,
    archive_url = string.format("https://nodejs.org/dist/%s/%s", version, archive_name),
    shasums_url = string.format("https://nodejs.org/dist/%s/SHASUMS256.txt", version),
    target_root = manager.get_version_root(version),
  }
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

local function run_system(cmd, on_done)
  vim.system(cmd, { text = true }, function(res)
    on_done(res)
  end)
end

local function download(url, destination, label, cb)
  run_system({
    "curl",
    "-fL",
    "--retry", "3",
    "--retry-delay", "1",
    "--connect-timeout", "15",
    "-o", destination,
    url,
  }, function(res)
    if res.code ~= 0 then
      cb(false, string.format("%s failed: %s", label, vim.trim(res.stderr or "")))
      return
    end

    cb(true)
  end)
end

local function parse_expected_checksum(path, archive_name)
  for _, line in ipairs(vim.fn.readfile(path)) do
    local checksum, name = line:match("^([a-fA-F0-9]+)%s+%*?(.-)%s*$")
    if checksum and name == archive_name then
      return checksum:lower()
    end
  end
end

local function get_checksum_command(file_path)
  if vim.fn.executable("shasum") == 1 then
    return { "shasum", "-a", "256", file_path }
  end
  if vim.fn.executable("sha256sum") == 1 then
    return { "sha256sum", file_path }
  end

  return nil
end

local function verify_checksum(info, archive_path, shasums_path, cb)
  local expected = parse_expected_checksum(shasums_path, info.archive_name)
  if not expected then
    cb(false, "unable to find Node.js checksum for " .. info.archive_name)
    return
  end

  local checksum_cmd = get_checksum_command(archive_path)
  if not checksum_cmd then
    cb(false, "missing checksum tool (`shasum` or `sha256sum`)")
    return
  end

  run_system(checksum_cmd, function(res)
    if res.code ~= 0 then
      cb(false, "checksum verification failed: " .. vim.trim(res.stderr or ""))
      return
    end

    local actual = (res.stdout or ""):match("^([a-fA-F0-9]+)")
    if not actual then
      cb(false, "unable to parse checksum output")
      return
    end

    if actual:lower() ~= expected then
      cb(false, string.format("checksum mismatch for %s", info.archive_name))
      return
    end

    cb(true)
  end)
end

local function extract_runtime(archive_path, staging_root, cb)
  run_system({
    "tar",
    "-xJf", archive_path,
    "-C", staging_root,
    "--strip-components=1",
  }, function(res)
    if res.code ~= 0 then
      cb(false, "extract failed: " .. vim.trim(res.stderr or ""))
      return
    end

    cb(true)
  end)
end

local function finalize_install(info, staging_root, cb)
  rm_rf(info.target_root)

  local ok, err = uv.fs_rename(staging_root, info.target_root)
  if not ok then
    rm_rf(staging_root)
    cb(false, err or "failed to move Node.js runtime into place")
    return
  end

  local activated, activate_err = manager.activate_version(info.version)
  if not activated then
    cb(false, activate_err or "failed to activate Node.js runtime")
    return
  end

  cb(true)
end

local function install_target_runtime(cb)
  local info = get_node_download_info()
  if not info then
    cb(false, "unsupported OS/arch for local Node.js bootstrap")
    return
  end

  if manager.target_is_installed() then
    local ok, err = manager.reconcile_current()
    cb(ok, err)
    return
  end

  manager.ensure_layout()

  local cache_dir = vim.fn.stdpath("cache")
  local archive_path = path_join(cache_dir, info.archive_name)
  local shasums_path = path_join(cache_dir, string.format("node-%s-SHASUMS256.txt", info.version))
  local staging_root = path_join(manager.versions_root, string.format(".tmp-%s-%d", info.version, uv.hrtime()))

  rm_rf(staging_root)
  vim.fn.mkdir(staging_root, "p")

  notify(string.format("Installing local Node.js %s ...", info.version), vim.log.levels.INFO)

  download(info.archive_url, archive_path, "Node.js download", function(ok, err)
    if not ok then
      rm_rf(staging_root)
      cb(false, err)
      return
    end

    download(info.shasums_url, shasums_path, "Node.js checksum download", function(ok2, err2)
      if not ok2 then
        rm_rf(staging_root)
        cb(false, err2)
        return
      end

      verify_checksum(info, archive_path, shasums_path, function(ok3, err3)
        if not ok3 then
          rm_rf(staging_root)
          cb(false, err3)
          return
        end

        extract_runtime(archive_path, staging_root, function(ok4, err4)
          if not ok4 then
            rm_rf(staging_root)
            cb(false, err4)
            return
          end

          finalize_install(info, staging_root, cb)
        end)
      end)
    end)
  end)
end

local function summarize_status()
  local status = manager.get_status()
  local current = status.current_version or (status.legacy and "legacy prefix install") or "none"
  local lines = {
    string.format("Target version: %s", status.target_version),
    string.format("State: %s", status.state),
    string.format("Current version: %s", current),
    string.format("Prefix: %s", status.prefix),
    string.format("Runtime: %s", status.runtime),
  }

  if status.legacy then
    table.insert(lines, "Legacy prefix install detected.")
  end

  return table.concat(lines, "\n")
end

local function prompt_for_install()
  local status = manager.get_status()
  local current = status.current_version or (status.legacy and "legacy prefix install") or "missing"

  local choice = vim.fn.confirm(
    table.concat({
      string.format("Neovim uses a local Node.js runtime under:\n%s", manager.node_root),
      "",
      string.format("Target version: %s", status.target_version),
      string.format("Current state: %s", current),
      "",
      "Install or upgrade now?",
    }, "\n"),
    "&Install\n&Later\n&Snooze this version",
    status.legacy and 2 or 1
  )

  if choice == 1 then
    manager.clear_skip()
    return true
  end

  if choice == 3 then
    manager.skip_current_version()
    notify("Local Node.js install snoozed for this pinned version.", vim.log.levels.INFO)
  end

  return false
end

local function install_and_report(opts)
  opts = opts or {}

  if install_in_progress then
    notify("Local Node.js install already in progress.", vim.log.levels.INFO)
    return
  end

  install_in_progress = true
  manager.clear_skip()

  install_target_runtime(function(ok, err)
    install_in_progress = false

    if not ok then
      notify("Local Node.js install failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
      return
    end

    manager.ensure_path()
    notify(string.format("Local Node.js %s is ready.", manager.node_version), vim.log.levels.INFO)

    if opts.on_complete then
      opts.on_complete()
    end
  end)
end

M.register_commands = function()
  if commands_registered then
    return
  end

  vim.api.nvim_create_user_command("NodeInstall", function()
    install_and_report()
  end, { desc = "Install or upgrade Neovim-local Node.js" })

  vim.api.nvim_create_user_command("NodeReconcile", function()
    local ok, err = manager.reconcile_current()
    if ok then
      manager.ensure_path()
      vim.notify("Reconciled Neovim-local Node.js runtime.", vim.log.levels.INFO)
    else
      vim.notify("Node.js reconcile failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
    end
  end, { desc = "Re-point Neovim-local Node.js current runtime" })

  vim.api.nvim_create_user_command("NodeStatus", function()
    vim.notify(summarize_status(), vim.log.levels.INFO)
  end, { desc = "Show Neovim-local Node.js status" })

  commands_registered = true
end

M.ensure_node = function(opts)
  opts = opts or {}

  manager.ensure_layout()
  manager.ensure_path()

  local status = manager.get_status()
  if status.target_active then
    return
  end

  if status.target_installed then
    local ok, err = manager.reconcile_current()
    if ok then
      manager.ensure_path()
      return
    end

    notify("Local Node.js runtime needs repair: " .. (err or "unknown issue"), vim.log.levels.WARN)
  end

  if opts.force then
    install_and_report(opts)
    return
  end

  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  if manager.is_skip_active() then
    return
  end

  if prompt_for_install() then
    install_and_report(opts)
  end
end

return M
