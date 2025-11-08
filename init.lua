-- init.lua -- bootloader / downloader
local component = require("component")
local term = require("term")
local fs = require("filesystem")
local shell = require("shell")

local myUser = "<GITHUB_USER>"
local myRepo = "<REPO>"
local branch = "main" -- change if different branch

local function rawURL(path)
  return ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(myUser, myRepo, branch, path)
end

local function fileExists(path)
  return fs.exists(path)
end

local function tryLoadCore()
  if fileExists("/os/core.lua") then
    local ok, err = pcall(function() dofile("/os/core.lua") end)
    if not ok then
      term.clear()
      print("Error running /os/core.lua:\n" .. tostring(err))
    end
    return true
  end
  return false
end

-- Attempt 1: load local
term.clear()
print("Bootloader: looking for /os/core.lua ...")
if tryLoadCore() then return end

-- Attempt 2: wget (shell) if available
local function tryWget(path, dest)
  if shell and shell.execute then
    local url = rawURL(path)
    print("Attempting wget: " .. url)
    local ok = shell.execute("wget", url, dest)
    return ok
  end
  return false
end

-- Attempt 3: component.internet
local function tryInternetLua(path, dest)
  if not component.isAvailable("internet") then return false end
  local internet = component.internet
  local url = rawURL(path)
  print("Downloading via component.internet: " .. url)
  local handle, err = internet.request(url)
  if not handle then
    print("internet.request failed:", tostring(err))
    return false
  end
  local content = ""
  while true do
    local chunk = handle.read(16384)
    if not chunk or chunk == "" then break end
    content = content .. chunk
  end
  handle.close()
  if content == "" then
    print("Downloaded empty content.")
    return false
  end
  -- write to dest
  local f = io.open(dest, "wb")
  if not f then
    print("Unable to open for write:", dest)
    return false
  end
  f:write(content)
  f:close()
  return true
end

-- Ensure /os folder exists
if not fileExists("/os") then
  pcall(function() fs.makeDirectory("/os") end)
end

-- Try fetch core via wget first (most user-friendly)
if not tryWget("os/core.lua", "/os/core.lua") then
  -- fallback to component.internet (if present)
  if not tryInternetLua("os/core.lua", "/os/core.lua") then
    term.clear()
    print("Could not download /os/core.lua automatically.")
    print("Options:")
    print("1) Put the files directly on the drive (copy into the map in your world folder).")
    print("2) Give this computer an Internet card and ensure outbound HTTP is allowed.")
    print("")
    print("If you want the downloader to fetch multiple files, update init.lua with your GitHub repo.")
    print("")
    print("Halting. Press any key to reboot.")
    os.pullEvent("key")
    os.execute("reboot")
    return
  end
end

-- Finally try loading
print("Running /os/core.lua")
pcall(function() dofile("/os/core.lua") end)
