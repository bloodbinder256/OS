-- init.lua (bootloader safe for BIOS / floppy)
-- Downloads core OS if missing, then runs /os/core.lua

local component = component            -- global provided by OpenComputers BIOS
local gpu = component.gpu
local screen = component.screen
local fs = filesystem or require("filesystem")

-- optional: try to bind a screen if present
local function tryBindScreen()
  local s = next(component.list("screen"))
  if s then
    gpu.bind(s)
  end
end

tryBindScreen()

-- small boot splash
local ok, w, h = pcall(function() return gpu.getResolution() end)
if ok and w and h then
  gpu.fill(1,1,w,h," ")
  gpu.set(2,2,"WinOC Bootloader")
  gpu.set(2,4,"Checking /os/core.lua ...")
end

-- helper: write a string to a path
local function writeFile(path, content)
  local f = io.open(path, "wb")
  if not f then return false end
  f:write(content)
  f:close()
  return true
end

-- if core exists locally, run it
if fs.exists("/os/core.lua") then
  -- run local core
  pcall(dofile, "/os/core.lua")
  return
end

-- attempt to download from GitHub using component.internet (if present)
local inetAddr = next(component.list("internet"))
if inetAddr then
  local internet = component.proxy(inetAddr)
  local url = "https://raw.githubusercontent.com/bloodbinder256/OS/main/os/core.lua"
  local ok, handle = pcall(internet.request, internet, url)
  if ok and handle then
    local data = ""
    for chunk in handle do
      data = data .. chunk
    end
    if #data > 0 then
      if not fs.exists("/os") then pcall(fs.makeDirectory, "/os") end
      if writeFile("/os/core.lua", data) then
        pcall(dofile, "/os/core.lua")
        return
      end
    end
  end
end

-- fallback message
if ok and w and h then
  gpu.set(2,6,"Could not find or download /os/core.lua")
  gpu.set(2,8,"Options:")
  gpu.set(2,9," - Place files onto the disk in your world folder")
  gpu.set(2,10," - Give this computer an Internet card and try again")
  gpu.set(2,12,"Press any key to reboot...")
  os.pullEvent("key")
  os.execute("reboot")
else
  print("Could not find /os/core.lua and unable to download.")
  print("Place files on disk or add an internet card.")
end
