local uv = vim.uv or vim.loop

local M = {}

local data = vim.fn.stdpath("data")
local node_root = data .. "/node"
local runtime_root = node_root .. "/runtime"
local versions_root = runtime_root .. "/versions"
local current_root = runtime_root .. "/current"
local current_version_file = runtime_root .. "/current-version"
local skip_version_file = runtime_root .. "/skip-version"
local prefix_bin = node_root .. "/bin"

M.node_version = "v22.11.0"
M.node_root = node_root
M.node_bin = prefix_bin
M.runtime_root = runtime_root
M.versions_root = versions_root
M.current_root = current_root
M.current_version_file = current_version_file
M.skip_version_file = skip_version_file

local function path_exists(path)
  return uv.fs_stat(path) ~= nil
end

local function is_dir(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory" or false
end

local function path_join(...)
  return table.concat({ ... }, "/")
end

local function read_trimmed_file(path)
  if not path_exists(path) then
    return nil
  end

  local lines = vim.fn.readfile(path)
  if #lines == 0 then
    return nil
  end

  return vim.trim(table.concat(lines, "\n"))
end

local function prepend_path_entry(entry)
  if entry == nil or entry == "" or not path_exists(entry) then
    return
  end

  local path = vim.env.PATH or ""
  local parts = vim.split(path, ":", { plain = true, trimempty = true })
  for _, part in ipairs(parts) do
    if part == entry then
      return
    end
  end

  vim.env.PATH = entry .. (path == "" and "" or ":" .. path)
end

local function set_npm_prefix_env()
  vim.env.NPM_CONFIG_PREFIX = node_root
  vim.env.npm_config_prefix = node_root
end

local function legacy_node_path()
  return path_join(prefix_bin, "node")
end

local function active_runtime_bin()
  return path_join(current_root, "bin")
end

local function active_node_path()
  return path_join(active_runtime_bin(), "node")
end

local function version_root(version)
  return path_join(versions_root, version)
end

local function version_node_path(version)
  return path_join(version_root(version), "bin", "node")
end

local function current_version_from_symlink()
  local target = uv.fs_readlink(current_root)
  if not target or target == "" then
    return nil
  end

  return vim.fs.basename(target)
end

M.ensure_layout = function()
  vim.fn.mkdir(versions_root, "p")
end

M.get_version_root = function(version)
  return version_root(version or M.node_version)
end

M.get_version_node_path = function(version)
  return version_node_path(version or M.node_version)
end

M.get_active_node_path = active_node_path
M.get_active_runtime_bin = active_runtime_bin
M.get_legacy_node_path = legacy_node_path

M.get_current_version = function()
  local version = read_trimmed_file(current_version_file)
  if version and version ~= "" then
    return version
  end

  return current_version_from_symlink()
end

M.has_local_node = function()
  return path_exists(active_node_path()) or path_exists(legacy_node_path())
end

M.target_is_installed = function()
  return path_exists(version_node_path(M.node_version))
end

M.target_is_active = function()
  return path_exists(active_node_path()) and M.get_current_version() == M.node_version
end

M.get_status = function()
  local legacy = path_exists(legacy_node_path())
  local target_installed = M.target_is_installed()
  local target_active = M.target_is_active()
  local current_version = M.get_current_version()

  local state
  if target_active then
    state = "ready"
  elseif target_installed then
    state = "installed_not_active"
  elseif legacy then
    state = "legacy_only"
  else
    state = "missing"
  end

  return {
    state = state,
    legacy = legacy,
    target_installed = target_installed,
    target_active = target_active,
    current_version = current_version,
    target_version = M.node_version,
    prefix = node_root,
    runtime = current_root,
  }
end

M.ensure_path = function()
  set_npm_prefix_env()

  prepend_path_entry(prefix_bin)

  if path_exists(active_node_path()) then
    prepend_path_entry(active_runtime_bin())
  elseif path_exists(legacy_node_path()) then
    prepend_path_entry(prefix_bin)
  end
end

M.activate_version = function(version)
  local target_root = version_root(version)
  local target_node = version_node_path(version)

  if not path_exists(target_node) then
    return false, "missing Node.js runtime for " .. version
  end

  M.ensure_layout()

  local current_stat = uv.fs_lstat(current_root)
  if current_stat then
    if current_stat.type == "link" then
      uv.fs_unlink(current_root)
    else
      vim.fn.delete(current_root, "rf")
    end
  end

  local ok, err = uv.fs_symlink(target_root, current_root)
  if not ok then
    return false, err or "failed to activate Node.js runtime"
  end

  vim.fn.writefile({ version }, current_version_file)
  M.ensure_path()
  return true
end

M.reconcile_current = function()
  if M.target_is_active() then
    return true
  end

  if not M.target_is_installed() then
    return false, "target runtime missing"
  end

  return M.activate_version(M.node_version)
end

M.get_skipped_version = function()
  return read_trimmed_file(skip_version_file)
end

M.skip_current_version = function()
  M.ensure_layout()
  vim.fn.writefile({ M.node_version }, skip_version_file)
end

M.clear_skip = function()
  if path_exists(skip_version_file) then
    vim.fn.delete(skip_version_file)
  end
end

M.is_skip_active = function()
  return M.get_skipped_version() == M.node_version
end

M.is_runtime_dir = is_dir

return M
